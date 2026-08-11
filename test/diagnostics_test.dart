import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/diagnostics/diagnostics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test('sync diagnostics keep only allowlisted non-identifying values', () {
    final sanitized = sanitizeDiagnosticData(DiagnosticArea.sync, {
      'outcome': 'succeeded',
      'pending_count': 3,
      'permanent': false,
      'url': 'https://private.invalid/feed?token=secret',
      'user_id': 42,
      'mutation_type': 'position',
      'arbitrary': 'private title',
    });

    expect(sanitized, {
      'outcome': 'succeeded',
      'pending_count': 3,
      'permanent': false,
      'mutation_type': 'position',
    });
  });

  test('download diagnostics bucket sizes and status codes', () {
    expect(downloadBytesBucket(12), 'under_1_mib');
    expect(downloadBytesBucket(5 * 1024 * 1024), '1_to_10_mib');
    expect(downloadBytesBucket(50 * 1024 * 1024), '10_to_100_mib');
    expect(downloadBytesBucket(150 * 1024 * 1024), 'over_100_mib');
    expect(httpStatusFamily(206), '2xx');
    expect(httpStatusFamily(503), '5xx');
    expect(httpStatusFamily(null), 'none');
  });

  test('outgoing crash events drop private payloads and exception text', () {
    final event = SentryEvent(
      user: SentryUser(id: 'private-user'),
      request: SentryRequest(url: 'https://private.invalid/path'),
      message: SentryMessage('private message'),
      // ignore: deprecated_member_use
      extra: {'token': 'secret'},
      exceptions: [
        SentryException(
          type: 'NetworkException',
          value: 'request failed for https://private.invalid?token=secret',
        ),
      ],
      breadcrumbs: [
        Breadcrumb(category: 'http', message: 'https://private.invalid'),
        Breadcrumb(
          category: 'podpine.download',
          message: 'Transfer failed for a private episode',
          data: {
            'outcome': 'failed',
            'http_status_family': '5xx',
            'url': 'https://private.invalid',
          },
        ),
      ],
    );

    final scrubbed = scrubDiagnosticEvent(event);

    expect(scrubbed.user, isNull);
    expect(scrubbed.request, isNull);
    expect(scrubbed.message, isNull);
    // ignore: deprecated_member_use
    expect(scrubbed.extra, isNull);
    expect(scrubbed.exceptions?.single.value, 'NetworkException');
    expect(scrubbed.breadcrumbs, hasLength(1));
    expect(
      scrubbed.breadcrumbs?.single.message,
      'transfer_failed_for_a_private_episode',
    );
    expect(scrubbed.breadcrumbs?.single.data, {
      'outcome': 'failed',
      'http_status_family': '5xx',
    });
  });
}
