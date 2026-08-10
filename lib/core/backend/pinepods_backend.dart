import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'podcast_backend.dart';

class PinepodsException implements Exception {
  const PinepodsException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class PinepodsBackend implements PodcastBackend {
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

  Future<Object?> _post(String path, Map<String, Object?> body) async {
    return _send(
      () => _client.post(_uri(path), headers: _headers, body: jsonEncode(body)),
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
    );
  }

  static RemoteEpisode _episodeFromJson(Map json) {
    final id = _int(_field(json, 'episodeid'));
    if (id <= 0) {
      throw const PinepodsException(
        'Pinepods returned an episode without a valid episode ID.',
      );
    }
    final queuePosition = _field(json, 'queueposition');
    return RemoteEpisode(
      id: id,
      podcastId: _int(_field(json, 'podcastid')),
      podcastTitle: '${_field(json, 'podcastname') ?? ''}',
      title: '${_field(json, 'episodetitle') ?? 'Untitled episode'}',
      description: '${_field(json, 'episodedescription') ?? ''}',
      artworkUrl: '${_field(json, 'episodeartwork') ?? ''}',
      audioUrl: '${_field(json, 'episodeurl') ?? ''}',
      publishedAt: _dateTime(_field(json, 'episodepubdate')),
      durationSeconds: _int(_field(json, 'episodeduration')),
      positionSeconds: _int(_field(json, 'listenduration')),
      completed: _bool(_field(json, 'completed')),
      queued: _bool(_field(json, 'queued')),
      downloaded: _bool(_field(json, 'downloaded')),
      isYoutube: _bool(_field(json, 'is_youtube')),
      queuePosition: queuePosition == null ? null : _int(queuePosition),
    );
  }

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
}
