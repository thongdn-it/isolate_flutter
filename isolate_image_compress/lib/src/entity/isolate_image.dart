import 'dart:io';
import 'dart:typed_data';

import 'package:isolate_image_compress/src/constants/enums.dart';

/// Image Entity Use in package
class IsolateImage {
  final String? filePath;

  Uint8List? _fileData;
  Uint8List? get data {
    return _fileData ??=
        (filePath != null ? File(filePath!).readAsBytesSync() : null);
  }

  final ImageFromType _fromType;
  ImageFromType get fromType => _fromType;

  IsolateImage({Uint8List? data, String? path})
      : assert(data != null || path != null),
        _fileData = data,
        filePath = path,
        _fromType = path != null ? ImageFromType.path : ImageFromType.file;

  factory IsolateImage.data(Uint8List data) {
    return IsolateImage(data: data);
  }

  factory IsolateImage.path(String path) {
    return IsolateImage(path: path);
  }
}
