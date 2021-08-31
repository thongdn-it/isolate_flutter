import 'package:http/http.dart';

import 'package:isolate_flutter/isolate_flutter.dart';

import 'package:isolate_http/src/http_file.dart';
import 'package:isolate_http/src/http_method.dart';
import 'package:isolate_http/src/isolate_http_request.dart';
import 'package:isolate_http/src/isolate_http_response.dart';

/// Isolate Http
///
/// [head], [get], [post], [put], [delete], [send]
class IsolateHttp {
  const IsolateHttp();

  /// Sends an HTTP HEAD request with the given headers to the given URL.
  Future<IsolateHttpResponse> head(String url,
      {Map<String, String> query, Map<String, String> headers}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.head, query: query, headers: headers);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP GET request with the given headers to the given URL.
  Future<IsolateHttpResponse> get(String url,
      {Map<String, String> query, Map<String, String> headers}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.get, query: query, headers: headers);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP POST request with the given headers and body to the given URL.
  Future<IsolateHttpResponse> post(String url,
      {Map<String, String> query,
      Map<String, String> headers,
      Map<String, dynamic> body,
      List<HttpFile> files}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.post,
        query: query,
        headers: headers,
        body: body,
        files: files);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP PUT request with the given headers and body to the given URL.
  Future<IsolateHttpResponse> put(String url,
      {Map<String, String> query,
      Map<String, String> headers,
      Map<String, dynamic> body,
      List<HttpFile> files}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.put,
        query: query,
        headers: headers,
        body: body,
        files: files);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP DELETE request with the given headers to the given URL.
  Future<IsolateHttpResponse> delete(String url,
      {Map<String, String> query,
      Map<String, String> headers,
      Map<String, dynamic> body}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.delete, query: query, headers: headers, body: body);
    return send(_isolateHttpRequest);
  }

  /// Sends an [IsolateHttpRequest] and returns the [IsolateHttpResponse].
  Future<IsolateHttpResponse> send(IsolateHttpRequest request) async {
    final _isolateHttpResponse =
        await IsolateFlutter.createAndStart(_call, request);
    return _isolateHttpResponse;
  }
}

Future<IsolateHttpResponse> _call(IsolateHttpRequest isolateHttpRequest) async {
  final _request = await isolateHttpRequest.toRequest();
  if (_request != null) {
    final streamedResponse = await _request.send();
    final httpResponse = await Response.fromStream(streamedResponse);
    final _isolateHttpResponse = IsolateHttpResponse(
        httpResponse.body, httpResponse.statusCode, httpResponse.headers);
    return _isolateHttpResponse;
  }
  return null;
}
