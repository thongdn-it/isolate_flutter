// `image` 4.x declares its own `ImageFormat`; hide it so this package's
// `ImageFormat` (see src/constants/enums.dart) stays unambiguous.
import 'package:image/image.dart' hide ImageFormat;

import 'package:isolate_image_compress/src/constants/enums.dart';
import 'package:isolate_image_compress/src/entity/isolate_image.dart';

extension ResizeOnImage on Image {
  /// Resize image with resolution
  Image resizeWithResolution(ImageResolution resolution) {
    int? _newWidth, _newHeight;
    if (width < height) {
      if (height > resolution.height) {
        _newHeight = resolution.height;
      }
    } else {
      if (width > resolution.width) {
        _newWidth = resolution.width;
      }
    }
    if (_newWidth != null || _newHeight != null) {
      return copyResize(this, width: _newWidth, height: _newHeight);
    }

    return this;
  }
}

extension ResizeOnIsolateImage on IsolateImage {
  /// Resize image with resolution
  Image? resizeWithResolution(ImageResolution resolution) {
    if (data?.isNotEmpty == true) {
      final _image = decodeImage(data!);
      if (_image != null) {
        return _image.resizeWithResolution(resolution);
      }
    }
    return null;
  }
}
