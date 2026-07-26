# Isolate Flutter

This repository holds three packages. `IsolateHttp` and `IsolateImageCompress`
are both built on top of `IsolateFlutter`.

| Package | Version | Description |
| --- | --- | --- |
| [isolate_flutter](isolate_flutter) | 4.0.0 | Create and manage isolates |
| [isolate_http](isolate_http) | 4.0.0 | Run `http` requests in an isolate |
| [isolate_image_compress](isolate_image_compress) | 3.0.0 | Compress and resize images in an isolate |

## Requirements

Flutter `>=3.35.0`, Dart `^3.9.0`. Verified against Flutter 3.44.

## IsolateFlutter

[![Pub][isolate_flutter_pub_v_image_url]][isolate_flutter_pub_url]

[IsolateFlutter](isolate_flutter) is a useful package for you who want to make and manage Isolate. It is based on `dart:isolate` so it only support iOS and Android.

## IsolateHttp

[![Pub][isolate_http_pub_v_image_url]][isolate_http_pub_url]

[IsolateHttp](isolate_http) provides a way to launch [http package][http_pub_url] with IsolateFlutter.

## IsolateImageCompress

[![Pub][isolate_image_compress_pub_v_image_url]][isolate_image_compress_pub_url]

[IsolateImageCompress](isolate_image_compress) is a package to compress and resize the images in isolate ([IsolateFlutter][isolate_flutter_pub_url]).

## Working on this repository

`isolate_http` and `isolate_image_compress` depend on the published
`isolate_flutter`. A `pubspec_overrides.yaml` in each of them points at the local
copy instead, so the whole repository resolves against your working tree. Those
overrides are ignored by `dart pub publish`.

When releasing, publish `isolate_flutter` first — the other two depend on it.

```sh
cd isolate_flutter && flutter test
cd ../isolate_http && flutter test
cd ../isolate_image_compress && flutter test
```

## Author

IsolateFlutter is developed by Thong Dang. You can contact me at thongdn.it@gmail.com

If you like my project, you can support me [![Buy Me A Coffee][buy_me_a_coffee_image_url]][buy_me_a_coffee_url] or star (like) for it.

Thank you! ❤️

[//]: # 'reference links'
[isolate_flutter_pub_url]: https://pub.dev/packages/isolate_flutter
[isolate_flutter_pub_v_image_url]: https://img.shields.io/pub/v/isolate_flutter.svg
[isolate_http_pub_url]: https://pub.dev/packages/isolate_http
[isolate_http_pub_v_image_url]: https://img.shields.io/pub/v/isolate_http.svg
[http_pub_url]: https://pub.dev/packages/http
[isolate_image_compress_pub_url]: https://pub.dev/packages/isolate_image_compress
[isolate_image_compress_pub_v_image_url]: https://img.shields.io/pub/v/isolate_image_compress.svg
[buy_me_a_coffee_image_url]: https://buymeacoffee.com/assets/img/custom_images/orange_img.png
[buy_me_a_coffee_url]: https://buymeacoffee.com/thongdn
