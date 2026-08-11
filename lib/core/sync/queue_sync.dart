import 'dart:convert';

import '../backend/podcast_backend.dart';

class QueueSyncOperation {
  const QueueSyncOperation({
    required this.id,
    required this.type,
    required this.baseRevision,
    required this.baseOrder,
    required this.desiredOrder,
    this.episodeId,
  });

  factory QueueSyncOperation.fromPayload({
    required String id,
    required String type,
    required int? episodeId,
    required Map<String, dynamic> payload,
  }) {
    final payloadOperationId = payload['operationId'];
    if (payloadOperationId != null && '$payloadOperationId' != id) {
      throw const FormatException(
        'Queue operation ID does not match its durable outbox ID.',
      );
    }
    final baseOrder = _episodeIds(
      payload['baseOrder'] ?? payload['episodeIds'],
    );
    var desiredOrder = _episodeIds(payload['order']);
    if (type == 'queue_remove') {
      desiredOrder = baseOrder.where((value) => value != episodeId).toList();
    } else if (type == 'queue_clear') {
      desiredOrder = const [];
    }
    return QueueSyncOperation(
      id: id,
      type: type,
      episodeId: episodeId,
      baseRevision: '${payload['baseRevision'] ?? queueRevision(baseOrder)}',
      baseOrder: baseOrder,
      desiredOrder: desiredOrder,
    );
  }

  final String id;
  final String type;
  final int? episodeId;
  final String baseRevision;
  final List<int> baseOrder;
  final List<int> desiredOrder;
}

class QueueSyncResult {
  const QueueSyncResult({
    required this.order,
    required this.revision,
    required this.conflicted,
  });

  final List<int> order;
  final String revision;
  final bool conflicted;
}

/// Applies queue operations by rebasing them onto the latest server snapshot.
///
/// Pinepods currently exposes materialized queue endpoints rather than an
/// atomic compare-and-swap API. The operation remains idempotent across retry:
/// if its converged target is already materialized, no write is sent.
class QueueSyncCoordinator {
  const QueueSyncCoordinator(this.backend, this.userId);

  final PodcastBackend backend;
  final int userId;

  Future<QueueSyncResult> apply(QueueSyncOperation operation) async {
    final current = await _serverOrder();
    final base = _normalized(operation.baseOrder);
    final desired = _desiredOrder(operation, current, base);
    final currentRevision = queueRevision(current);
    final resumedPartialAdd =
        operation.type == 'queue_add' &&
        operation.episodeId != null &&
        !base.contains(operation.episodeId) &&
        current.contains(operation.episodeId) &&
        _sameMembers(current, desired);
    final conflicted =
        !resumedPartialAdd &&
        currentRevision != operation.baseRevision &&
        !_sameOrder(current, base) &&
        !_sameOrder(current, desired);
    final target = resumedPartialAdd
        ? desired
        : conflicted
        ? mergeConcurrentQueueOrders(
            base: base,
            local: desired,
            remote: current,
          )
        : desired;

    if (!_sameOrder(current, target)) {
      await _materialize(current, target);
    }
    return QueueSyncResult(
      order: target,
      revision: queueRevision(target),
      conflicted: conflicted,
    );
  }

  Future<List<int>> _serverOrder() async {
    final remote = await backend.getQueue(userId);
    final indexed = remote.indexed.toList()
      ..sort((left, right) {
        final leftPosition = left.$2.queuePosition ?? left.$1;
        final rightPosition = right.$2.queuePosition ?? right.$1;
        final result = leftPosition.compareTo(rightPosition);
        return result == 0 ? left.$1.compareTo(right.$1) : result;
      });
    return _normalized(indexed.map((entry) => entry.$2.id));
  }

