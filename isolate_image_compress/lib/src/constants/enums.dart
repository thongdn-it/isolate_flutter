enum ImageFromType { file, path }
enum ImageFormat { png, jpeg, gif, tga }

class ImageResolution {
  final int width;
  final int height;

  const ImageResolution(this.width, this.height);

  /// Standard Definition (SD) | 640 x 480 | 480p | 4:3
  static const ImageResolution sd = ImageResolution(640, 480);

  /// High Definition (HD) | 1280 x 720 | 720p | 16:9
  static const ImageResolution hd = ImageResolution(1280, 720);

  /// Full HD, FHD | 1920 x 1080 | 1080p | 16:9
  static const ImageResolution fhd = ImageResolution(1920, 1080);

  /// 2K, Quad HD, QHD | 2560 x 1440 | 2K | 16:9
  static const ImageResolution qhd = ImageResolution(2560, 1440);

  /// 4K, Ultra HD | 3840 x 2160 | 4K | 16:9
  static const ImageResolution uhd = ImageResolution(3840, 2160);

  /// 8K, Ultra HD | 7680 x 4320 | 8K | 16:9
  static const ImageResolution fuhd = ImageResolution(7680, 4320);

  static const List<ImageResolution> all = [sd, hd, fhd, qhd, uhd, fuhd];

  ImageResolution? prev() {
    final _index = all.indexOf(this);
    if (_index > 0) {
      return all[_index - 1];
    }
    return null;
  }

  ImageResolution? next() {
    final _index = all.indexOf(this);
    if (_index < all.length - 1) {
      return all[_index + 1];
    }
    return null;
  }
}
