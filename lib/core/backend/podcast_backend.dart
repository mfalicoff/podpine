class RemotePodcast {
  const RemotePodcast({
    required this.id,
    required this.title,
    required this.author,
    required this.artworkUrl,
    required this.description,
    required this.feedUrl,
    required this.episodeCount,
  });

  final int id;
  final String title;
  final String author;
  final String artworkUrl;
  final String description;
  final String feedUrl;
  final int episodeCount;
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
}

abstract interface class PodcastBackend {
  Future<int> verifyConnection();
  Future<List<RemotePodcast>> getSubscriptions(int userId);
  Future<List<RemoteEpisode>> getEpisodes(int userId);
  Future<List<RemoteEpisode>> getQueue(int userId);
  Future<String> getChapters(int userId, int episodeId);
  Future<void> updatePlayback(int userId, int episodeId, Duration position);
  Future<void> markCompleted(int userId, int episodeId, bool completed);
  Future<void> addToQueue(int userId, int episodeId);
  Future<void> removeFromQueue(int userId, int episodeId);
}
