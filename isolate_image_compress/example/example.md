```dart
import 'package:isolate_image_compress/isolate_image_compress.dart';
```

## Compress

- Compress with file path

```dart
void compressImage(String path) async {
    final _image = IsolateImage.path(path);
    print('isolate_image_compress begin - : ${_image.data.length}');
    final _data = await _image.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data.length}');
}
```

- Compress with file data (Uint8List)

```dart
void compressImage(Uint8List fileData) async {
    print('isolate_image_compress begin - : ${fileData.length}');
    final _data =  fileData.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data.length}');
}
```

## Resize

```dart
void resizeImage(String path) {
    final _image = IsolateImage.path(path);
    _image.resizeWithResolution(ImageResolution.fhd);
}
```
