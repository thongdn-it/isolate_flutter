import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:isolate_http/isolate_http.dart';
import 'package:isolate_http/src/log_utils.dart';

void main() {
  group('IsolateHttpRequest.uri', () {
    test('leaves the url untouched when there is no query', () {
      final request = IsolateHttpRequest('https://example.com/product');
      expect(request.uri, Uri.parse('https://example.com/product'));
    });

    test('appends and encodes query parameters', () {
      final request = IsolateHttpRequest(
        'https://example.com/search',
        query: {'q': 'flutter isolate', 'page': '2'},
      );

      expect(request.uri?.queryParameters,
          {'q': 'flutter isolate', 'page': '2'});
    });
  });

  group('IsolateHttpRequest.toRequest', () {
    test('defaults to a JSON body when no content-type is given', () async {
      final request = IsolateHttpRequest(
        'https://example.com/product',
        method: HttpMethod.post,
        body: {'size': 'XL', 'price': 236},
      );

      final baseRequest = await request.toRequest();

      expect(baseRequest, isA<http.Request>());
      final plain = baseRequest! as http.Request;
      expect(plain.method, 'POST');
      expect(plain.headers[ContentType.contentTypeHeaderKey],
          contains(ContentType.json));
      expect(jsonDecode(plain.body), {'size': 'XL', 'price': 236});
    });

    test('encodes form fields for x-www-form-urlencoded', () async {
      final request = IsolateHttpRequest(
        'https://example.com/product',
        method: HttpMethod.post,
        headers: ContentType.x_www_form_urlencoded.toContentTypeHeader,
        body: {'size': 'XL', 'price': 236},
      );

      final plain = (await request.toRequest())! as http.Request;

      expect(plain.bodyFields, {'size': 'XL', 'price': '236'});
    });

    test('builds a MultipartRequest when files are attached', () async {
      final request = IsolateHttpRequest(
        'https://example.com/product',
        method: HttpMethod.post,
        body: {'size': 'XL'},
        files: [
          HttpFile.fromBytes('files', utf8.encode('hello'),
              filename: 'hello.txt'),
        ],
      );

      final multipart = (await request.toRequest())! as http.MultipartRequest;

      expect(multipart.fields, {'size': 'XL'});
      expect(multipart.files, hasLength(1));
      expect(multipart.files.single.field, 'files');
      expect(multipart.files.single.filename, 'hello.txt');
    });

    test('builds a MultipartRequest when the header says multipart', () async {
      final request = IsolateHttpRequest(
        'https://example.com/product',
        method: HttpMethod.post,
        headers: ContentType.formData.toContentTypeHeader,
      );

      expect(await request.toRequest(), isA<http.MultipartRequest>());
    });

    test('returns null for an unparseable url', () async {
      expect(await IsolateHttpRequest(':://nope').toRequest(), isNull);
    });
  });

  group('HttpFile', () {
    test('fromPath reads the file off disk', () async {
      final dir = await Directory.systemTemp.createTemp('isolate_http_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/upload.txt')
        ..writeAsStringSync('file body');

      final multipartFile =
          await HttpFile.fromPath('doc', file.path).toMultipartFile();

      expect(multipartFile, isNotNull);
      expect(multipartFile!.field, 'doc');
      expect(multipartFile.length, 'file body'.length);
    });

    test('fromString carries the given content type', () async {
      final multipartFile = await HttpFile.fromString('doc', 'body',
              filename: 'a.json', contentType: MediaType('application', 'json'))
          .toMultipartFile();

      expect(multipartFile!.contentType.mimeType, 'application/json');
    });
  });

  group('content-type helpers', () {
    test('toContentTypeHeader builds the header map', () {
      expect(ContentType.json.toContentTypeHeader,
          {ContentType.contentTypeHeaderKey: ContentType.json});
    });

    test('isJson / isMultipart read the header back', () {
      expect(ContentType.json.toContentTypeHeader.isJson, isTrue);
      expect(ContentType.json.toContentTypeHeader.isMultipart, isFalse);
      expect(ContentType.formData.toContentTypeHeader.isMultipart, isTrue);
      expect(<String, String>{}.contentType, isNull);
    });
  });

  group('IsolateHttpResponse', () {
    test('decodes an object body', () {
      final response = IsolateHttpResponse('{"a":1}', 200, {});
      expect(response.bodyAsMap, {'a': 1});
      expect(() => response.bodyAsList, throwsArgumentError);
    });

    test('decodes a list body', () {
      final response = IsolateHttpResponse('[1,2]', 200, {});
      expect(response.bodyAsList, [1, 2]);
      expect(() => response.bodyAsMap, throwsArgumentError);
    });
  });

  group('LogUtils.getCurl', () {
    test('renders a GET with headers', () async {
      final request = IsolateHttpRequest(
        'https://example.com/product',
        headers: {'Authorization': 'abc='},
      );

      final curl = LogUtils.getCurl((await request.toRequest())!);

      expect(curl, contains('curl -i'));
      expect(curl, isNot(contains('-X GET')));
      expect(curl, contains('-H "Authorization: abc="'));
      expect(curl, contains('"https://example.com/product"'));
    });

    test('renders a POST with a body and files', () async {
      final request = IsolateHttpRequest(
        'https://example.com/product',
        method: HttpMethod.post,
        body: {'size': 'XL'},
        files: [HttpFile.fromBytes('files', utf8.encode('x'),
            filename: 'image_1.png')],
      );

      final curl = LogUtils.getCurl((await request.toRequest())!);

      expect(curl, contains('-X POST'));
      expect(curl, contains(r'-F files=@/path/to/image_1.png'));
    });
  });

  group('IsolateHttp', () {
    late HttpServer server;
    late String origin;
    final requests = <String>[];

    setUp(() async {
      requests.clear();
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      origin = 'http://${server.address.address}:${server.port}';
      server.listen((request) async {
        final body = await utf8.decoder.bind(request).join();
        requests.add('${request.method} ${request.uri} $body');

        if (request.uri.path == '/slow') {
          // Long enough to blow any test timeout, but the forced close in
          // tearDown tears the connection down as soon as the test is over.
          await Future<void>.delayed(const Duration(seconds: 30));
        }

        request.response
          ..statusCode = 200
          ..headers.set(ContentType.contentTypeHeaderKey, ContentType.json)
          ..write(jsonEncode({'path': request.uri.path, 'echo': body}));
        await request.response.close();
      });
    });

    tearDown(() => server.close(force: true));

    test('performs a GET round trip through an isolate', () async {
      final response = await IsolateHttp(debugLabel: 'get_test').get(
        '$origin/product',
        query: {'q': 'flutter'},
        headers: {'Authorization': 'abc='},
      );

      expect(response?.statusCode, 200);
      expect(response?.bodyAsMap['path'], '/product');
      expect(requests.single, contains('GET /product?q=flutter'));
    });

    test('performs a POST round trip with a JSON body', () async {
      final response = await IsolateHttp(debugLabel: 'post_test').post(
        '$origin/product',
        body: {'size': 'XL', 'price': 236},
      );

      expect(response?.statusCode, 200);
      expect(
        jsonDecode(response!.bodyAsMap['echo'] as String),
        {'size': 'XL', 'price': 236},
      );
    });

    test('uploads a file as multipart', () async {
      final response = await IsolateHttp(debugLabel: 'upload_test').post(
        '$origin/upload',
        body: {'size': 'XL'},
        files: [
          HttpFile.fromBytes('files', utf8.encode('image-bytes'),
              filename: 'image_1.png'),
        ],
      );

      expect(response?.statusCode, 200);
      expect(requests.single, contains('image-bytes'));
      expect(requests.single, contains('filename="image_1.png"'));
    });

    test('the curl listener reports the request that was sent', () async {
      final isolateHttp = IsolateHttp(debugLabel: 'curl_test');
      final curls = <String>[];
      isolateHttp.listener = curls.add;

      await isolateHttp.get('$origin/product');
      await pumpEventQueue();

      expect(curls.single, contains('"$origin/product"'));
    });

    test('returns a 408 response when the request times out', () async {
      final isolateHttp = IsolateHttp(
        timeout: const Duration(milliseconds: 50),
        debugLabel: 'timeout_test',
      );

      final response = await isolateHttp.get('$origin/slow');

      expect(response?.statusCode, 408);
      expect(response?.body, contains('TimeoutException'));
    });

    // `send()` stops the isolate it spawned once it has returned (see the
    // `finally` in IsolateHttp.send). That is not observable from here — a
    // killed isolate does not release its socket promptly — so the isolate
    // teardown itself is covered by isolate_flutter's `stop()` tests.
  });
}
