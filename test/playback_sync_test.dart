import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/sync/playback_sync.dart';
import 'package:podpine/core/sync/sync_engine.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);

  test(
    'multi-device pause, seek, completion, and offline reconnect converge',
    () async {
      final fixture =
          jsonDecode(
                File(
                  'test/fixtures/pinepods/playback_multi_device.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final episode = fixture['episode'] as Map<String, dynamic>;
      final events = (fixture['events'] as List).cast<Map<String, dynamic>>();
      final backend = _PlaybackFixtureBackend(
        _remoteEpisode(
          position: 0,
          duration: episode['durationSeconds'] as int,
          audioUrl: episode['audioUrl'] as String,
        ),
      );
      final deviceA = AppDatabase(NativeDatabase.memory());
      final deviceB = AppDatabase(NativeDatabase.memory());
      addTearDown(deviceA.close);
      addTearDown(deviceB.close);

      Future<void> enqueueAndFlush(
        AppDatabase database,
        Map<String, dynamic> fixtureEvent,
      ) async {
        final event = _event(episode, fixtureEvent);
        await database.enqueueMutation(
          SyncMutationsCompanion.insert(
            id: fixtureEvent['name'] as String,
            type:
                event.kind == PlaybackEventKind.completed ||
                    event.kind == PlaybackEventKind.uncompleted
                ? 'completed'
                : 'position',
            episodeId: Value(event.episodeId),
            payload: Value(jsonEncode(event.toPayload())),
            createdAt: event.occurredAt,
          ),
        );
        await SyncEngine(database, backend, 7).flushPendingMutations();
      }

      await enqueueAndFlush(deviceA, events[0]);
      expect(backend.episode.positionSeconds, 120);

      // Device B reconnects later with an event that happened earlier.
      await enqueueAndFlush(deviceB, events[1]);
      expect(backend.episode.positionSeconds, 120);

      await enqueueAndFlush(deviceA, events[2]);
      expect(backend.episode.positionSeconds, 30);

      await enqueueAndFlush(deviceB, events[3]);
      expect(backend.episode.completed, isTrue);

      // An old partial position reconnecting after completion cannot reopen it.
      await enqueueAndFlush(deviceA, events[4]);
      expect(backend.episode.completed, isTrue);
      expect(backend.episode.positionSeconds, 0);
      expect(await deviceA.pendingMutations(), isEmpty);
      expect(await deviceB.pendingMutations(), isEmpty);
      expect(backend.appliedEvents, [
        'pause-on-device-a',
        'backward-seek-on-device-a',
        'completion-on-device-b',
      ]);
    },
  );

  test('media changes and material duration mismatches discard old events', () {
    final remote = _remoteEpisode(
      position: 15,
      duration: 1800,
      audioUrl: 'https://example.test/replaced.mp3',
      updatedAt: DateTime.utc(2026, 8, 11, 11),
    );
    final oldMedia = PlaybackSyncEvent(
      episodeId: 101,
      positionSeconds: 900,
      durationSeconds: 3600,
      completed: false,
      kind: PlaybackEventKind.progress,
      occurredAt: DateTime.utc(2026, 8, 11, 12),
      deviceId: 'device-a',
      mediaIdentity: 'https://example.test/original.mp3',
    );
    final wrongDuration = PlaybackSyncEvent(
      episodeId: 101,
      positionSeconds: 900,
      durationSeconds: 3600,
      completed: false,
      kind: PlaybackEventKind.progress,
      occurredAt: DateTime.utc(2026, 8, 11, 12),
      deviceId: 'device-a',
      mediaIdentity: remote.audioUrl,
    );

    expect(resolvePlaybackEvent(oldMedia, remote).shouldApply, isFalse);
    expect(resolvePlaybackEvent(wrongDuration, remote).shouldApply, isFalse);
  });

  test('device identity is durable and event metadata round-trips', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    expect(await database.ensureSyncDeviceId('device-a'), 'device-a');
    expect(await database.ensureSyncDeviceId('device-b'), 'device-a');

    final original = PlaybackSyncEvent(
      episodeId: 101,
      positionSeconds: 42,
      durationSeconds: 3600,
      completed: false,
      kind: PlaybackEventKind.seek,
      occurredAt: DateTime.utc(2026, 8, 11, 12, 34, 56),
      deviceId: 'device-a',
      mediaIdentity: 'https://example.test/episode.mp3',
    );
    final restored = PlaybackSyncEvent.fromPayload(
      episodeId: original.episodeId,
      payload: original.toPayload(),
      fallbackOccurredAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      fallbackKind: PlaybackEventKind.progress,
    );
    expect(restored.deviceId, original.deviceId);
    expect(restored.occurredAt, original.occurredAt);
    expect(restored.kind, PlaybackEventKind.seek);
    expect(restored.mediaIdentity, original.mediaIdentity);
  });

  test('snapshot merge keeps completion but resets for replaced media', () {
    final staleRemote = _remoteEpisode(position: 55, duration: 3600);
    final sticky = mergePlaybackSnapshot(
      localPositionSeconds: 0,
      localDurationSeconds: 3600,
      localCompleted: true,
      localUpdatedAt: DateTime.utc(2026, 8, 11, 10),
      localDeviceId: 'device-a',
      localIntent: PlaybackEventKind.completed,
      localMediaIdentity: staleRemote.audioUrl,
      remote: staleRemote,
      observedAt: DateTime.utc(2026, 8, 11, 11),
    );
    expect(sticky.completed, isTrue);

    final replaced = mergePlaybackSnapshot(
      localPositionSeconds: 0,
      localDurationSeconds: 3600,
      localCompleted: true,
      localUpdatedAt: DateTime.utc(2026, 8, 11, 10),
      localDeviceId: 'device-a',
      localIntent: PlaybackEventKind.completed,
      localMediaIdentity: 'https://example.test/old.mp3',
      remote: _remoteEpisode(
        position: 10,
        duration: 1800,
        audioUrl: 'https://example.test/new.mp3',
      ),
      observedAt: DateTime.utc(2026, 8, 11, 11),
    );
    expect(replaced.completed, isFalse);
    expect(replaced.positionSeconds, 10);
  });
}

