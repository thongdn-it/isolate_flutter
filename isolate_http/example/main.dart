import 'package:isolate_http/isolate_http.dart';

void main(List<String> args) async {
  // https://developers.google.com/books
  final _response = await IsolateHttp().get(
      'https://www.googleapis.com/auth/books/v1/volumes',
      query: {'q': 'flutter'});
  if (_response.statusCode == 200) {
    final _bodyJson = _response.bodyJson;
    print(_bodyJson);
  } else {
    print('Request failed with status: ${_response.statusCode}.');
  }
}
