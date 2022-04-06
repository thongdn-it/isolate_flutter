import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:isolate_flutter/isolate_flutter.dart';

import 'package:isolate_image_compress/src/constants/enums.dart';
import 'package:isolate_image_compress/src/entity/isolate_image.dart';
import 'package:isolate_image_compress/src/compress_format/index.dart';

class CompressParams {
  /// [image] - the image used for compression.
  final IsolateImage? image;

  /// [imageData] - the image data used for compression.
  final Uint8List? imageData;

  /// [maxSize] - compressed file size limit (Bytes).
  final int? maxSize;

  /// [maxResolution] - the maximum resolution compressed.
  final ImageResolution? maxResolution;

  /// [format] - the image format you want to compress.
  final ImageFormat? format;

  /// Parameters used for compression
  ///
  /// - [image] - the image data used for compression (required).
  /// - [maxSize] - compressed file size limit (Bytes) (optional).
  /// - [maxResolution] - the maximum resolution compressed. Default is [ImageResolution.uhd] - 4K, Ultra HD | 3840 x 2160.
  /// - [format] - the image format you want to compress (optional).
  CompressParams(
      {this.image,
      this.imageData,
      this.maxSize,
      this.maxResolution = ImageResolution.uhd,
      this.format})
      : assert(image != null || imageData != null);
}

Future<Uint8List> _compressImage(CompressParams params) async {
  final _maxSize = params.maxSize;

  // read image data
  final Uint8List _fileData =
      params.imageData ?? params.image?.data ?? Uint8List(0);

  if (_fileData.isEmpty || _maxSize == null || _fileData.length < _maxSize) {
    // not compression
    return _fileData;
  } else {
    final _maxResolution = params.maxResolution;

    Decoder? _decoder =
        (params.format != null ? _getDecoder(params.format!) : null) ??
            findDecoderForData(_fileData);
    if (_decoder is JpegDecoder) {
      return compressJpegImage(_fileData,
          maxSize: _maxSize, maxResolution: _maxResolution);
    } else if (_decoder is PngDecoder) {
      return compressPngImage(_fileData,
          maxSize: _maxSize, maxResolution: _maxResolution);
    } else if (_decoder is TgaDecoder) {
      return compressTgaImage(_fileData,
          maxSize: _maxSize, maxResolution: _maxResolution);
    } else if (_decoder is GifDecoder) {
      return compressGifImage(_fileData,
          maxSize: _maxSize, maxResolution: _maxResolution);
    }

    return Uint8List(0);
  }
}

Decoder? _getDecoder(ImageFormat format) {
  switch (format) {
    case ImageFormat.jpeg:
      return JpegDecoder();
    case ImageFormat.png:
      return PngDecoder();
    case ImageFormat.tga:
      return TgaDecoder();
    case ImageFormat.gif:
      return GifDecoder();
    default:
      return null;
  }
}

// --- Extension --- //

extension CompressOnIsolateImage on IsolateImage {
  /// Compress image.
  ///
  /// - [maxSize] - compressed file size limit (Bytes). (optional).
  /// - [maxResolution] - the maximum resolution compressed. (optional).
  /// - [format] - the image format you want to compress. (optional).
  Future<Uint8List?> compress(
      {int? maxSize,
      ImageResolution? maxResolution,
      ImageFormat? format}) async {
    final CompressParams _params = CompressParams(
        image: this,
        maxSize: maxSize,
        maxResolution: maxResolution,
        format: format);
    return IsolateFlutter.createAndStart(_compressImage, _params,
        debugLabel: 'isolate_image_compress');
  }
}

extension CompressOnUint8List on Uint8List {
  /// Compress image data.
  ///
  /// - [maxSize] - compressed file size limit (Bytes). (optional).
  /// - [maxResolution] - the maximum resolution compressed. (optional).
  /// - [format] - the image format you want to compress. (optional).
  Future<Uint8List?> compress(
      {int? maxSize, ImageResolution? resolution, ImageFormat? format}) async {
    final CompressParams _params = CompressParams(
        imageData: this,
        maxSize: maxSize,
        maxResolution: resolution,
        format: format);
    return IsolateFlutter.createAndStart(_compressImage, _params,
        debugLabel: 'isolate_image_compress');
  }
}

extension CompressOnListInt on List<int> {
  /// Compress image data.
  ///
  /// - [maxSize] - compressed file size limit (Bytes). (optional).
  /// - [maxResolution] - the maximum resolution compressed. (optional).
  /// - [format] - the image format you want to compress. (optional).
  Future<Uint8List?> compress(
      {int? maxSize, ImageResolution? resolution, ImageFormat? format}) async {
    final CompressParams _params = CompressParams(
        imageData: Uint8List.fromList(this),
        maxSize: maxSize,
        maxResolution: resolution,
        format: format);
    return IsolateFlutter.createAndStart(_compressImage, _params,
        debugLabel: 'isolate_image_compress');
  }
}
