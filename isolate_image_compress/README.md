# IsolateImageCompress

[![Pub][pub_v_image_url]][pub_url]

IsolateImageCompress is a package to compress and resize the images in isolate ([IsolateFlutter][isolate_flutter_pub_url]).

Supported formats: JPEG, PNG, GIF and TGA.

## Requirements

Flutter `>=3.35.0`, Dart `^3.9.0`. Verified against Flutter 3.44.

## Installation

```yaml
dependencies:
  isolate_image_compress: ^3.0.0
```

```dart
import 'package:isolate_image_compress/isolate_image_compress.dart';
```

\*\*\* The [image][image_pub_url] package (4.x) declares its own `ImageFormat`,
which collides with the one exported here. If you import both libraries, hide
one of them, or use a prefix:

```dart
import 'package:image/image.dart' hide ImageFormat;
```

## Usage

### Compress

- Compress with file path

```dart
Future<void> compressImage(String path) async {
    final _image = IsolateImage.path(path);
    print('isolate_image_compress begin - : ${_image.data?.length}');
    final _data = await _image.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data?.length}');
}
```

- Compress with file data (`Uint8List` or `List<int>`)

```dart
Future<void> compressImage(Uint8List fileData) async {
    print('isolate_image_compress begin - : ${fileData.length}');
    final _data = await fileData.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data?.length}');
}
```

Both return `null` if the isolate could not be created, the data unchanged if it
is already under `maxSize` (or if `maxSize` is omitted), and an empty `Uint8List`
if the image could not be brought under `maxSize`.

#### Options

| Option | Description |
| --- | --- |
| `maxSize` | Compressed file size limit, in bytes. Without it nothing is compressed. |
| `maxResolution` / `resolution` | Largest resolution to keep. Defaults to `ImageResolution.uhd`. |
| `format` | Force a decoder instead of detecting it from the data. |

\*\*\* The resolution argument is named `maxResolution` on `IsolateImage` but
`resolution` on the `Uint8List` and `List<int>` extensions.

```dart
final _data = await fileData.compress(
    maxSize: 1 * 1024 * 1024,
    resolution: ImageResolution.fhd,
    format: ImageFormat.jpeg);
```

JPEG is compressed by lowering quality, PNG by raising the compression level. If
the image still does not fit, the resolution steps down (`uhd` → `qhd` → `fhd` →
`hd` → `sd`) and it tries again.

### Resize

```dart
void resizeImage(String path) {
    final _image = IsolateImage.path(path);
    final _resized = _image.resizeWithResolution(ImageResolution.fhd);
    print('isolate_image_compress resized - : ${_resized?.width}');
}
```

Resizing keeps the aspect ratio and never scales an image up: an image that
already fits inside the resolution is returned unchanged.

### ImageResolution

`sd` (640x480), `hd` (1280x720), `fhd` (1920x1080), `qhd` (2560x1440),
`uhd` (3840x2160), `fuhd` (7680x4320). Use `prev()` and `next()` to walk the
ladder, or build your own with `ImageResolution(width, height)`.

## Author

IsolateImageCompress is developed by Thong Dang. You can contact me at thongdn.it@gmail.com

If you like my project, you can support me [![Buy Me A Coffee][buy_me_a_coffee_image_url]][buy_me_a_coffee_url] or star (like) for it.

Thank you! ❤️

[//]: # 'reference links'
[isolate_flutter_pub_url]: https://pub.dev/packages/isolate_flutter
[image_pub_url]: https://pub.dev/packages/image
[pub_url]: https://pub.dev/packages/isolate_image_compress
[pub_v_image_url]: https://img.shields.io/pub/v/isolate_image_compress.svg
[buy_me_a_coffee_image_url]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png
[buy_me_a_coffee_url]: https://www.buymeacoffee.com/thongdn.it
