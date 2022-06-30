import 'dart:io';

/// Content-Type in Header
///
/// Define most common type.
abstract class ContentType {
  /// content-type
  static const String contentTypeHeaderKey = HttpHeaders.contentTypeHeader;

  // - Text - //
  /// text/plain
  static const String text = 'text/plain';

  /// text/html
  static const String html = 'text/html';

  /// text/css
  static const String css = 'text/css';

  /// text/csv
  static const String csv = 'text/csv';

  // - Application - //
  /// application/javascript
  static const String javascript = 'application/javascript';

  /// application/json
  static const String json = 'application/json';

  /// application/xml
  static const String xml = 'application/xml';

  /// application/x-www-form-urlencoded
  // ignore: constant_identifier_names
  static const String x_www_form_urlencoded =
      'application/x-www-form-urlencoded';

  /// application/zip
  static const String zip = 'application/zip';

  /// application/pdf
  static const String pdf = 'application/pdf';

  // - Multipart - //
  /// multipart/form-data
  static const String formData = 'multipart/form-data';

  // - Image - //
  /// image/gif
  static const String gif = 'image/gif';

  /// image/jpeg
  static const String jpeg = 'image/jpeg';

  /// image/png
  static const String png = 'image/png';

  /// image/tiff
  static const String tiff = 'image/tiff';

  // - Video - //
  /// video/mpeg
  static const String mpeg = 'video/mpeg';

  /// video/mp4
  static const String mp4 = 'video/mp4';

  /// video/quicktime
  static const String quicktime = 'video/quicktime';
}

extension ContentTypeString on String {
  Map<String, String> get toContentTypeHeader =>
      {ContentType.contentTypeHeaderKey: this};
}

extension ContentTypeMap on Map {
  String? get contentType {
    if (containsKey(ContentType.contentTypeHeaderKey)) {
      final _sContentType = this[ContentType.contentTypeHeaderKey];
      if (_sContentType is String) {
        return _sContentType.toLowerCase();
      } else {
        return _sContentType.toString().toLowerCase();
      }
    }
    return null;
  }

  bool get isMultipart => contentType?.contains('multipart') == true;

  bool get isJson => contentType?.contains('json') == true;
}
