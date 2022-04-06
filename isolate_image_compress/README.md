# IsolateImageCompress

[![Pub][pub_v_image_url]][pub_url]

IsolateImageCompress is a package to compress and resize the images in isolate ([IsolateFlutter][isolate_flutter_pub_url]).

## Usage

### Compress

- Compress with file path

```dart
void compressImage(String path) async {
    final _image = IsolateImage.path(path);
    print('isolate_image_compress begin - : ${_image.data.length}');
    final _data = await _image.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data.length}');
}
```

- Compress with file data (`Uint8List` or `List<int>`)

```dart
void compressImage(Uint8List fileData) async {
    print('isolate_image_compress begin - : ${fileData.length}');
    final _data =  fileData.compress(maxSize: 1 * 1024 * 1024); // 1 MB
    print('isolate_image_compress end - : ${_data.length}');
}
```

### Resize

```dart
void resizeImage(String path) {
    final _image = IsolateImage.path(path);
    _image.resizeWithResolution(ImageResolution.fhd);
}
```

## Author

IsolateImageCompress is developed by Thong Dang. You can contact me at thongdn.it@gmail.com

If you like my project, you can support me [![Buy Me A Coffee][buy_me_a_coffee_image_url]][buy_me_a_coffee_url] or star (like) for it.

Thank you! ❤️

[//]: # 'reference links'
[isolate_flutter_pub_url]: https://pub.dev/packages/isolate_flutter
[pub_url]: https://pub.dev/packages/isolate_image_compress
[pub_v_image_url]: https://img.shields.io/pub/v/isolate_image_compress.svg
[buy_me_a_coffee_image_url]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png
[buy_me_a_coffee_url]: https://www.buymeacoffee.com/thongdn.it
