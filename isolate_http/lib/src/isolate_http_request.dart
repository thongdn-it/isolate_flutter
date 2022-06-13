import 'dart:convert';

import 'package:http/http.dart';

import 'http_file.dart';
import 'http_method.dart';

/// The request using for Isolate Http.
class IsolateHttpRequest {
  /// The url to which the request will be sent.
  final String url;

  /// The [HttpMethod] of the request.
  ///
  /// Most commonly "GET" or "POST", less commonly "HEAD", "PUT", or "DELETE".
  /// Non-standard method names are also supported.
  final String method;

  /// List [queryParameters] in [http]
  final Map<String, String>? query;

  /// The headers of the request.
  final Map<String, String>? headers;

  /// The body of the request.
  final Map<String, dynamic>? body;

  /// List of files to be uploaded of the request.
  final List<HttpFile>? files;

  /// The size of the request body, in bytes.
  ///
  /// This defaults to `null`, which indicates that the size of the request is
  /// not known in advance. May not be assigned a negative value.
  int? get contentLength => _contentLength;
  int? _contentLength;

  set contentLength(int? value) {
    if (value != null && value < 0) {
      throw ArgumentError('Invalid content length $value.');
    }
    _contentLength = value;
  }

  /// The request using for Isolate Http.
  ///
  /// [url] The url to which the request will be sent.
  ///
  /// [method] The [HttpMethod] of the request.
  ///
  /// [query] List [queryParameters] in [http]
  ///
  /// [headers] The headers of the request.
  ///
  /// [body] The body of the request.
  ///
  /// [files] List of files (HttpFile) to be uploaded of the request.
  IsolateHttpRequest(this.url,
      {this.method = HttpMethod.get,
      this.query,
      this.headers,
      this.body,
      this.files});

  /// Convert [url] and [query] to full link request (Uri)
  Uri? get uri {
    String _requestUrl = url;
    if (query?.isNotEmpty == true) {
      final _queryString = Uri(queryParameters: query).query;
      _requestUrl += '?$_queryString';
    }
    return Uri.tryParse(_requestUrl);
  }

  /// Convert [IsolateHttpRequest] to [BaseRequest] (The base class for HTTP requests).
  Future<BaseRequest?> toRequest() async {
    final _uri = uri;
    if (_uri != null) {
      if (files?.isNotEmpty == true) {
        MultipartRequest _request = MultipartRequest(method, _uri);
        if (headers?.isNotEmpty == true) {
          _request.headers.addAll(headers!);
        }

        body?.forEach((key, value) {
          _request.fields[key] = jsonEncode(value);
        });

        for (var file in files!) {
          final _file = await file.toMultipartFile();
          if (_file != null) {
            _request.files.add(_file);
          }
        }
        return _request;
      } else {
        Request _request = Request(method, _uri);
        if (headers?.isNotEmpty == true) {
          _request.headers.addAll(headers!);
        }
        if (body?.isNotEmpty == true) {
          _request.body = jsonEncode(body);
          _request.headers['content-type'] = 'application/json';
        }
        return _request;
      }
    }
    return null;
  }
}