PlaybackSyncEvent _event(
  Map<String, dynamic> episode,
  Map<String, dynamic> event,
) => PlaybackSyncEvent(
  episodeId: episode['id'] as int,
  positionSeconds: event['positionSeconds'] as int,
  durationSeconds: episode['durationSeconds'] as int,
  completed: event['completed'] as bool,
  kind: PlaybackEventKind.parse(event['kind']),
  occurredAt: DateTime.parse(event['occurredAt'] as String).toUtc(),
  deviceId: event['deviceId'] as String,
  mediaIdentity: episode['audioUrl'] as String,
);

RemoteEpisode _remoteEpisode({
  required int position,
  required int duration,
  String audioUrl = 'https://example.test/episode-v1.mp3',
  bool completed = false,
  DateTime? updatedAt,
  String? deviceId,
}) => RemoteEpisode(
  id: 101,
  podcastId: 12,
  podcastTitle: 'Fixture Cast',
  title: 'Conflict fixture',
  description: '',
  artworkUrl: '',
  audioUrl: audioUrl,
  publishedAt: DateTime.utc(2026, 8, 10),
  durationSeconds: duration,
  positionSeconds: position,
  completed: completed,
  queued: false,
  downloaded: false,
  isYoutube: false,
  playbackUpdatedAt: updatedAt,
  playbackDeviceId: deviceId,
);

class _PlaybackFixtureBackend implements PodcastBackend, PlaybackEventBackend {
  _PlaybackFixtureBackend(this.episode);

  RemoteEpisode episode;
  final appliedEvents = <String>[];

  @override
  Future<void> updatePlaybackEvent(int userId, PlaybackSyncEvent event) async {
    final decision = resolvePlaybackEvent(event, episode);
    if (!decision.shouldApply) return;
    appliedEvents.add(switch (event.kind) {
      PlaybackEventKind.progress when event.positionSeconds == 120 =>
        'pause-on-device-a',
      PlaybackEventKind.seek => 'backward-seek-on-device-a',
      PlaybackEventKind.completed => 'completion-on-device-b',
      _ => event.kind.name,
    });
    episode = _remoteEpisode(
      position: event.completed ? 0 : decision.positionSeconds,
      duration: episode.durationSeconds,
      audioUrl: episode.audioUrl,
      completed: event.completed,
      updatedAt: event.occurredAt,
      deviceId: event.deviceId,
    );
  }

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async => [episode];

  @override
  Future<void> updatePlayback(
    int userId,
    int episodeId,
    Duration position,
  ) async => throw UnimplementedError();

  @override
  Future<void> markCompleted(int userId, int episodeId, bool completed) async =>
      throw UnimplementedError();

  @override
  Future<int> verifyConnection() async => 7;
  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async => const [];
  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async => const [];
  @override
  Future<List<RemotePodcast>> searchPodcasts(
    String query, {
    String provider = 'podcast_index',
  }) async => const [];
  @override
  Future<RemotePodcast> getPodcastDetails(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => podcast;
  @override
  Future<List<RemoteEpisode>> getPodcastEpisodes(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => const [];
  @override
  Future<int> subscribe(int userId, RemotePodcast podcast) async => podcast.id;
  @override
  Future<void> unsubscribe(int userId, RemotePodcast podcast) async {}
  @override
  Future<String> getChapters(int userId, int episodeId) async => '[]';
  @override
  Future<void> addToQueue(int userId, int episodeId) async {}
  @override
  Future<void> removeFromQueue(int userId, int episodeId) async {}
}
