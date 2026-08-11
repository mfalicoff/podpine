import 'dart:typed_data';

abstract interface class DownloadByteSink {
  void add(Uint8List bytes);
  Future<void> flush();
  Future<void> close();
}

abstract interface class DownloadFileStore {
  Future<String> downloadsDirectory();
  Future<bool> exists(String path);
  Future<int> length(String path);
  Future<DownloadByteSink> open(String path, {required bool append});
  Future<void> move(String from, String to);
  Future<void> delete(String path);
}

class DeviceDownloadFileStore implements DownloadFileStore {
  const DeviceDownloadFileStore();

  Never _unsupported() =>
      throw UnsupportedError('Episode downloads are unavailable on web.');

  @override
  Future<String> downloadsDirectory() async => _unsupported();

  @override
  Future<void> delete(String path) async => _unsupported();

  @override
  Future<bool> exists(String path) async => _unsupported();

  @override
  Future<int> length(String path) async => _unsupported();

  @override
  Future<void> move(String from, String to) async => _unsupported();

  @override
  Future<DownloadByteSink> open(String path, {required bool append}) async =>
      _unsupported();
}
