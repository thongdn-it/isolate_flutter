# [4.0.0] - 26/07/2026

- **Breaking**: require Flutter `>=3.35.0` / Dart `^3.9.0`. Earlier SDKs are no
  longer supported.
- **Breaking**: upgrade `http` from `^0.13.0` to `^1.6.0`. `HttpFile.toMultipartFile()`
  now returns a `MultipartFile` from `http` 1.x.
- **Breaking**: depend on `isolate_flutter: ^4.0.0`.
- Fix: `send()` now stops the isolate it spawned once it returns. Previously a
  timed-out request kept running in the background after the caller had already
  received its 408.
- Re-export `MediaType` from `isolate_http.dart`, so callers no longer need a
  direct dependency on `http_parser`.
- Switch linting to `flutter_lints ^6.0.0`.
- Add a test suite covering request building, curl logging and GET/POST/multipart
  round trips through an isolate.

# [3.0.0] - 05/01/2023

- Update a dependency to the latest release.

# [2.3.0] - 30/06/2022

- Support multiple content-type headers.

# [2.2.0] - 13/06/2022

- Add log CURL.
- Add `contentLength` for IsolateHttpRequest, IsolateHttpResponse.

# [2.1.1] - 23/09/2021

- [Fix] missing `content-type` header in post method.

# [2.1.0] - 12/09/2021

- Support timeout, debug label.

# [2.0.0] - 03/09/2021

- Support null-safety.

# [1.0.0] - 01/09/2021

- Initial package.
