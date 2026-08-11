import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

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

  @override
  Future<String> downloadsDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/episode_downloads');
    await directory.create(recursive: true);
    return directory.path;
  }

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<int> length(String path) => File(path).length();

  @override
  Future<DownloadByteSink> open(String path, {required bool append}) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    return _IoDownloadByteSink(
      file.openWrite(mode: append ? FileMode.append : FileMode.write),
    );
  }

  @override
  Future<void> move(String from, String to) async {
    final target = File(to);
    if (await target.exists()) await target.delete();
    await File(from).rename(to);
  }

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

class _IoDownloadByteSink implements DownloadByteSink {
  _IoDownloadByteSink(this._sink);

  final IOSink _sink;

  @override
  void add(Uint8List bytes) => _sink.add(bytes);

  @override
  Future<void> flush() => _sink.flush();

  @override
  Future<void> close() => _sink.close();
}
