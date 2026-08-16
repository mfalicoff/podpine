class MetadataSanitizer {
  const MetadataSanitizer._();

  static String plainText(String input) {
    var value = input
        .replaceAllMapped(
          RegExp(
            r'''<a\b[^>]*\bhref\s*=\s*["']([^"']+)["'][^>]*>([\s\S]*?)</a>''',
            caseSensitive: false,
          ),
          (match) {
            final label = match.group(2)!.replaceAll(RegExp(r'<[^>]*>'), ' ');
            final url = safeHttpUrl(match.group(1)!);
            if (url.isEmpty || label.contains(url)) return label;
            return '$label ($url)';
          },
        )
        .replaceAll(
          RegExp(r'<(script|style)[^>]*>[\s\S]*?</\1>', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</\s*(p|div|li|h[1-6])\s*>', caseSensitive: false),
          '\n',
        )
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F]'), '');
    value = value.replaceAllMapped(RegExp(r'&#(x?[0-9a-fA-F]+);'), (match) {
      final raw = match.group(1)!;
      final code = raw.startsWith('x') || raw.startsWith('X')
          ? int.tryParse(raw.substring(1), radix: 16)
          : int.tryParse(raw);
      return code == null || code > 0x10ffff ? '' : String.fromCharCode(code);
    });
    const entities = {
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&apos;': "'",
      '&nbsp;': ' ',
    };
    for (final entry in entities.entries) {
      value = value.replaceAll(entry.key, entry.value);
    }
    return value
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .join('\n')
        .trim();
  }

  static Uri? safeHttpUri(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return uri;
  }

  static String safeHttpUrl(String input) =>
      safeHttpUri(input)?.toString() ?? '';
}
