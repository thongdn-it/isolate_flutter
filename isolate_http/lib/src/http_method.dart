abstract class HttpMethod {
  /// [get] is used to request data from a specified resource.
  static const get = 'GET';

  /// [post] is used to send data to a server to create/update a resource.
  static const post = 'POST';

  /// [head] is almost identical to GET, but without the response body.
  static const head = 'HEAD';

  /// [put] is used to send data to a server to create/update a resource.
  ///
  /// The difference between POST and PUT is that PUT requests are idempotent.
  /// That is, calling the same PUT request multiple times will always produce the same result.
  /// In contrast, calling a POST request repeatedly have side effects of creating the same resource multiple times.
  static const put = 'PUT';

  /// The [delete] method deletes the specified resource.
  static const delete = 'DELETE';
}
