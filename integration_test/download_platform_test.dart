import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:podpine/core/downloads/download_file_store.dart';
import 'package:podpine/core/downloads/download_platform.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mobile download storage is writable and reports capacity', (
    tester,
  ) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final directory = await const DeviceDownloadFileStore()
        .downloadsDirectory();
    final available = await const DeviceStorageSpaceProbe().availableBytes();

    expect(Directory(directory).existsSync(), isTrue);
    expect(available, isNotNull);
    expect(available, greaterThan(0));
  });
}
