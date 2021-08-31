import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

/// A file to be uploaded as part of a [IsolateHttp].
class HttpFile {
  /// The name of the form field for the file.
  final String field;

  /// Byte array of the file.
  final List<int> bytes;

  /// The path to a file on disk.
  final String filePath;

  /// The encoding to use when translating [value] into bytes is taken from
  /// [contentType] if it has a charset set. Otherwise, it defaults to UTF-8.
  /// [contentType] currently defaults to `text/plain; charset=utf-8`, but in
  /// the future may be inferred from [filename].
  final String value;

  /// The basename of the file.
  final String filename;

  /// The content-type of the file.
  final MediaType contentType;

  HttpFile._(this.field,
      {this.bytes, this.filePath, this.value, this.filename, this.contentType});

  /// Creates a new [HttpFile] from a byte array.
  factory HttpFile.fromBytes(String field, List<int> bytes,
      {String filename, MediaType contentType}) {
    return HttpFile._(field,
        bytes: bytes, filename: filename, contentType: contentType);
  }

  /// Creates a new [HttpFile] from a path to a file on disk.
  factory HttpFile.fromPath(String field, String filePath,
      {String filename, MediaType contentType}) {
    return HttpFile._(field,
        filePath: filePath, filename: filename, contentType: contentType);
  }

  /// Creates a new [HttpFile] from a string.
  factory HttpFile.fromString(String field, String value,
      {String filename, MediaType contentType}) {
    return HttpFile._(field,
        value: value, filename: filename, contentType: contentType);
  }

  /// Convert [HttpFile] to [MultipartFile].
  ///
  /// A file to be uploaded as part of a [MultipartRequest].
  /// This doesn't need to correspond to a physical file.
  Future<MultipartFile> toMultipartFile() async {
    if (bytes != null) {
      return MultipartFile.fromBytes(field, bytes,
          filename: filename, contentType: contentType);
    } else if (filePath != null) {
      return MultipartFile.fromPath(field, filePath,
          filename: filename, contentType: contentType);
    } else if (value != null) {
      return MultipartFile.fromString(field, value,
          filename: filename, contentType: contentType);
    }
    return null;
  }
}
