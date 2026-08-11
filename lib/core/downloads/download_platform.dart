import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract interface class StorageSpaceProbe {
  Future<int?> availableBytes();
}

class DeviceStorageSpaceProbe implements StorageSpaceProbe {
  const DeviceStorageSpaceProbe();

  static const _channel = MethodChannel('app.podpine.podpine/storage');

  @override
  Future<int?> availableBytes() async {
    if (kIsWeb) return null;
    try {
      return await _channel.invokeMethod<int>('availableBytes');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
