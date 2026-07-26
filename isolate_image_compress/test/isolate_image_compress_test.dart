import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
// This package exports its own `ImageFormat`, which collides with the one
// `image` 4.x added. A prefix (as here) or `hide ImageFormat` resolves it.
import 'package:image/image.dart' as img;
import 'package:isolate_image_compress/isolate_image_compress.dart';

/// Noise compresses badly, which is what makes it a useful JPEG fixture: the
/// encoder actually has to drop quality to get under the limit.
Uint8List _noisyJpeg({int width = 600, int height = 400}) {
  final image = img.Image(width: width, height: height);
  var seed = 1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      image.setPixelRgb(
          x, y, seed & 0xff, (seed >> 8) & 0xff, (seed >> 16) & 0xff);
    }
  }
  return img.encodeJpg(image, quality: 100);
}

/// A smooth gradient, so PNG's own compression levels make a real difference.
Uint8List _gradientPng({int width = 400, int height = 300}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgb(x, y, x % 256, y % 256, (x + y) % 256);
    }
  }
  return img.encodePng(image, level: 0);
}

void main() {
  group('ImageResolution', () {
    test('prev() walks down the ladder and stops at the smallest', () {
      expect(ImageResolution.uhd.prev(), ImageResolution.qhd);
      expect(ImageResolution.qhd.prev(), ImageResolution.fhd);
      expect(ImageResolution.sd.prev(), isNull);
    });

    test('next() walks up the ladder and stops at the largest', () {
      expect(ImageResolution.sd.next(), ImageResolution.hd);
      expect(ImageResolution.fuhd.next(), isNull);
    });
  });

  group('resizeWithResolution', () {
    test('scales a landscape image down to the target width', () {
      final image = img.Image(width: 2000, height: 1000);

      final resized = image.resizeWithResolution(ImageResolution.hd);

      expect(resized.width, 1280);
      expect(resized.height, 640);
    });

    test('scales a portrait image down to the target height', () {
      final image = img.Image(width: 1000, height: 2000);

      final resized = image.resizeWithResolution(ImageResolution.hd);

      expect(resized.height, 720);
    });

    test('leaves an image that already fits untouched', () {
      final image = img.Image(width: 100, height: 100);

      expect(identical(image.resizeWithResolution(ImageResolution.uhd), image),
          isTrue);
    });

    test('decodes and resizes an IsolateImage', () {
      final isolateImage = IsolateImage.data(_gradientPng());

      final resized =
          isolateImage.resizeWithResolution(const ImageResolution(200, 150));

      expect(resized, isNotNull);
      expect(resized!.width, 200);
    });
  });

  group('IsolateImage', () {
    test('data() reads the bytes lazily from disk for a path', () async {
      final dir = await Directory.systemTemp.createTemp('isolate_image_test');
      addTearDown(() => dir.delete(recursive: true));
      final bytes = _gradientPng();
      final file = File('${dir.path}/gradient.png')..writeAsBytesSync(bytes);

      final isolateImage = IsolateImage.path(file.path);

      expect(isolateImage.fromType, ImageFromType.path);
      expect(isolateImage.data, bytes);
    });

    test('reports the source type for raw data', () {
      expect(IsolateImage.data(_gradientPng()).fromType, ImageFromType.file);
    });
  });

  group('compress', () {
    test('returns the data untouched when it is already small enough',
        () async {
      final data = _gradientPng();

      final result = await data.compress(maxSize: data.length + 1);

      expect(result, data);
    });

    test('returns the data untouched when no maxSize is given', () async {
      final data = _gradientPng();

      expect(await data.compress(), data);
    });

    test('compresses a JPEG below maxSize', () async {
      final data = _noisyJpeg();
      const maxSize = 60 * 1024;
      expect(data.length, greaterThan(maxSize),
          reason: 'fixture must actually need compressing');

      final result = await data.compress(maxSize: maxSize);

      expect(result, isNotNull);
      expect(result!, isNotEmpty);
      expect(result.length, lessThan(maxSize));
      expect(img.decodeJpg(result), isNotNull);
    });

    test('compresses a PNG below maxSize', () async {
      final data = _gradientPng();
      const maxSize = 50 * 1024;
      expect(data.length, greaterThan(maxSize),
          reason: 'fixture must actually need compressing');

      final result = await data.compress(maxSize: maxSize);

      expect(result, isNotNull);
      expect(result!, isNotEmpty);
      expect(result.length, lessThan(maxSize));
      expect(img.decodePng(result), isNotNull);
    });

    test('honours an explicitly supplied format', () async {
      final data = _noisyJpeg();
      const maxSize = 60 * 1024;

      final result =
          await data.compress(maxSize: maxSize, format: ImageFormat.jpeg);

      expect(result!, isNotEmpty);
      expect(result.length, lessThan(maxSize));
    });

    test('compresses from a List<int>', () async {
      final data = _noisyJpeg();
      const maxSize = 60 * 1024;

      final result = await data.toList().compress(maxSize: maxSize);

      expect(result!, isNotEmpty);
      expect(result.length, lessThan(maxSize));
    });

    test('compresses an IsolateImage backed by a file path', () async {
      final dir = await Directory.systemTemp.createTemp('isolate_image_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/noise.jpg')
        ..writeAsBytesSync(_noisyJpeg());
      const maxSize = 60 * 1024;

      final result = await IsolateImage.path(file.path).compress(
        maxSize: maxSize,
      );

      expect(result!, isNotEmpty);
      expect(result.length, lessThan(maxSize));
    });
  });
}
