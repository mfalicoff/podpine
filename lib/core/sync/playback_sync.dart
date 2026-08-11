import '../backend/podcast_backend.dart';

/// Optional backend capability for servers that can resolve timestamped,
/// device-aware playback events atomically.
abstract interface class PlaybackEventBackend {
  Future<void> updatePlaybackEvent(int userId, PlaybackSyncEvent event);
}

enum PlaybackEventKind {
  progress,
  seek,
  completed,
  uncompleted;

  static PlaybackEventKind parse(Object? value) => values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => PlaybackEventKind.progress,
  );
}

class PlaybackSyncEvent {
  const PlaybackSyncEvent({
    required this.episodeId,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.completed,
    required this.kind,
    required this.occurredAt,
    required this.deviceId,
    required this.mediaIdentity,
  });

  final int episodeId;
  final int positionSeconds;
  final int durationSeconds;
  final bool completed;
  final PlaybackEventKind kind;
  final DateTime occurredAt;
  final String deviceId;
  final String mediaIdentity;

  Map<String, Object?> toPayload() => {
    'playbackEventVersion': 1,
    'seconds': positionSeconds,
    'durationSeconds': durationSeconds,
    'completed': completed,
    'kind': kind.name,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'deviceId': deviceId,
    'mediaIdentity': mediaIdentity,
  };

  factory PlaybackSyncEvent.fromPayload({
    required int episodeId,
    required Map<String, dynamic> payload,
    required DateTime fallbackOccurredAt,
    required PlaybackEventKind fallbackKind,
  }) => PlaybackSyncEvent(
    episodeId: episodeId,
    positionSeconds: _int(payload['seconds']),
    durationSeconds: _int(payload['durationSeconds']),
    completed: payload['completed'] == true || payload['value'] == true,
    kind: payload.containsKey('kind')
        ? PlaybackEventKind.parse(payload['kind'])
        : fallbackKind,
    occurredAt:
        DateTime.tryParse('${payload['occurredAt'] ?? ''}')?.toUtc() ??
        fallbackOccurredAt.toUtc(),
    deviceId: '${payload['deviceId'] ?? ''}',
    mediaIdentity: '${payload['mediaIdentity'] ?? ''}',
  );
}

class PlaybackEventDecision {
  const PlaybackEventDecision._(this.shouldApply, this.positionSeconds);

  const PlaybackEventDecision.apply(int positionSeconds)
    : this._(true, positionSeconds);
  const PlaybackEventDecision.ignore(int positionSeconds)
    : this._(false, positionSeconds);

  final bool shouldApply;
  final int positionSeconds;
}

PlaybackEventDecision resolvePlaybackEvent(
  PlaybackSyncEvent event,
  RemoteEpisode remote,
) {
  if (_mediaChanged(event.mediaIdentity, remote.audioUrl) ||
      _durationChanged(event.durationSeconds, remote.durationSeconds)) {
    return PlaybackEventDecision.ignore(remote.positionSeconds);
  }

  final remoteUpdatedAt = remote.playbackUpdatedAt;
  if (remoteUpdatedAt != null && remoteUpdatedAt.isAfter(event.occurredAt)) {
    return PlaybackEventDecision.ignore(remote.positionSeconds);
  }

  if (event.kind == PlaybackEventKind.completed ||
      event.kind == PlaybackEventKind.uncompleted) {
    return PlaybackEventDecision.apply(
      _boundedPosition(event.positionSeconds, remote.durationSeconds),
    );
  }

  // A position write never implicitly reopens an episode. Explicitly marking
  // it unplayed is represented by a separate uncompleted event.
  if (remote.completed) {
    return PlaybackEventDecision.ignore(remote.positionSeconds);
  }

  final candidate = _boundedPosition(
    event.positionSeconds,
    remote.durationSeconds,
  );
  if (event.kind == PlaybackEventKind.seek ||
      candidate >= remote.positionSeconds) {
    return PlaybackEventDecision.apply(candidate);
  }
  return PlaybackEventDecision.ignore(remote.positionSeconds);
}

