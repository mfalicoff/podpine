import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:podpine/core/backend/pinepods_backend.dart';

void main() {
  test('resolves the API key owner with get_user', () async {
    final requestedPaths = <String>[];
    final client = MockClient((request) async {
      requestedPaths.add(request.url.path);
      expect(request.headers['Api-Key'], 'test-key');
      return switch (request.url.path) {
        '/api/pinepods_check' => _json({
          'status_code': 200,
          'pinepods_instance': true,
        }),
        '/api/data/verify_key' => _json({'status': 'success'}),
        '/api/data/get_user' => _json({
          'status': 'success',
          'retrieved_id': 42,
        }),
        _ => http.Response('not found', 404),
      };
    });
    final backend = PinepodsBackend(
      serverUrl: 'https://pinepods.example',
      apiKey: 'test-key',
      client: client,
    );

    expect(await backend.verifyConnection(), 42);
    expect(requestedPaths, [
      '/api/pinepods_check',
      '/api/data/verify_key',
      '/api/data/get_user',
    ]);
    expect(requestedPaths, isNot(contains('/api/data/get_user_info')));
  });
}

http.Response _json(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: const {'content-type': 'application/json'},
);
