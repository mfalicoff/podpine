import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/metadata_sanitizer.dart';

void main() {
  test('sanitizes untrusted metadata before rendering', () {
    expect(
      MetadataSanitizer.plainText(
        '<script>alert(1)</script><p>Hello &amp; welcome<br>Second line</p>',
      ),
      'Hello & welcome\nSecond line',
    );
  });

  test('allows only credential-free HTTP links', () {
    expect(
      MetadataSanitizer.safeHttpUri('https://example.test/show')?.host,
      'example.test',
    );
    expect(MetadataSanitizer.safeHttpUri('javascript:alert(1)'), isNull);
    expect(
      MetadataSanitizer.safeHttpUri('https://user:pass@example.test'),
      isNull,
    );
    expect(MetadataSanitizer.safeHttpUri('file:///private/data'), isNull);
  });
}
