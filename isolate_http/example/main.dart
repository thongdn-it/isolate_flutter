import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:isolate_http/isolate_http.dart';

void main(List<String> args) async {
  // https://developers.google.com/books
  final _isolateHttp =
      IsolateHttp(timeout: Duration(seconds: 60), debugLabel: 'search_book');
  final _response = await _isolateHttp.get(
      'https://www.googleapis.com/auth/books/v1/volumes',
      query: {'q': 'flutter'});
  if (_response?.statusCode == 200) {
    final _bodyJson = _response?.bodyJson;
    print(_bodyJson);
  } else {
    print('Request failed with status: ${_response?.statusCode}.');
  }

  // Log Curl
  _isolateHttp.listener = (curl) {
    if (kDebugMode) {
      log('Isolate Http -> Curl: ----------------\n$curl\n----------------');
    }
  };
}