  List<int> _desiredOrder(
    QueueSyncOperation operation,
    List<int> current,
    List<int> base,
  ) {
    switch (operation.type) {
      case 'queue_add':
        final episodeId = operation.episodeId;
        if (episodeId == null || episodeId <= 0) {
          throw const FormatException('Queue add mutation has no episode.');
        }
        if (operation.desiredOrder.isNotEmpty) {
          return _normalized(operation.desiredOrder);
        }
        return _normalized([...base.isEmpty ? current : base, episodeId]);
      case 'queue_remove':
        final episodeId = operation.episodeId;
        if (episodeId == null || episodeId <= 0) {
          throw const FormatException('Queue remove mutation has no episode.');
        }
        return _normalized(
          (base.isEmpty ? current : base).where((id) => id != episodeId),
        );
      case 'queue_reorder':
        return _normalized(operation.desiredOrder);
      case 'queue_clear':
        return const [];
      default:
        throw UnsupportedError(
          'Unknown queue operation type: ${operation.type}',
        );
    }
  }

  Future<void> _materialize(List<int> current, List<int> target) async {
    final targetSet = target.toSet();
    for (final episodeId in current.where((id) => !targetSet.contains(id))) {
      await backend.removeFromQueue(userId, episodeId);
    }

    final currentSet = current.toSet();
    for (final episodeId in target.where((id) => !currentSet.contains(id))) {
      await backend.addToQueue(userId, episodeId);
    }

    final remaining = current.where(targetSet.contains).toList()
      ..addAll(target.where((id) => !currentSet.contains(id)));
    if (!_sameOrder(remaining, target)) {
      final reorderBackend = backend is QueueReorderBackend
          ? backend as QueueReorderBackend
          : null;
      if (reorderBackend == null) {
        throw UnsupportedError('Queue reordering is unavailable.');
      }
      await reorderBackend.reorderQueue(userId, target);
    }
  }
}

String queueRevision(Iterable<int> order) =>
    'queue-v1:${_normalized(order).join(',')}';

/// A commutative three-way merge for queue snapshots with the same base.
///
/// Removing a base item wins over retaining or moving it, while additions from
/// either side survive. Conflicting orderings are resolved by choosing the
/// lexicographically smaller complete ordering, making reconnect order stable.
List<int> mergeConcurrentQueueOrders({
  required List<int> base,
  required List<int> local,
  required List<int> remote,
}) {
  final normalizedBase = _normalized(base);
  final normalizedLocal = _normalized(local);
  final normalizedRemote = _normalized(remote);
  final baseSet = normalizedBase.toSet();
  final localSet = normalizedLocal.toSet();
  final remoteSet = normalizedRemote.toSet();
  final members = <int>{
    for (final id in normalizedBase)
      if (localSet.contains(id) && remoteSet.contains(id)) id,
    ...normalizedLocal.where((id) => !baseSet.contains(id)),
    ...normalizedRemote.where((id) => !baseSet.contains(id)),
  };
  final localCandidate = _expanded(normalizedLocal, members);
  final remoteCandidate = _expanded(normalizedRemote, members);
  return _compareOrders(localCandidate, remoteCandidate) <= 0
      ? localCandidate
      : remoteCandidate;
}

List<int> _expanded(List<int> order, Set<int> members) {
  final result = order.where(members.contains).toList();
  final present = result.toSet();
  result.addAll(members.where((id) => !present.contains(id)).toList()..sort());
  return result;
}

int _compareOrders(List<int> left, List<int> right) {
  for (var index = 0; index < left.length && index < right.length; index++) {
    final result = left[index].compareTo(right[index]);
    if (result != 0) return result;
  }
  return left.length.compareTo(right.length);
}

bool _sameOrder(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _sameMembers(List<int> left, List<int> right) =>
    left.length == right.length && left.toSet().containsAll(right);

List<int> _episodeIds(Object? value) {
  if (value is String) {
    try {
      return _episodeIds(jsonDecode(value));
    } on FormatException {
      return const [];
    }
  }
  return _normalized(
    (value as List? ?? const [])
        .map((id) => id is int ? id : int.tryParse('$id'))
        .whereType<int>(),
  );
}

List<int> _normalized(Iterable<int> values) {
  final seen = <int>{};
  return values.where((id) => id > 0 && seen.add(id)).toList(growable: false);
}
