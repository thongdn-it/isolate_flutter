# IsolateHttp

[![Pub][pub_v_image_url]][pub_url]

IsolateHttp provides a way to launch [http package][http_pub_url] with [IsolateFlutter][isolate_flutter_pub_url].

## Usage

Performing a `GET` request:

```dart
final _isolateHttp = IsolateHttp();
```

```dart
final _response = await _isolateHttp.get('https://example.com/product',
    headers: {'Authorization': 'abc='});
print(_response);
```

Performing a `POST` request:

```dart
final _response = await _isolateHttp.post('https://example.com/product',
    headers: {'Authorization': 'abc='},
    body: {'size': 'XL', 'price': 236},
    files: [
        HttpFile.fromPath('files', 'path/image_1.png')
    ]);
print(_response);
```

Performing a `DELETE` request:

```dart
final _response = await _isolateHttp.delete('https://example.com/product/1',
    headers: {'Authorization': 'abc='});
print(_response);
```

\*\*\* You can set a timeout and debug label for your request when creating an IsolateHttp like:

```dart
final _isolateHttp =  IsolateHttp(timeout: Duration(seconds: 30), debugLabel: 'get_products')
```

If timeout, its returns you an IsolateHttpResponse with status code 408 (Request Timeout).

### Log Curl

```dart
_isolateHttp.listener = (curl) {
    if (kDebugMode) {
      log('Isolate Http -> Curl: ----------------\n$curl\n----------------');
    }
  };
```

## Author

IsolateHttp is developed by Thong Dang. You can contact me at thongdn.it@gmail.com

If you like my project, you can support me [![Buy Me A Coffee][buy_me_a_coffee_image_url]][buy_me_a_coffee_url] or star (like) for it.

Thank you! ❤️

[//]: # 'reference links'
[http_pub_url]: https://pub.dev/packages/http
[isolate_flutter_pub_url]: https://pub.dev/packages/isolate_flutter
[pub_url]: https://pub.dev/packages/isolate_http
[pub_v_image_url]: https://img.shields.io/pub/v/isolate_http.svg
[buy_me_a_coffee_image_url]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png
[buy_me_a_coffee_url]: https://www.buymeacoffee.com/thongdn.it
