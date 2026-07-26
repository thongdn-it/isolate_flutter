# IsolateHttp

[![Pub][pub_v_image_url]][pub_url]

IsolateHttp provides a way to launch [http package][http_pub_url] with [IsolateFlutter][isolate_flutter_pub_url].

## Requirements

Flutter `>=3.35.0`, Dart `^3.9.0`. Verified against Flutter 3.44. Version 4.0.0
and later build on `http` 1.x.

## Installation

```yaml
dependencies:
  isolate_http: ^4.0.0
```

```dart
import 'package:isolate_http/isolate_http.dart';
```

## Usage

Performing a `GET` request:

```dart
final _isolateHttp = IsolateHttp();
```

```dart
final _response = await _isolateHttp.get('https://example.com/product',
    query: {'q': 'flutter'},
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

`head`, `get`, `post`, `put` and `delete` are available, plus `send` if you want
to build the [IsolateHttpRequest](#request) yourself.

\*\*\* You can set a timeout and debug label for your request when creating an IsolateHttp like:

```dart
final _isolateHttp =  IsolateHttp(timeout: Duration(seconds: 30), debugLabel: 'get_products')
```

If timeout, its returns you an IsolateHttpResponse with status code 408 (Request Timeout) and the isolate running the request is stopped. Other exceptions come back as status code 520.

### Request

The body is encoded from the `content-type` header:

- no `content-type` — the header is set to `application/json` and the body is JSON encoded.
- `application/x-www-form-urlencoded` — the body is sent as form fields.
- `multipart/form-data`, or any request with `files` — the body is sent as a multipart request.
- anything else — the body is sent as `body.toString()`.

```dart
final _request = IsolateHttpRequest('https://example.com/product',
    method: HttpMethod.post,
    headers: ContentType.json.toContentTypeHeader,
    body: {'size': 'XL'});
final _response = await _isolateHttp.send(_request);
```

### Response

```dart
_response?.statusCode;    // int
_response?.body;          // String
_response?.headers;       // Map<String, String>
_response?.contentLength; // int?
_response?.bodyJson;      // dynamic, decoded from body
_response?.bodyAsMap;     // Map<String, dynamic>, throws ArgumentError if not a map
_response?.bodyAsList;    // List<dynamic>, throws ArgumentError if not a list
```

### Files

```dart
HttpFile.fromPath('files', 'path/image_1.png');
HttpFile.fromBytes('files', bytes, filename: 'image_1.png');
HttpFile.fromString('files', '{"a":1}', filename: 'a.json',
    contentType: MediaType('application', 'json'));
```

`MediaType` is re-exported by this package, so you do not need to depend on
`http_parser` yourself.

### Log Curl

```dart
_isolateHttp.listener = (curl) {
    if (kDebugMode) {
      log('Isolate Http -> Curl: ----------------\n$curl\n----------------');
    }
  };
```

## Migrating from 3.x

- `http` moved from `0.13.x` to `1.x`. If you use `HttpFile.toMultipartFile()`, the
  `MultipartFile` you get back is now the one from `http` 1.x. Most code needs no
  change beyond bumping `http` in your own `pubspec.yaml`.
- Requires Flutter `>=3.35.0` / Dart `^3.9.0`.
- A request that times out no longer keeps running in the background; the isolate
  is stopped once `send()` returns.

## Author

IsolateHttp is developed by Thong Dang. You can contact me at thongdn.it@gmail.com

If you like my project, you can support me [![Buy Me A Coffee][buy_me_a_coffee_image_url]][buy_me_a_coffee_url] or star (like) for it.

Thank you! ❤️

[//]: # 'reference links'
[http_pub_url]: https://pub.dev/packages/http
[isolate_flutter_pub_url]: https://pub.dev/packages/isolate_flutter
[pub_url]: https://pub.dev/packages/isolate_http
[pub_v_image_url]: https://img.shields.io/pub/v/isolate_http.svg
[buy_me_a_coffee_image_url]: https://buymeacoffee.com/assets/img/custom_images/orange_img.png
[buy_me_a_coffee_url]: https://buymeacoffee.com/thongdn
