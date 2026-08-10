import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/features/player/playback_options.dart';

void main() {
  test('Podcasting 2.0 JSON chapters are normalized and sorted', () {
    final chapters = ChapterParser.parse(
      jsonEncode({
        'version': '1.2.0',
        'chapters': [
          {'startTime': 90.5, 'title': 'Topic'},
          {'startTime': 0, 'title': 'Intro'},
          {'startTime': 60, 'title': 'Hidden', 'toc': false},
          {'startTime': -1, 'title': 'Invalid'},
        ],
      }),
    );

    expect(chapters.map((chapter) => chapter.title), ['Intro', 'Topic']);
    expect(chapters.last.start, const Duration(milliseconds: 90500));
  });

  test('description timestamps provide offline chapter fallback', () {
    final chapters = ChapterParser.parse(
      '[]',
      description: '''
        <p>00:00 – Welcome</p><br>
        12:34 Interview<br/>
        1:02:03 | Listener questions
      ''',
    );

    expect(chapters.map((chapter) => chapter.title), [
      'Welcome',
      'Interview',
      'Listener questions',
    ]);
    expect(
      chapters.last.start,
      const Duration(hours: 1, minutes: 2, seconds: 3),
    );
  });

  test('skip-silence values round trip through persisted names', () {
    for (final value in SkipSilenceStrength.values) {
      expect(SkipSilenceStrength.parse(value.name), value);
    }
    expect(SkipSilenceStrength.parse('future-value'), SkipSilenceStrength.off);
  });
}
