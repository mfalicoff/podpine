class RemotePodcast {
  const RemotePodcast({
    required this.id,
    required this.title,
    required this.author,
    required this.artworkUrl,
    required this.description,
    required this.feedUrl,
    required this.episodeCount,
    this.websiteUrl = '',
    this.categories = const [],
    this.explicit = false,
    this.podcastIndexId = 0,
  });

  final int id;
  final String title;
  final String author;
  final String artworkUrl;
  final String description;
  final String feedUrl;
  final int episodeCount;
  final String websiteUrl;
  final List<String> categories;
  final bool explicit;
  final int podcastIndexId;

  RemotePodcast copyWith({int? id}) => RemotePodcast(
    id: id ?? this.id,
    title: title,
    author: author,
    artworkUrl: artworkUrl,
    description: description,
    feedUrl: feedUrl,
    episodeCount: episodeCount,
    websiteUrl: websiteUrl,
    categories: categories,
    explicit: explicit,
    podcastIndexId: podcastIndexId,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'artworkUrl': artworkUrl,
    'description': description,
    'feedUrl': feedUrl,
    'episodeCount': episodeCount,
    'websiteUrl': websiteUrl,
    'categories': categories,
    'explicit': explicit,
    'podcastIndexId': podcastIndexId,
  };

  factory RemotePodcast.fromJson(Map<String, Object?> json) => RemotePodcast(
    id: _jsonInt(json['id']),
    title: '${json['title'] ?? 'Untitled podcast'}',
    author: '${json['author'] ?? ''}',
    artworkUrl: '${json['artworkUrl'] ?? ''}',
    description: '${json['description'] ?? ''}',
    feedUrl: '${json['feedUrl'] ?? ''}',
    episodeCount: _jsonInt(json['episodeCount']),
    websiteUrl: '${json['websiteUrl'] ?? ''}',
    categories: (json['categories'] as List? ?? const [])
        .map((value) => '$value')
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false),
    explicit: json['explicit'] == true,
    podcastIndexId: _jsonInt(json['podcastIndexId']),
  );
}

class RemoteEpisode {
  const RemoteEpisode({
    required this.id,
    required this.podcastId,
    required this.podcastTitle,
    required this.title,
    required this.description,
    required this.artworkUrl,
    required this.audioUrl,
    required this.publishedAt,
    required this.durationSeconds,
    required this.positionSeconds,
    required this.completed,
    required this.queued,
    required this.downloaded,
    required this.isYoutube,
    this.chaptersJson = '[]',
    this.queuePosition,
    this.playbackUpdatedAt,
    this.playbackDeviceId,
  });

  final int id;
  final int podcastId;
  final String podcastTitle;
  final String title;
  final String description;
  final String artworkUrl;
  final String audioUrl;
  final DateTime publishedAt;
  final int durationSeconds;
  final int positionSeconds;
  final bool completed;
  final bool queued;
  final bool downloaded;
  final bool isYoutube;
  final String chaptersJson;
  final int? queuePosition;
  final DateTime? playbackUpdatedAt;
  final String? playbackDeviceId;

  Map<String, Object?> toJson() => {
    'id': id,
    'podcastId': podcastId,
    'podcastTitle': podcastTitle,
    'title': title,
    'description': description,
    'artworkUrl': artworkUrl,
    'audioUrl': audioUrl,
    'publishedAt': publishedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'positionSeconds': positionSeconds,
    'completed': completed,
    'queued': queued,
    'downloaded': downloaded,
    'isYoutube': isYoutube,
    'chaptersJson': chaptersJson,
    'queuePosition': queuePosition,
    'playbackUpdatedAt': playbackUpdatedAt?.toUtc().toIso8601String(),
    'playbackDeviceId': playbackDeviceId,
  };

  factory RemoteEpisode.fromJson(Map<String, Object?> json) => RemoteEpisode(
    id: _jsonInt(json['id']),
    podcastId: _jsonInt(json['podcastId']),
    podcastTitle: '${json['podcastTitle'] ?? ''}',
    title: '${json['title'] ?? 'Untitled episode'}',
    description: '${json['description'] ?? ''}',
    artworkUrl: '${json['artworkUrl'] ?? ''}',
    audioUrl: '${json['audioUrl'] ?? ''}',
    publishedAt:
        DateTime.tryParse('${json['publishedAt'] ?? ''}')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    durationSeconds: _jsonInt(json['durationSeconds']),
    positionSeconds: _jsonInt(json['positionSeconds']),
    completed: json['completed'] == true,
    queued: json['queued'] == true,
    downloaded: json['downloaded'] == true,
    isYoutube: json['isYoutube'] == true,
    chaptersJson: '${json['chaptersJson'] ?? '[]'}',
    queuePosition: json['queuePosition'] == null
        ? null
        : _jsonInt(json['queuePosition']),
    playbackUpdatedAt: DateTime.tryParse(
      '${json['playbackUpdatedAt'] ?? ''}',
    )?.toUtc(),
    playbackDeviceId: json['playbackDeviceId'] == null
        ? null
        : '${json['playbackDeviceId']}',
  );
}

abstract interface class PodcastBackend {
  Future<int> verifyConnection();
  Future<List<RemotePodcast>> getSubscriptions(int userId);
  Future<List<RemoteEpisode>> getEpisodes(int userId);
  Future<List<RemoteEpisode>> getQueue(int userId);
  Future<List<RemotePodcast>> searchPodcasts(String query, {String provider});
  Future<RemotePodcast> getPodcastDetails(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  });
  Future<List<RemoteEpisode>> getPodcastEpisodes(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  });
  Future<int> subscribe(int userId, RemotePodcast podcast);
  Future<void> unsubscribe(int userId, RemotePodcast podcast);
  Future<String> getChapters(int userId, int episodeId);
  Future<void> updatePlayback(int userId, int episodeId, Duration position);
  Future<void> markCompleted(int userId, int episodeId, bool completed);
  Future<void> addToQueue(int userId, int episodeId);
  Future<void> removeFromQueue(int userId, int episodeId);
}

abstract interface class EpisodeDownloadBackend {
  Future<void> setEpisodeDownloaded(int userId, int episodeId, bool downloaded);
}

abstract interface class QueueReorderBackend {
  Future<void> reorderQueue(int userId, List<int> episodeIds);
}

abstract interface class QueueControlBackend implements QueueReorderBackend {
  Future<void> clearQueue(int userId);
}

int _jsonInt(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => num.tryParse(text.trim())?.toInt() ?? 0,
  _ => 0,
};
