import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:podpine/core/backend/pinepods_backend.dart';

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
