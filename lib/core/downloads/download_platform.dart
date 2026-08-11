import 'package:connectivity_plus/connectivity_plus.dart';
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
    } catch (_) {
      return null;
    }
  }
}

abstract interface class DownloadNetworkProbe {
  Future<List<ConnectivityResult>> current();
}

class DeviceDownloadNetworkProbe implements DownloadNetworkProbe {
  const DeviceDownloadNetworkProbe();

  @override
  Future<List<ConnectivityResult>> current() async {
    try {
      return await Connectivity().checkConnectivity();
    } catch (_) {
      return const [ConnectivityResult.other];
    }
  }
}

abstract interface class ChargingStateProbe {
  Future<bool?> isCharging();
}

class DeviceChargingStateProbe implements ChargingStateProbe {
  const DeviceChargingStateProbe();

  static const _channel = MethodChannel('app.podpine.podpine/storage');

  @override
  Future<bool?> isCharging() async {
    if (kIsWeb) return null;
    try {
      return await _channel.invokeMethod<bool>('isCharging');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
