import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:podpine/core/backend/pinepods_backend.dart';
import 'package:podpine/core/backend/podcast_backend.dart';

void main() {
  group('Pinepods API fixture contracts', () {
    test(
      'resolves the API-key owner across casing and type variants',
      () async {
        final fixture = _fixture('identity');
        final requestedPaths = <String>[];
        final client = MockClient((request) async {
          requestedPaths.add(request.url.path);
          expect(request.headers['Api-Key'], 'test-key');
          return switch (request.url.path) {
            '/api/pinepods_check' => _json(fixture['check']),
            '/api/data/verify_key' => _json(fixture['verify']),
            '/api/data/get_user' => _json(fixture['user']),
            _ => http.Response('not found', 404),
          };
        });

        expect(await _backend(client).verifyConnection(), 42);
        expect(requestedPaths, [
          '/api/pinepods_check',
          '/api/data/verify_key',
          '/api/data/get_user',
        ]);
        expect(requestedPaths, isNot(contains('/api/data/get_user_info')));
      },
    );

    test('normalizes subscription field casing and numeric strings', () async {
      final backend = _fixtureBackend(
        '/api/data/return_pods/42',
        _fixture('subscriptions'),
      );

      final podcast = (await backend.getSubscriptions(42)).single;

      expect(podcast.id, 12);
      expect(podcast.title, 'Fixture Cast');
      expect(podcast.author, 'Podpine');
      expect(podcast.artworkUrl, 'https://example.test/podcast.png');
      expect(podcast.description, 'A fixture-backed podcast.');
      expect(podcast.feedUrl, 'https://example.test/feed.xml');
      expect(podcast.episodeCount, 7);
    });

    test(
      'normalizes episode casing, numeric types, and boolean types',
      () async {
        final backend = _fixtureBackend(
          '/api/data/return_episodes/42',
          _fixture('episodes'),
          expectedQuery: const {'limit': '500'},
        );

        final episode = (await backend.getEpisodes(42)).single;

        expect(episode.id, 101);
        expect(episode.podcastId, 12);
        expect(episode.podcastTitle, 'Fixture Cast');
        expect(episode.title, 'Types and casing');
        expect(episode.publishedAt, DateTime.utc(2026, 8, 10, 19, 30));
        expect(episode.durationSeconds, 3600);
        expect(episode.positionSeconds, 72);
        expect(episode.completed, isTrue);
        expect(episode.queued, isTrue);
        expect(episode.downloaded, isFalse);
        expect(episode.isYoutube, isFalse);
        expect(episode.queuePosition, 3);
        expect(jsonDecode(episode.chaptersJson), [
          {'startTime': 0.0, 'title': 'Opening'},
          {'startTime': 125.5, 'title': 'Main topic'},
        ]);
      },
    );

    test('normalizes queued episodes and epoch publication dates', () async {
      final backend = _fixtureBackend(
        '/api/data/get_queued_episodes',
        _fixture('queue'),
        expectedQuery: const {'user_id': '42'},
      );

      final episode = (await backend.getQueue(42)).single;

      expect(episode.id, 202);
      expect(episode.podcastId, 12);
      expect(episode.queued, isTrue);
      expect(episode.queuePosition, 1);
      expect(
        episode.publishedAt,
        DateTime.fromMillisecondsSinceEpoch(1786388400000, isUtc: true),
      );
    });

    test('fetches and normalizes Podcasting 2.0 chapters', () async {
      final backend = _fixtureBackend(
        '/api/data/fetch_podcasting_2_data',
        {
          'chapters': [
            {'startTime': 0, 'title': 'Intro'},
            {'startTime': 42.25, 'title': 'Discussion'},
          ],
          'transcripts': <Object>[],
          'people': <Object>[],
        },
        expectedQuery: const {'episode_id': '101', 'user_id': '42'},
      );

      expect(jsonDecode(await backend.getChapters(42, 101)), [
        {'startTime': 0.0, 'title': 'Intro'},
        {'startTime': 42.25, 'title': 'Discussion'},
      ]);
    });

    test(
      'sends the playback contract and accepts its fixture response',
      () async {
        late http.Request recordedRequest;
        final client = MockClient((request) async {
          recordedRequest = request;
          return _json(_fixture('playback'));
        });

        await _backend(
          client,
        ).updatePlayback(42, 101, const Duration(seconds: 9));

        expect(recordedRequest.method, 'POST');
        expect(recordedRequest.url.path, '/api/data/record_listen_duration');
        expect(recordedRequest.headers['Api-Key'], 'test-key');
        expect(jsonDecode(recordedRequest.body), {
          'episode_id': 101,
          'user_id': 42,
          'listen_duration': 9,
          'is_youtube': false,
        });
      },
    );

    test('searches through the configured Pinepods proxy provider', () async {
      late http.Request recordedRequest;
      final backend = _backend(
        MockClient((request) async {
          recordedRequest = request;
          return _json({
            'status': 'true',
            'feeds': [
              {
                'id': '88',
                'title': 'Discovery Cast',
                'url': 'https://example.test/discovery.xml',
                'link': 'https://example.test/show',
                'description': '<p>Useful &amp; safe</p>',
                'ownerName': 'Fixture Owner',
                'artwork': 'https://example.test/discovery.png',
                'categories': {'0': 'Technology'},
                'explicit': 'false',
                'episodeCount': '12',
              },
              {'id': 99, 'title': 'Malformed feed without a URL'},
            ],
          });
        }),
      );

      final results = await backend.searchPodcasts('discovery');

      expect(recordedRequest.url.path, '/api/data/proxy_search');
      expect(recordedRequest.url.queryParameters, {
        'query': 'discovery',
        'index': 'podcast_index',
      });
      expect(results, hasLength(1));
      expect(results.single.podcastIndexId, 88);
      expect(results.single.author, 'Fixture Owner');
      expect(results.single.categories, ['Technology']);
    });

    test('loads unsubscribed episodes through Pinepods feed parsing', () async {
      final backend = _fixtureBackend(
        '/api/data/fetch_podcast_feed',
        {
          'episodes': [
            {
              'title': 'Before subscribing',
              'description': '<p>Preview notes</p>',
              'pub_date': '2026-08-10T19:30:00Z',
              'enclosure_url': 'https://example.test/preview.mp3',
              'artwork': 'https://example.test/preview.png',
              'duration': 125,
            },
          ],
        },
        expectedQuery: const {
          'podcast_feed': 'https://example.test/discovery.xml',
        },
      );
      const podcast = RemotePodcast(
        id: 0,
        title: 'Discovery Cast',
        author: '',
        artworkUrl: '',
        description: '',
        feedUrl: 'https://example.test/discovery.xml',
        episodeCount: 1,
      );

      final episode = (await backend.getPodcastEpisodes(
        42,
        podcast,
        subscribed: false,
      )).single;

      expect(episode.id, isNegative);
      expect(episode.title, 'Before subscribing');
      expect(episode.audioUrl, 'https://example.test/preview.mp3');
      expect(episode.durationSeconds, 125);
      expect(episode.publishedAt, DateTime.utc(2026, 8, 10, 19, 30));
    });

    test('sends add and remove podcast mutation contracts', () async {
      final requests = <http.Request>[];
      final backend = _backend(
        MockClient((request) async {
          requests.add(request);
          return request.url.path.endsWith('add_podcast')
              ? _json({
                  'success': true,
                  'podcast_id': 314,
                  'first_episode_id': 1,
                })
              : _json({'success': true});
        }),
      );
      const podcast = RemotePodcast(
        id: 0,
        title: 'Discovery Cast',
        author: 'Fixture Owner',
        artworkUrl: 'https://example.test/art.png',
        description: 'Description',
        feedUrl: 'https://example.test/discovery.xml',
        episodeCount: 12,
        websiteUrl: 'https://example.test/show',
        categories: ['Technology'],
        explicit: true,
        podcastIndexId: 88,
      );

      expect(await backend.subscribe(42, podcast), 314);
      await backend.unsubscribe(42, podcast);

      expect(requests.map((request) => request.url.path), [
        '/api/data/add_podcast',
        '/api/data/remove_podcast',
      ]);
      expect(jsonDecode(requests.first.body), {
        'podcast_values': {
          'pod_title': 'Discovery Cast',
          'pod_artwork': 'https://example.test/art.png',
          'pod_author': 'Fixture Owner',
          'categories': {'0': 'Technology'},
          'pod_description': 'Description',
          'pod_episode_count': 12,
          'pod_feed_url': 'https://example.test/discovery.xml',
          'pod_website': 'https://example.test/show',
          'pod_explicit': true,
          'user_id': 42,
        },
        'podcast_index_id': 88,
      });
      expect(jsonDecode(requests.last.body), {
        'podcast_name': 'Discovery Cast',
        'podcast_url': 'https://example.test/discovery.xml',
        'user_id': 42,
      });
    });
  });

  group('Pinepods failure contracts', () {
    final errors = _fixture('errors');
    final statusCases = <(String, String, String)>[
      ('unauthorized', 'rejected', '401'),
      ('forbidden', 'not allowed', '403'),
      ('notFound', 'not found', '404'),
    ];

    for (final (fixtureName, messageFragment, statusText) in statusCases) {
      test('$statusText is a typed, explicit HTTP failure', () async {
        final fixture = errors[fixtureName] as Map<String, dynamic>;
        final backend = _backend(
          MockClient(
            (_) async => http.Response(
              jsonEncode(fixture['body']),
              fixture['statusCode'] as int,
              headers: const {'content-type': 'application/json'},
            ),
          ),
        );

        await expectLater(
          backend.getEpisodes(42),
          throwsA(
            isA<PinepodsException>()
                .having(
                  (error) => error.statusCode,
                  'statusCode',
                  fixture['statusCode'],
                )
                .having(
                  (error) => error.message,
                  'message',
                  contains(messageFragment),
                ),
          ),
        );
      });
    }

    test('timeout is translated to a stable Pinepods failure', () async {
      final backend = _backend(
        MockClient((_) async => throw TimeoutException('fixture timeout')),
      );

      await expectLater(
        backend.getEpisodes(42),
        throwsA(
          isA<PinepodsException>()
              .having((error) => error.statusCode, 'statusCode', isNull)
              .having(
                (error) => error.message,
                'message',
                contains('timed out'),
              ),
        ),
      );
    });

    test('malformed JSON is translated to a stable Pinepods failure', () async {
      final backend = _backend(
        MockClient(
          (_) async => http.Response(errors['malformedJson'] as String, 200),
        ),
      );

      await expectLater(
        backend.getEpisodes(42),
        throwsA(
          isA<PinepodsException>().having(
            (error) => error.message,
            'message',
            'Pinepods returned malformed JSON.',
          ),
        ),
      );
    });

    test('malformed response schemas fail instead of looking empty', () async {
      final backend = _backend(
        MockClient((_) async => _json(errors['malformedSubscriptions'])),
      );

      await expectLater(
        backend.getSubscriptions(42),
        throwsA(
          isA<PinepodsException>().having(
            (error) => error.message,
            'message',
            'Pinepods returned a malformed subscriptions response.',
          ),
        ),
      );
    });
  });
}

PinepodsBackend _backend(http.Client client) => PinepodsBackend(
  serverUrl: 'https://pinepods.example',
  apiKey: 'test-key',
  client: client,
  requestTimeout: const Duration(milliseconds: 50),
);

PinepodsBackend _fixtureBackend(
  String expectedPath,
  Object fixture, {
  Map<String, String> expectedQuery = const {},
}) => _backend(
  MockClient((request) async {
    expect(request.url.path, expectedPath);
    expect(request.url.queryParameters, expectedQuery);
    return _json(fixture);
  }),
);

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/pinepods/$name.json').readAsStringSync())
        as Map<String, dynamic>;

http.Response _json(Object? body) => http.Response(
  jsonEncode(body),
  200,
  headers: const {'content-type': 'application/json'},
);