class PlaybackSnapshotDecision {
  const PlaybackSnapshotDecision({
    required this.positionSeconds,
    required this.completed,
    required this.updatedAt,
    required this.deviceId,
    required this.intent,
    required this.mediaIdentity,
  });

  final int positionSeconds;
  final bool completed;
  final DateTime? updatedAt;
  final String? deviceId;
  final PlaybackEventKind intent;
  final String mediaIdentity;
}

PlaybackSnapshotDecision mergePlaybackSnapshot({
  required int localPositionSeconds,
  required int localDurationSeconds,
  required bool localCompleted,
  required DateTime? localUpdatedAt,
  required String? localDeviceId,
  required PlaybackEventKind localIntent,
  required String localMediaIdentity,
  required RemoteEpisode remote,
  required DateTime observedAt,
}) {
  final remoteMediaIdentity = remote.audioUrl.trim();
  final remoteWinsForMedia =
      _mediaChanged(localMediaIdentity, remoteMediaIdentity) ||
      _durationChanged(localDurationSeconds, remote.durationSeconds);
  if (remoteWinsForMedia) {
    return _remoteSnapshot(remote, observedAt);
  }

  final remoteUpdatedAt = remote.playbackUpdatedAt;
  if (remoteUpdatedAt != null &&
      (localUpdatedAt == null || remoteUpdatedAt.isAfter(localUpdatedAt))) {
    return _remoteSnapshot(remote, observedAt);
  }

  final keepLocalCompletion = localCompleted && !remote.completed;
  final keepLocalSeek =
      localIntent == PlaybackEventKind.seek &&
      localPositionSeconds != remote.positionSeconds &&
      localUpdatedAt != null &&
      (remoteUpdatedAt == null || !remoteUpdatedAt.isAfter(localUpdatedAt));
  final keepLocalProgress = localPositionSeconds > remote.positionSeconds;
  if (keepLocalCompletion || keepLocalSeek || keepLocalProgress) {
    return PlaybackSnapshotDecision(
      positionSeconds: localCompleted
          ? 0
          : _boundedPosition(localPositionSeconds, remote.durationSeconds),
      completed: localCompleted || remote.completed,
      updatedAt: localUpdatedAt,
      deviceId: localDeviceId,
      intent: localIntent,
      mediaIdentity: remoteMediaIdentity.isEmpty
          ? localMediaIdentity
          : remoteMediaIdentity,
    );
  }
  return _remoteSnapshot(remote, observedAt);
}

PlaybackSnapshotDecision _remoteSnapshot(
  RemoteEpisode remote,
  DateTime observedAt,
) => PlaybackSnapshotDecision(
  positionSeconds: remote.completed
      ? 0
      : _boundedPosition(remote.positionSeconds, remote.durationSeconds),
  completed: remote.completed,
  updatedAt: remote.playbackUpdatedAt ?? observedAt,
  deviceId: remote.playbackDeviceId,
  intent: remote.completed
      ? PlaybackEventKind.completed
      : PlaybackEventKind.progress,
  mediaIdentity: remote.audioUrl.trim(),
);

bool _mediaChanged(String local, String remote) =>
    local.trim().isNotEmpty &&
    remote.trim().isNotEmpty &&
    local.trim() != remote.trim();

bool _durationChanged(int local, int remote) {
  if (local <= 0 || remote <= 0) return false;
  final difference = (local - remote).abs();
  final tolerance = (local > remote ? local : remote) ~/ 10;
  return difference > (tolerance > 30 ? tolerance : 30);
}

int _boundedPosition(int position, int duration) =>
    position.clamp(0, duration > 0 ? duration : (1 << 31)).toInt();

int _int(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => num.tryParse(text.trim())?.toInt() ?? 0,
  _ => 0,
};
