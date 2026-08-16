import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../core/l10n.dart';
import '../../core/metadata_sanitizer.dart';

class LinkifiedText extends StatelessWidget {
  const LinkifiedText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  static final _urlPattern = RegExp(r'https?://[^\s<>]+', caseSensitive: false);
  static const _trailingPunctuation = '.,;:!?)]}';

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _urlPattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      var raw = match.group(0)!;
      var trailing = '';
      while (raw.isNotEmpty &&
          _trailingPunctuation.contains(raw[raw.length - 1])) {
        trailing = '${raw[raw.length - 1]}$trailing';
        raw = raw.substring(0, raw.length - 1);
      }
      final uri = MetadataSanitizer.safeHttpUri(raw);
      if (uri == null) {
        spans.add(TextSpan(text: match.group(0)));
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Link(
              uri: uri,
              target: LinkTarget.blank,
              builder: (context, followLink) => Semantics(
                link: true,
                label: context.l10n.openLink(uri.toString()),
                child: TextButton(
                  onPressed: followLink,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    textStyle: effectiveStyle.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: Text(raw),
                ),
              ),
            ),
          ),
        );
        if (trailing.isNotEmpty) spans.add(TextSpan(text: trailing));
      }
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));

    return SelectableText.rich(
      TextSpan(style: effectiveStyle, children: spans),
    );
  }
}
