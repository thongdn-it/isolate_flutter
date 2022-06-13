import 'dart:convert';

import 'package:http/http.dart';

abstract class LogUtils {
  static String getCurl(BaseRequest request) {
    List<String> components = ['curl -i'];
    if (request.method.toUpperCase() != 'GET') {
      components.add('-X ${request.method.toUpperCase()}');
    }

    for (var _key in request.headers.keys) {
      if (_key != 'Cookie') {
        components.add('-H "$_key: ${request.headers[_key]}"');
      }
    }

    if (request is Request) {
      if (request.body.isNotEmpty == true) {
        final data = request.body.replaceAll('"', '\\"');
        components.add('-d "$data"');
      }
    } else if (request is MultipartRequest) {
      if (request.fields.isNotEmpty == true) {
        final data = jsonEncode(request.fields).replaceAll('"', '\\"');
        components.add('-d "$data"');
      }
      if (request.files.isNotEmpty == true) {
        for (var _file in request.files) {
          components.add('-F ${_file.field}=@/path/to/${_file.filename}');
        }
      }
    }

    components.add('"${request.url.toString()}"');

    return components.join(' \\\n\t');
  }
}
