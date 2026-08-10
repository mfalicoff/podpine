import 'dart:convert';

enum SkipSilenceStrength {
  off,
  conservative,
  moderate,
  aggressive;

  String get label => switch (this) {
    off => 'Off',
    conservative => 'Conservative',
    moderate => 'Moderate',
    aggressive => 'Aggressive',
  };

  static SkipSilenceStrength parse(String? value) => values.firstWhere(
    (strength) => strength.name == value,
    orElse: () => off,
  );
}

class PlaybackPreferences {
  const PlaybackPreferences({
    this.speed = 1,
    this.skipSilence = SkipSilenceStrength.off,
  });

  final double speed;
  final SkipSilenceStrength skipSilence;
}

class PodcastPlaybackOverride {
  const PodcastPlaybackOverride({this.speed, this.skipSilence});

  final double? speed;
  final SkipSilenceStrength? skipSilence;

  bool get isEmpty => speed == null && skipSilence == null;
}

class PodcastChapter {
  const PodcastChapter({
    required this.start,
    required this.title,
    this.end,
    this.imageUrl,
    this.url,
  });

  final Duration start;
  final Duration? end;
  final String title;
  final String? imageUrl;
  final String? url;

  Map<String, Object?> toJson() => <String, Object?>{
    'startTime': start.inMilliseconds / 1000,
    if (end != null) 'endTime': end!.inMilliseconds / 1000,
    'title': title,
    if (imageUrl != null) 'img': imageUrl,
    if (url != null) 'url': url,
  };
}

class ChapterParser {
  const ChapterParser._();

  static List<PodcastChapter> parse(
    String metadata, {
    String description = '',
  }) {
    final decoded = _tryDecode(metadata);
    final rows = decoded is Map ? decoded['chapters'] : decoded;
    if (rows is List) {
      final chapters = rows
          .whereType<Map>()
          .map(_chapterFromJson)
          .whereType<PodcastChapter>()
          .toList();
      if (chapters.isNotEmpty) return _normalized(chapters);
    }
    return parseDescription(description);
  }

  static List<PodcastChapter> parseDescription(String description) {
    final plain = description
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ');
    final expression = RegExp(
      r'(?:^|\n)\s*(?:(\d{1,2}):)?(\d{1,2}):(\d{2})\s*(?:[-–—|:]\s*)?([^\n]+)',
      multiLine: true,
    );
    final chapters = <PodcastChapter>[];
    for (final match in expression.allMatches(plain)) {
      final hours = int.tryParse(match.group(1) ?? '') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '') ?? 0;
      final title = (match.group(4) ?? '').trim();
      if (minutes > 59 && hours > 0 || seconds > 59 || title.isEmpty) continue;
      chapters.add(
        PodcastChapter(
          start: Duration(hours: hours, minutes: minutes, seconds: seconds),
          title: title,
        ),
      );
    }
    return _normalized(chapters);
  }

  static String normalizeMetadata(Object? value) {
    if (value == null) return '[]';
    final decoded = value is String ? _tryDecode(value) : value;
    final rows = decoded is Map ? decoded['chapters'] : decoded;
    if (rows is! List) return '[]';
    final chapters = rows
        .whereType<Map>()
        .map(_chapterFromJson)
        .whereType<PodcastChapter>()
        .toList();
    return jsonEncode(
      _normalized(chapters).map((chapter) => chapter.toJson()).toList(),
    );
  }

  static Object? _tryDecode(String value) {
    if (value.trim().isEmpty) return null;
    try {
      return jsonDecode(value);
    } on FormatException {
      return null;
    }
  }

  static PodcastChapter? _chapterFromJson(Map row) {
    if (row['toc'] == false) return null;
    final seconds = switch (row['startTime'] ?? row['start']) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
    if (seconds == null || seconds < 0) return null;
    final title = '${row['title'] ?? 'Chapter'}'.trim();
    final endSeconds = switch (row['endTime'] ?? row['end']) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
    return PodcastChapter(
      start: Duration(milliseconds: (seconds * 1000).round()),
      end: endSeconds == null
          ? null
          : Duration(milliseconds: (endSeconds * 1000).round()),
      title: title.isEmpty ? 'Chapter' : title,
      imageUrl: _optionalText(row['img'] ?? row['imageUrl']),
      url: _optionalText(row['url']),
    );
  }

  static String? _optionalText(Object? value) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? null : text;
  }

  static List<PodcastChapter> _normalized(List<PodcastChapter> chapters) {
    chapters.sort((a, b) => a.start.compareTo(b.start));
    final result = <PodcastChapter>[];
    for (final chapter in chapters) {
      if (result.isNotEmpty && result.last.start == chapter.start) continue;
      result.add(chapter);
    }
    return List<PodcastChapter>.unmodifiable(result);
  }
}
