import 'dart:async';

import 'package:http/http.dart';

import 'package:isolate_flutter/isolate_flutter.dart';

import 'log_utils.dart';
import 'http_file.dart';
import 'http_method.dart';
import 'isolate_http_request.dart';
import 'isolate_http_response.dart';

/// Isolate Http
///
/// [head], [get], [post], [put], [delete], [send]
class IsolateHttp {
  final Duration? _timeout;
  final String? _debugLabel;

  Function(String)? _logCurlListener;
  set listener(Function(String)? listener) {
    _logCurlListener = listener;
  }

  void _logCurl(IsolateHttpRequest isolateRequest) async {
    if (_logCurlListener != null) {
      final _request = await isolateRequest.toRequest();
      if (_request != null) {
        final _curl = LogUtils.getCurl(_request);
        _logCurlListener!(_curl);
      } else {
        throw ArgumentError('request is null.');
      }
    }
  }

  /// Create an IsolateHttp
  ///
  /// [timeout] time limit for an request.
  /// If this request does not complete before [timeout] has passed,
  /// Its returns you an IsolateHttpResponse with status code 408 (Request Timeout).
  ///
  /// [debugLabel] this name in debuggers and logging for IsolateHttp.
  IsolateHttp({Duration? timeout, String? debugLabel})
      : _timeout = timeout,
        _debugLabel = debugLabel;

  /// Sends an HTTP HEAD request with the given headers to the given URL.
  Future<IsolateHttpResponse?> head(String url,
      {Map<String, String>? query, Map<String, String>? headers}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.head, query: query, headers: headers);
    _logCurl(_isolateHttpRequest);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP GET request with the given headers to the given URL.
  Future<IsolateHttpResponse?> get(String url,
      {Map<String, String>? query, Map<String, String>? headers}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.get, query: query, headers: headers);
    _logCurl(_isolateHttpRequest);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP POST request with the given headers and body to the given URL.
  Future<IsolateHttpResponse?> post(String url,
      {Map<String, String>? query,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
      List<HttpFile>? files}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.post,
        query: query,
        headers: headers,
        body: body,
        files: files);
    _logCurl(_isolateHttpRequest);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP PUT request with the given headers and body to the given URL.
  Future<IsolateHttpResponse?> put(String url,
      {Map<String, String>? query,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
      List<HttpFile>? files}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.put,
        query: query,
        headers: headers,
        body: body,
        files: files);
    _logCurl(_isolateHttpRequest);
    return send(_isolateHttpRequest);
  }

  /// Sends an HTTP DELETE request with the given headers to the given URL.
  Future<IsolateHttpResponse?> delete(String url,
      {Map<String, String>? query,
      Map<String, String>? headers,
      Map<String, dynamic>? body}) async {
    final _isolateHttpRequest = IsolateHttpRequest(url,
        method: HttpMethod.delete, query: query, headers: headers, body: body);
    _logCurl(_isolateHttpRequest);
    return send(_isolateHttpRequest);
  }

  /// Sends an [IsolateHttpRequest] and returns the [IsolateHttpResponse].
  Future<IsolateHttpResponse?> send(IsolateHttpRequest request) async {
    try {
      final _isolateRequest = IsolateFlutter.createAndStart(_call, request,
          debugLabel: _debugLabel);

      if (_timeout == null) {
        return await _isolateRequest;
      } else {
        return await _isolateRequest.timeout(_timeout!);
      }
    } on TimeoutException catch (e) {
      return IsolateHttpResponse(e.toString(), 408, request.headers ?? {});
    } on Exception catch (e) {
      return IsolateHttpResponse(e.toString(), 520, request.headers ?? {});
    }
  }
}

Future<IsolateHttpResponse?> _call(
    IsolateHttpRequest isolateHttpRequest) async {
  final _request = await isolateHttpRequest.toRequest();
  if (_request != null) {
    final streamedResponse = await _request.send();
    final httpResponse = await Response.fromStream(streamedResponse);
    final _isolateHttpResponse = IsolateHttpResponse(
        httpResponse.body, httpResponse.statusCode, httpResponse.headers,
        request: isolateHttpRequest, contentLength: httpResponse.contentLength);
    return _isolateHttpResponse;
  }
  return null;
}
