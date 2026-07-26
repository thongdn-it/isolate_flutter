# [3.0.0] - 26/07/2026

- **Breaking**: require Flutter `>=3.35.0` / Dart `^3.9.0`. Earlier SDKs are no
  longer supported.
- **Breaking**: depend on `isolate_flutter: ^4.0.0`.
- Update `image` to `^4.9.1`. Note that `image` 4.x declares its own `ImageFormat`,
  which collides with this package's. If you import both libraries, hide one of
  them, e.g. `import 'package:image/image.dart' hide ImageFormat;`.
- Switch linting to `flutter_lints ^6.0.0`.
- Add a test suite covering compression, resizing and resolution handling.

# [2.0.0] - 05/01/2023

- Update a dependency to the latest release.

# [1.0.0] - 06/04/2022

- Initial package.
