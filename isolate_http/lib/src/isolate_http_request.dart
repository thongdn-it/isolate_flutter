import 'dart:convert';

import 'package:http/http.dart';

import 'content_type.dart';
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
  // final Map<String, dynamic>? body;
  final Object? body;

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
      // Form data
      if (files?.isNotEmpty == true || headers?.isMultipart == true) {
        MultipartRequest _request = MultipartRequest(method, _uri);
        if (headers?.isNotEmpty == true) {
          _request.headers.addAll(headers!);
        }

        if (body != null) {
          Map<String, dynamic> _fields = {};

          if (body is Map<String, dynamic>) {
            _fields = body as Map<String, dynamic>;
          } else {
            try {
              final _jsonData = jsonDecode(body.toString());
              if (_jsonData is Map<String, dynamic>) {
                _fields = _jsonData;
              }
            } catch (e) {
              // err
            }
          }

          _fields.forEach((key, value) {
            _request.fields[key] = value.toString();
          });
        }

        if (files != null) {
          for (var file in files!) {
            final _file = await file.toMultipartFile();
            if (_file != null) {
              _request.files.add(_file);
            }
          }
        }
        return _request;
      } else {
        // Other
        Request _request = Request(method, _uri);
        if (headers?.isNotEmpty == true) {
          _request.headers.addAll(headers!);
        }
        if (body != null) {
          String? _contentType = _request.headers.contentType;
          if (_contentType?.isNotEmpty != true) {
            // set request default content-type as json.
            _request.headers[ContentType.contentTypeHeaderKey] =
                ContentType.json;
          }

          if (_contentType?.contains(ContentType.x_www_form_urlencoded) ==
              true) {
            Map<String, String> _bodyFields = {};
            if (body is Map<String, dynamic>) {
              (body as Map<String, dynamic>).forEach((key, value) {
                _bodyFields[key] = value.toString();
              });
            } else {
              final _jsonData = jsonDecode(body.toString());
              if (_jsonData is Map<String, dynamic>) {
                _jsonData.forEach((key, value) {
                  _bodyFields[key] = value.toString();
                });
              }
            }
            _request.bodyFields = _bodyFields;
          } else {
            if (_request.headers.isJson == true) {
              _request.body = jsonEncode(body);
            } else {
              _request.body = body.toString();
            }
          }
        }
        return _request;
      }
    }
    return null;
  }
}
