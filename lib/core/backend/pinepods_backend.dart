import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'podcast_backend.dart';
import '../../features/player/playback_options.dart';

class PinepodsException implements Exception {
  const PinepodsException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class PinepodsBackend
    implements PodcastBackend, EpisodeDownloadBackend, QueueControlBackend {
  PinepodsBackend({
    required String serverUrl,
    required this.apiKey,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 15),
  }) : baseUri = Uri.parse(serverUrl.replaceFirst(RegExp(r'/+$'), '')),
       _client = client ?? http.Client();

  final Uri baseUri;
  final String apiKey;
  final Duration requestTimeout;
  final http.Client _client;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Api-Key': apiKey,
  };

  Uri _uri(String path, [Map<String, String>? query]) =>
      baseUri.replace(path: '${baseUri.path}$path', queryParameters: query);

  Future<Object?> _get(String path, [Map<String, String>? query]) async {
    return _send(() => _client.get(_uri(path, query), headers: _headers));
  }

  Future<Object?> _post(
    String path,
    Map<String, Object?> body, [
    Map<String, String>? query,
  ]) async {
    return _send(
      () => _client.post(
        _uri(path, query),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Object?> _send(Future<http.Response> Function() request) async {
    try {
      return _decode(await request().timeout(requestTimeout));
    } on PinepodsException {
      rethrow;
    } on TimeoutException {
      throw const PinepodsException(
        'Pinepods did not respond before the request timed out.',
      );
    } on FormatException {
      throw const PinepodsException('Pinepods returned malformed JSON.');
    } on http.ClientException catch (error) {
      throw PinepodsException('Could not reach Pinepods: ${error.message}');
    }
  }

  Object? _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PinepodsException(switch (response.statusCode) {
        401 => 'The API key was rejected by this server.',
        403 => 'The API key is not allowed to perform this action.',
        404 => 'The requested Pinepods endpoint was not found.',
        final code => 'Pinepods returned HTTP $code.',
      }, statusCode: response.statusCode);
    }
    if (response.body.trim().isEmpty) return null;
    return jsonDecode(response.body);
  }

  @override
  Future<int> verifyConnection() async {
    final check = await _get('/api/pinepods_check');
    if (check is! Map || !_bool(_field(check, 'pinepods_instance'))) {
      throw const PinepodsException('This URL is not a Pinepods server.');
    }
    await _get('/api/data/verify_key');
    final user = await _get('/api/data/get_user');
    if (user is Map) {
      final userId = _int(
        _field(user, 'retrieved_id') ?? _field(user, 'user_id'),
      );
      if (userId > 0) return userId;
    }
    throw const PinepodsException(
      'The server did not return a user for this API key.',
    );
  }

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async {
    final json = await _get('/api/data/return_pods/$userId');
    return _mapRows(json, 'pods', 'subscriptions', _podcastFromJson);
  }

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async {
    final json = await _get('/api/data/return_episodes/$userId', {
      'limit': '500',
    });
    return _mapRows(json, 'episodes', 'episodes', _episodeFromJson);
  }

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async {
    final json = await _get('/api/data/get_queued_episodes', {
      'user_id': '$userId',
    });
    return _mapRows(json, 'data', 'queue', _episodeFromJson);
  }

  @override
  Future<List<RemotePodcast>> searchPodcasts(
    String query, {
    String provider = 'podcast_index',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final json = await _get('/api/data/proxy_search', {
      'query': trimmed,
      'index': provider,
    });
    if (json is! Map) {
      throw const PinepodsException(
        'Pinepods returned a malformed search response.',
      );
    }
    final rows = _field(json, 'feeds') ?? _field(json, 'results');
    if (rows is! List) {
      throw const PinepodsException(
        'Pinepods returned a malformed search response.',
      );
    }
    return rows
        .whereType<Map>()
        .map(
          (row) => provider == 'itunes'
              ? _itunesPodcastFromJson(row)
              : _searchPodcastFromJson(row),
        )
        .where((podcast) => podcast.feedUrl.trim().isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<RemotePodcast> getPodcastDetails(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async {
    final json = await _get('/api/data/get_podcast_details_dynamic', {
      'user_id': '$userId',
      'podcast_title': podcast.title,
      'podcast_url': podcast.feedUrl,
      'podcast_index_id': '${podcast.podcastIndexId}',
      'added': '$subscribed',
      'display_only': 'true',
    });
    if (json is! Map) {
      throw const PinepodsException(
        'Pinepods returned malformed podcast details.',
      );
    }
    return RemotePodcast(
      id: _int(_field(json, 'podcastid')) > 0
          ? _int(_field(json, 'podcastid'))
          : podcast.id,
      title: _text(_field(json, 'podcastname'), podcast.title),
      author: _text(_field(json, 'author'), podcast.author),
      artworkUrl: _text(_field(json, 'artworkurl'), podcast.artworkUrl),
      description: _text(_field(json, 'description'), podcast.description),
      feedUrl: _text(_field(json, 'feedurl'), podcast.feedUrl),
      episodeCount: _int(_field(json, 'episodecount')) > 0
          ? _int(_field(json, 'episodecount'))
          : podcast.episodeCount,
      websiteUrl: _text(_field(json, 'websiteurl'), podcast.websiteUrl),
      categories: _categories(_field(json, 'categories')).isEmpty
          ? podcast.categories
          : _categories(_field(json, 'categories')),
      explicit: _field(json, 'explicit') == null
          ? podcast.explicit
          : _bool(_field(json, 'explicit')),
      podcastIndexId: _int(_field(json, 'podcastindexid')) > 0
          ? _int(_field(json, 'podcastindexid'))
          : podcast.podcastIndexId,
    );
  }

  @override
  Future<List<RemoteEpisode>> getPodcastEpisodes(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async {
    final json = subscribed && podcast.id > 0
        ? await _get('/api/data/podcast_episodes', {
            'user_id': '$userId',
            'podcast_id': '${podcast.id}',
          })
        : await _get('/api/data/fetch_podcast_feed', {
            'podcast_feed': podcast.feedUrl,
          });
    if (json is! Map || _field(json, 'episodes') is! List) {
      throw const PinepodsException(
        'Pinepods returned malformed podcast episodes.',
      );
    }
    final rows = _field(json, 'episodes')! as List;
    return rows
        .whereType<Map>()
        .map((row) {
          return _episodeFromJson(
            row,
            fallbackPodcast: podcast,
            allowMissingId: !subscribed,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<int> subscribe(int userId, RemotePodcast podcast) async {
    final json = await _post('/api/data/add_podcast', {
      'podcast_values': {
        'pod_title': podcast.title,
        'pod_artwork': podcast.artworkUrl,
        'pod_author': podcast.author,
        'categories': {
          for (final (index, category) in podcast.categories.indexed)
            '$index': category,
        },
        'pod_description': podcast.description,
        'pod_episode_count': podcast.episodeCount,
        'pod_feed_url': podcast.feedUrl,
        'pod_website': podcast.websiteUrl,
        'pod_explicit': podcast.explicit,
        'user_id': userId,
      },
      'podcast_index_id': podcast.podcastIndexId,
    });
    if (json is! Map || !_bool(_field(json, 'success'))) {
      throw const PinepodsException('Pinepods could not add this podcast.');
    }
    return _int(_field(json, 'podcastid'));
  }

  @override
  Future<void> unsubscribe(int userId, RemotePodcast podcast) async {
    final json = await _post('/api/data/remove_podcast', {
      'podcast_name': podcast.title,
      'podcast_url': podcast.feedUrl,
      'user_id': userId,
    });
    if (json is Map &&
        _field(json, 'success') != null &&
        !_bool(_field(json, 'success'))) {
      throw const PinepodsException('Pinepods could not remove this podcast.');
    }
  }

  @override
  Future<String> getChapters(int userId, int episodeId) async {
    final json = await _get('/api/data/fetch_podcasting_2_data', {
      'episode_id': '$episodeId',
      'user_id': '$userId',
    });
    if (json is! Map) {
      throw const PinepodsException(
        'Pinepods returned malformed Podcasting 2.0 data.',
      );
    }
    return ChapterParser.normalizeMetadata(_field(json, 'chapters'));
  }

  @override
  Future<void> updatePlayback(int userId, int episodeId, Duration position) =>
      _post('/api/data/record_listen_duration', {
        'episode_id': episodeId,
        'user_id': userId,
        'listen_duration': position.inSeconds,
        'is_youtube': false,
      });

  @override
  Future<void> markCompleted(int userId, int episodeId, bool completed) =>
      _post(
        completed
            ? '/api/data/mark_episode_completed'
            : '/api/data/mark_episode_uncompleted',
        {'episode_id': episodeId, 'user_id': userId, 'is_youtube': false},
      );

  @override
  Future<void> addToQueue(int userId, int episodeId) => _post(
    '/api/data/queue_pod',
    {'episode_id': episodeId, 'user_id': userId, 'is_youtube': false},
  );

  @override
  Future<void> removeFromQueue(int userId, int episodeId) => _post(
    '/api/data/remove_queued_pod',
    {'episode_id': episodeId, 'user_id': userId, 'is_youtube': false},
  );

  @override
  Future<void> setEpisodeDownloaded(
    int userId,
    int episodeId,
    bool downloaded,
  ) => _post(
    downloaded
        ? '/api/data/bulk_download_episodes'
        : '/api/data/bulk_delete_downloaded_episodes',
    {
      'episode_ids': [episodeId],
      'user_id': userId,
      'is_youtube': false,
    },
  );

  @override
  Future<void> reorderQueue(int userId, List<int> episodeIds) => _post(
    '/api/data/reorder_queue',
    {'episode_ids': episodeIds},
    {'user_id': '$userId'},
  );

  @override
  Future<void> clearQueue(int userId) =>
      _post('/api/data/clear_queue', {'user_id': userId});

  static List<T> _mapRows<T>(
    Object? response,
    String field,
    String resource,
    T Function(Map json) convert,
  ) {
    if (response is! Map) {
      throw PinepodsException(
        'Pinepods returned a malformed $resource response.',
      );
    }
    final rows = _field(response, field);
    if (rows is! List) {
      throw PinepodsException(
        'Pinepods returned a malformed $resource response.',
      );
    }
    return rows
        .map((row) {
          if (row is! Map) {
            throw PinepodsException(
              'Pinepods returned a malformed $resource item.',
            );
          }
          return convert(row);
        })
        .toList(growable: false);
  }

  static RemotePodcast _podcastFromJson(Map json) {
    final id = _int(_field(json, 'podcastid'));
    if (id <= 0) {
      throw const PinepodsException(
        'Pinepods returned a subscription without a valid podcast ID.',
      );
    }
    return RemotePodcast(
      id: id,
      title: '${_field(json, 'podcastname') ?? 'Untitled podcast'}',
      author: '${_field(json, 'author') ?? ''}',
      artworkUrl: '${_field(json, 'artworkurl') ?? ''}',
      description: '${_field(json, 'description') ?? ''}',
      feedUrl: '${_field(json, 'feedurl') ?? ''}',
      episodeCount: _int(_field(json, 'episodecount')),
      websiteUrl: '${_field(json, 'websiteurl') ?? ''}',
      categories: _categories(_field(json, 'categories')),
      explicit: _bool(_field(json, 'explicit')),
      podcastIndexId: _int(_field(json, 'podcastindexid')),
    );
  }

  static RemoteEpisode _episodeFromJson(
    Map json, {
    RemotePodcast? fallbackPodcast,
    bool allowMissingId = false,
  }) {
    var id = _int(_field(json, 'episodeid'));
    if (id <= 0 && allowMissingId) {
      id = _temporaryId(
        _text(
          _field(json, 'episodeurl') ?? _field(json, 'enclosure_url'),
          _text(
            _field(json, 'episodetitle') ?? _field(json, 'title'),
            'episode',
          ),
        ),
      );
    }
    if (id <= 0 && !allowMissingId) {
      throw const PinepodsException(
        'Pinepods returned an episode without a valid episode ID.',
      );
    }
    final queuePosition = _field(json, 'queueposition');
    return RemoteEpisode(
      id: id,
      podcastId: _int(_field(json, 'podcastid')) != 0
          ? _int(_field(json, 'podcastid'))
          : fallbackPodcast?.id ?? 0,
      podcastTitle: _text(
        _field(json, 'podcastname'),
        fallbackPodcast?.title ?? '',
      ),
      title: _text(
        _field(json, 'episodetitle') ?? _field(json, 'title'),
        'Untitled episode',
      ),
      description: _text(
        _field(json, 'episodedescription') ??
            _field(json, 'description') ??
            _field(json, 'content'),
        '',
      ),
      artworkUrl: _text(
        _field(json, 'episodeartwork') ?? _field(json, 'artwork'),
        fallbackPodcast?.artworkUrl ?? '',
      ),
      audioUrl: _text(
        _field(json, 'episodeurl') ?? _field(json, 'enclosure_url'),
        '',
      ),
      publishedAt: _dateTime(
        _field(json, 'episodepubdate') ?? _field(json, 'pub_date'),
      ),
      durationSeconds: _int(
        _field(json, 'episodeduration') ?? _field(json, 'duration'),
      ),
      positionSeconds: _int(_field(json, 'listenduration')),
      completed: _bool(_field(json, 'completed')),
      queued: _bool(_field(json, 'queued')),
      downloaded: _bool(_field(json, 'downloaded')),
      isYoutube: _bool(_field(json, 'is_youtube')),
      chaptersJson: ChapterParser.normalizeMetadata(
        _field(json, 'chapters') ?? _field(json, 'episode_chapters'),
      ),
      queuePosition: queuePosition == null ? null : _int(queuePosition),
      playbackUpdatedAt: _optionalDateTime(
        _field(json, 'playbackupdatedat') ??
            _field(json, 'listenupdatedat') ??
            _field(json, 'lastlistenedat'),
      ),
      playbackDeviceId: _optionalText(
        _field(json, 'playbackdeviceid') ?? _field(json, 'deviceid'),
      ),
    );
  }

  static RemotePodcast _searchPodcastFromJson(Map json) => RemotePodcast(
    id: 0,
    title: _text(_field(json, 'title'), 'Untitled podcast'),
    author: _text(_field(json, 'author'), _text(_field(json, 'ownername'), '')),
    artworkUrl: _text(
      _field(json, 'artwork'),
      _text(_field(json, 'image'), ''),
    ),
    description: _text(_field(json, 'description'), ''),
    feedUrl: _text(_field(json, 'url'), _text(_field(json, 'originalurl'), '')),
    episodeCount: _int(_field(json, 'episodecount')),
    websiteUrl: _text(_field(json, 'link'), ''),
    categories: _categories(_field(json, 'categories')),
    explicit: _bool(_field(json, 'explicit')),
    podcastIndexId: _int(_field(json, 'id')),
  );

  static RemotePodcast _itunesPodcastFromJson(Map json) => RemotePodcast(
    id: 0,
    title: _text(_field(json, 'trackname'), 'Untitled podcast'),
    author: _text(_field(json, 'artistname'), ''),
    artworkUrl: _text(
      _field(json, 'artworkurl600'),
      _text(_field(json, 'artworkurl100'), ''),
    ),
    description: '',
    feedUrl: _text(_field(json, 'feedurl'), ''),
    episodeCount: _int(_field(json, 'trackcount')),
    websiteUrl: _text(_field(json, 'collectionviewurl'), ''),
    categories: _categories(_field(json, 'genres')),
    explicit:
        _text(_field(json, 'collectionexplicitness'), '').toLowerCase() ==
        'explicit',
    podcastIndexId: 0,
  );

  static Object? _field(Map json, String name) {
    final expected = _canonicalKey(name);
    for (final entry in json.entries) {
      if (_canonicalKey('${entry.key}') == expected) return entry.value;
    }
    return null;
  }

  static String _canonicalKey(String key) =>
      key.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  static int _int(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => num.tryParse(text.trim())?.toInt() ?? 0,
    _ => 0,
  };

  static String _text(Object? value, String fallback) {
    if (value == null) return fallback;
    final text = '$value'.trim();
    return text.isEmpty || text.toLowerCase() == 'null' ? fallback : text;
  }

  static String? _optionalText(Object? value) {
    final text = _text(value, '');
    return text.isEmpty ? null : text;
  }

  static List<String> _categories(Object? value) {
    final values = switch (value) {
      Map map => map.values,
      List list => list,
      String text => text.split(','),
      _ => const <Object>[],
    };
    return values
        .map((item) => '$item'.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  static int _temporaryId(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return -(hash == 0 ? 1 : hash);
  }

  static bool _bool(Object? value) => switch (value) {
    bool boolean => boolean,
    num number => number != 0,
    String text => const {
      'true',
      '1',
      'yes',
      'y',
      'on',
    }.contains(text.trim().toLowerCase()),
    _ => false,
  };

  static DateTime _dateTime(Object? value) {
    if (value is num) {
      final milliseconds = value.abs() < 100000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(
        milliseconds.toInt(),
        isUtc: true,
      );
    }
    final text = '$value'.trim();
    final parsedNumber = num.tryParse(text);
    if (parsedNumber != null) return _dateTime(parsedNumber);
    return DateTime.tryParse(text)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static DateTime? _optionalDateTime(Object? value) {
    if (value == null || '$value'.trim().isEmpty) return null;
    final parsed = _dateTime(value);
    return parsed.millisecondsSinceEpoch == 0 ? null : parsed;
  }
}
