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
  }) : baseUri = Uri.parse(serverUrl.replaceFirst(RegExp(r'/+$'), '')),
       _client = client ?? http.Client();

  final Uri baseUri;
  final String apiKey;
  final http.Client _client;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Api-Key': apiKey,
  };

  Uri _uri(String path, [Map<String, String>? query]) =>
      baseUri.replace(path: '${baseUri.path}$path', queryParameters: query);

  Future<Object?> _get(String path, [Map<String, String>? query]) async {
    final response = await _client
        .get(_uri(path, query), headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _decode(response);
  }

  Future<Object?> _post(String path, Map<String, Object?> body) async {
    final response = await _client
        .post(_uri(path), headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _decode(response);
  }

  Object? _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PinepodsException(
        response.statusCode == 401
            ? 'The API key was rejected by this server.'
            : 'Pinepods returned HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    if (response.body.trim().isEmpty) return null;
    return jsonDecode(response.body);
  }

  @override
  Future<int> verifyConnection() async {
    final check = await _get('/api/pinepods_check');
    if (check is! Map || check['pinepods_instance'] != true) {
      throw const PinepodsException('This URL is not a Pinepods server.');
    }
    await _get('/api/data/verify_key');
    final user = await _get('/api/data/get_user');
    if (user is Map && user['retrieved_id'] != null) {
      final userId = _int(user['retrieved_id']);
      if (userId > 0) return userId;
    }
    throw const PinepodsException(
      'The server did not return a user for this API key.',
    );
  }

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async {
    final json = await _get('/api/data/return_pods/$userId');
    final rows = json is Map ? json['pods'] : null;
    if (rows is! List) return const [];
    return rows.whereType<Map>().map(_podcastFromJson).toList();
  }

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async {
    final json = await _get('/api/data/return_episodes/$userId', {
      'limit': '500',
    });
    final rows = json is Map ? json['episodes'] : null;
    if (rows is! List) return const [];
    return rows.whereType<Map>().map(_episodeFromJson).toList();
  }

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async {
    final json = await _get('/api/data/get_queued_episodes', {
      'user_id': '$userId',
    });
    final rows = json is Map ? json['data'] : null;
    if (rows is! List) return const [];
    return rows.whereType<Map>().map(_episodeFromJson).toList();
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

  static RemotePodcast _podcastFromJson(Map json) => RemotePodcast(
    id: _int(json['podcastid']),
    title: '${json['podcastname'] ?? 'Untitled podcast'}',
    author: '${json['author'] ?? ''}',
    artworkUrl: '${json['artworkurl'] ?? ''}',
    description: '${json['description'] ?? ''}',
    feedUrl: '${json['feedurl'] ?? ''}',
    episodeCount: _int(json['episodecount']),
  );

  static RemoteEpisode _episodeFromJson(Map json) => RemoteEpisode(
    id: _int(json['episodeid']),
    podcastId: _int(json['podcastid']),
    podcastTitle: '${json['podcastname'] ?? ''}',
    title: '${json['episodetitle'] ?? 'Untitled episode'}',
    description: '${json['episodedescription'] ?? ''}',
    artworkUrl: '${json['episodeartwork'] ?? ''}',
    audioUrl: '${json['episodeurl'] ?? ''}',
    publishedAt:
        DateTime.tryParse('${json['episodepubdate'] ?? ''}')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    durationSeconds: _int(json['episodeduration']),
    positionSeconds: _int(json['listenduration']),
    completed: json['completed'] == true,
    queued: json['queued'] == true,
    downloaded: json['downloaded'] == true,
    isYoutube: json['is_youtube'] == true,
    queuePosition: json['queueposition'] == null
        ? null
        : _int(json['queueposition']),
  );

  static int _int(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text) ?? 0,
    _ => 0,
  };
}
