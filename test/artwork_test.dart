import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/features/shared/artwork.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ImageCache imageCache;
  late ui.Image testImage;
  late int originalMaximumSize;
  late int originalMaximumSizeBytes;

  setUp(() async {
    imageCache = PaintingBinding.instance.imageCache;
    originalMaximumSize = imageCache.maximumSize;
    originalMaximumSizeBytes = imageCache.maximumSizeBytes;
    imageCache
      ..clear()
      ..clearLiveImages();
    testImage = await createTestImage(width: 10, height: 10, cache: false);
  });

  tearDown(() {
    imageCache
      ..maximumSize = originalMaximumSize
      ..maximumSizeBytes = originalMaximumSizeBytes
      ..clear()
      ..clearLiveImages();
    testImage.dispose();
  });

  testWidgets('shows the artwork placeholder while a cold image loads', (
    tester,
  ) async {
    final provider = _ControlledImageProvider(testImage);

    await tester.pumpWidget(_artwork(provider: provider, size: 24));

    expect(find.text('P'), findsOneWidget);
    expect(provider.loadCount, 1);

    provider.complete();
    await tester.pumpAndSettle();

    expect(find.text('P'), findsNothing);
  });

  testWidgets('keeps resized artwork cached across widget disposal', (
    tester,
  ) async {
    imageCache.maximumSizeBytes = 2048;
    final provider = _ControlledImageProvider(testImage)..complete();

    await tester.pumpWidget(_artwork(provider: provider, size: 10));
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    final resizedProvider = image.image as ResizeImage;
    expect(resizedProvider.width, 10);
    expect(resizedProvider.height, 10);
    expect(find.text('P'), findsNothing);
    expect(provider.loadCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(_artwork(provider: provider, size: 10));

    expect(find.text('P'), findsNothing);
    expect(provider.loadCount, 1);
  });
}

Widget _artwork({
  required ImageProvider<Object> provider,
  required double size,
}) => MediaQuery(
  data: const MediaQueryData(devicePixelRatio: 1),
  child: MaterialApp(
    home: Scaffold(
      body: Artwork(
        id: 1,
        title: 'Podcast',
        imageProvider: provider,
        size: size,
      ),
    ),
  ),
);

class _ControlledImageProvider extends ImageProvider<_ControlledImageProvider> {
  _ControlledImageProvider(this.image);

  final ui.Image image;
  final Completer<void> _ready = Completer<void>();
  int loadCount = 0;

  void complete() {
    if (!_ready.isCompleted) _ready.complete();
  }

  @override
  Future<_ControlledImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) => SynchronousFuture<_ControlledImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    _ControlledImageProvider key,
    ImageDecoderCallback decode,
  ) {
    loadCount += 1;
    return OneFrameImageStreamCompleter(
      _ready.future.then((_) => ImageInfo(image: image.clone())),
    );
  }
}
