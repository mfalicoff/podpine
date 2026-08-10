import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredSession {
  const StoredSession({
    required this.serverUrl,
    required this.apiKey,
    required this.userId,
  });
  final String serverUrl;
  final String apiKey;
  final int userId;
}

class CredentialStore {
  const CredentialStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _serverKey = 'pinepods_server';
  static const _apiKey = 'pinepods_api_key';
  static const _userKey = 'pinepods_user_id';

  Future<StoredSession?> read() async {
    final values = await _storage.readAll();
    final server = values[_serverKey];
    final apiKey = values[_apiKey];
    final userId = int.tryParse(values[_userKey] ?? '');
    if (server == null || apiKey == null || userId == null) return null;
    return StoredSession(serverUrl: server, apiKey: apiKey, userId: userId);
  }

  Future<void> write(StoredSession session) async {
    await _storage.write(key: _serverKey, value: session.serverUrl);
    await _storage.write(key: _apiKey, value: session.apiKey);
    await _storage.write(key: _userKey, value: '${session.userId}');
  }

  Future<void> clear() => _storage.deleteAll();
}
