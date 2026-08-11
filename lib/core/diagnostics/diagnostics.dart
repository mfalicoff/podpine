import 'package:sentry_flutter/sentry_flutter.dart';

enum DiagnosticArea { sync, download }

abstract interface class DiagnosticReporter {
  Future<void> breadcrumb(
    DiagnosticArea area,
    String operation, {
    Map<String, Object?> data = const {},
  });

  Future<void> failure(
    DiagnosticArea area,
    String operation,
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> data = const {},
  });
}

class SentryDiagnosticReporter implements DiagnosticReporter {
  const SentryDiagnosticReporter();

  @override
  Future<void> breadcrumb(
    DiagnosticArea area,
    String operation, {
    Map<String, Object?> data = const {},
  }) async {
    if (!Sentry.isEnabled) return;
    try {
      await Sentry.addBreadcrumb(
        Breadcrumb(
          category: 'podpine.${area.name}',
          message: _safeOperation(operation),
          data: sanitizeDiagnosticData(area, data),
          level: SentryLevel.info,
        ),
      );
    } catch (_) {
      // Diagnostics must never interfere with playback, sync, or downloads.
    }
  }

  @override
  Future<void> failure(
    DiagnosticArea area,
    String operation,
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> data = const {},
  }) async {
    if (!Sentry.isEnabled) return;
    final safeOperation = _safeOperation(operation);
    try {
      await breadcrumb(
        area,
        safeOperation,
        data: {...data, 'outcome': 'failed'},
      );
      await Sentry.captureException(
        DiagnosticFailure(
          area: area.name,
          operation: safeOperation,
          errorType: error.runtimeType.toString(),
        ),
        stackTrace: stackTrace,
      );
    } catch (_) {
      // Diagnostics must never replace the application error being reported.
    }
  }
}

class DiagnosticFailure implements Exception {
  const DiagnosticFailure({
    required this.area,
    required this.operation,
    required this.errorType,
  });

  final String area;
  final String operation;
  final String errorType;

  @override
  String toString() => '$area.$operation failed ($errorType)';
}

const _allowedKeys = <DiagnosticArea, Set<String>>{
  DiagnosticArea.sync: {
    'attempts',
    'mutation_type',
    'outcome',
    'pending_count',
    'permanent',
  },
  DiagnosticArea.download: {
    'attempts',
    'automatic',
    'bytes_bucket',
    'http_status_family',
    'outcome',
    'resumed',
    'retry_scheduled',
  },
};

Map<String, Object> sanitizeDiagnosticData(
  DiagnosticArea area,
  Map<String, Object?> data,
) {
  final allowed = _allowedKeys[area]!;
  final result = <String, Object>{};
  for (final entry in data.entries) {
    if (!allowed.contains(entry.key)) continue;
    final value = entry.value;
    if (value is bool) {
      result[entry.key] = value;
    } else if (value is int) {
      result[entry.key] = value.clamp(0, 1000000);
    } else if (value is String && _safeToken.hasMatch(value)) {
      result[entry.key] = value;
    }
  }
  return result;
}

String downloadBytesBucket(int bytes) => switch (bytes) {
  < 1024 * 1024 => 'under_1_mib',
  < 10 * 1024 * 1024 => '1_to_10_mib',
  < 100 * 1024 * 1024 => '10_to_100_mib',
  _ => 'over_100_mib',
};

String httpStatusFamily(int? statusCode) {
  if (statusCode == null) return 'none';
  return switch (statusCode ~/ 100) {
    1 => '1xx',
    2 => '2xx',
    3 => '3xx',
    4 => '4xx',
    5 => '5xx',
    _ => 'other',
  };
}

void configureProductionDiagnostics(
  SentryFlutterOptions options, {
  required String dsn,
  String? environment,
}) {
  options
    ..dsn = dsn
    ..environment = environment
    ..sendDefaultPii = false
    ..captureFailedRequests = false
    ..recordHttpBreadcrumbs = false
    ..enablePrintBreadcrumbs = false
    ..maxRequestBodySize = MaxRequestBodySize.never
    ..tracesSampleRate = 0
    ..beforeBreadcrumb = _scrubBreadcrumb
    ..beforeSend = (event, _) => scrubDiagnosticEvent(event);
}

SentryEvent scrubDiagnosticEvent(SentryEvent event) {
  event
    ..user = null
    ..request = null
    ..message = null;
  // Sentry deprecates arbitrary extras, but old SDK integrations can still
  // attach them. Clear that legacy field at the final privacy boundary.
  // ignore: deprecated_member_use
  event.extra = null;
  for (final exception in event.exceptions ?? const <SentryException>[]) {
    exception
      ..value = exception.type
      ..throwable = null;
  }
  event.breadcrumbs = event.breadcrumbs
      ?.map((breadcrumb) => _scrubBreadcrumb(breadcrumb, Hint()))
      .whereType<Breadcrumb>()
      .toList(growable: false);
  return event;
}

Breadcrumb? _scrubBreadcrumb(Breadcrumb? breadcrumb, Hint _) {
  if (breadcrumb == null) return null;
  final category = breadcrumb.category;
  final area = switch (category) {
    'podpine.sync' => DiagnosticArea.sync,
    'podpine.download' => DiagnosticArea.download,
    _ => null,
  };
  if (area == null) return null;
  breadcrumb
    ..message = _safeOperation(breadcrumb.message ?? 'event')
    ..data = sanitizeDiagnosticData(area, breadcrumb.data ?? const {});
  return breadcrumb;
}

String _safeOperation(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(
    RegExp('[^a-z0-9_]+'),
    '_',
  );
  if (normalized.isEmpty) return 'event';
  return normalized.substring(0, normalized.length.clamp(0, 48));
}

final _safeToken = RegExp(r'^[a-z0-9_.-]{1,48}$');
