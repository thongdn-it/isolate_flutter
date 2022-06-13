import 'dart:convert';

import 'isolate_http_request.dart';

/// The response using for Isolate Http.
class IsolateHttpResponse {
  /// The body of the response as a String.
  final String body;

  /// The headers of the response as a Map<String, String>.
  final Map<String, String> headers;

  /// The status code of the response as int.
  final int statusCode;

  /// The (frozen) request that triggered this response.
  final IsolateHttpRequest? request;

  /// The size of the response body, in bytes.
  ///
  /// If the size of the request is not known in advance, this is `null`.
  final int? contentLength;

  /// The response using for Isolate Http.
  ///
  /// [body] The body of the response as a String.
  ///
  /// [statusCode] The status code of the response as int.
  ///
  /// [headers] The headers of the response as a Map<String, String>.
  IsolateHttpResponse(this.body, this.statusCode, this.headers,
      {this.contentLength, this.request});

  /// Return the body as as Json (dynamic).
  dynamic get bodyJson => jsonDecode(body);

  /// Return the body as as Map<String, dynamic>.
  Map<String, dynamic> get bodyAsMap => bodyJson is Map<String, dynamic>
      ? bodyJson
      : throw ArgumentError("body is not Map");

  /// Return the body as as List<dynamic>.
  List<dynamic> get bodyAsList => bodyJson is List<dynamic>
      ? bodyJson
      : throw ArgumentError("body is not List");
}
