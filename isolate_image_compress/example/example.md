```dart
import 'package:isolate_image_compress/isolate_image_compress.dart';
```

*** The `image` package (4.x) declares its own `ImageFormat`, which collides
with the one exported here. If you import both libraries, hide one of them:

```dart
import 'package:image/image.dart' hide ImageFormat;
```

## Compress

- Compress with file path

```dart
Future<void> compressImage(String path) async {
    final _image = IsolateImage.path(path);
    print('isolate_image_compress begin - : ${_image.data?.length}');
    final _data = await _image.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data?.length}');
}
```

- Compress with file data (Uint8List)

```dart
Future<void> compressImage(Uint8List fileData) async {
    print('isolate_image_compress begin - : ${fileData.length}');
    final _data = await fileData.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data?.length}');
}
```

## Resize

```dart
void resizeImage(String path) {
    final _image = IsolateImage.path(path);
    final _resized = _image.resizeWithResolution(ImageResolution.fhd);
    print('isolate_image_compress resized - : ${_resized?.width}');
}
```
