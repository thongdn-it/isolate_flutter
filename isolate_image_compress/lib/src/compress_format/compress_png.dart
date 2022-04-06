import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:isolate_image_compress/src/log_utils.dart';
import 'package:isolate_image_compress/src/resize_utils.dart';
import 'package:isolate_image_compress/src/constants/enums.dart';

/// Compress PNG Image - return empty(*Uint8List(0)*) if image can't be compressed.
///
/// Params:
/// - [data] The image data to compress.
/// - [maxSize] limit file size you want to compress (Bytes). If it is null, return [data].
/// - [maxResolution] limit image resolution you want to compress ([ImageResolution]). Default is [ImageResolution.uhd].
Future<Uint8List> compressPngImage(Uint8List data,
    {int? maxSize, ImageResolution? maxResolution}) async {
  if (maxSize == null) {
    return data;
  }

  // level: The compression level, in the range [0, 9] where 9 is the most compressed.
  const _minLevel = 0;
  const _maxLevel = 9;
  const _step = 1;

  ImageResolution? _resolution = maxResolution ?? ImageResolution.uhd;

  Image? _image = decodeImage(data);
  if (_image == null) {
    return Uint8List(0);
  } else {
    List<int>? _data;
    do {
      if (_resolution != null) {
        _image = _image!.resizeWithResolution(_resolution);
        print(
            'resizeWithResolution: ${_resolution.width} - ${_resolution.height}');
      }

      _data = encodePng(_image!, level: _minLevel);
      print('encodePNG - _minLevel: ${_data.length}');

      if (_data.length > maxSize) {
        _data = encodePng(_image, level: _maxLevel);
        print('encodePNG - _maxLevel: ${_data.length}');

        if (_data.length < maxSize) {
          int _level = _minLevel;
          do {
            _level += _step;
            _data = encodePng(_image, level: _level);
            print('encodePNG - _level - $_level: ${_data.length}');
          } while (_data.length > maxSize && _level < _maxLevel);

          break;
        }
      }
      _resolution = _resolution?.prev();
    } while (_resolution != null);

    return _data.length < maxSize ? Uint8List.fromList(_data) : Uint8List(0);
  }
}
