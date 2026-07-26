# [4.0.0] - 26/07/2026

- **Breaking**: require Flutter `>=3.35.0` / Dart `^3.9.0`. Earlier SDKs are no
  longer supported.
- Support Flutter 3.44 / Dart 3.
- Rename the `IsolateFlutterStatus` values to lowerCamelCase (`running`,
  `paused`, `stopped`).
- Update `flutter_lints` to `^6.0.0`.
- Add a test suite covering create/start, pause/resume/stop, stopping in-flight
  work, error propagation and concurrent isolates.

# [3.0.0] - 30/09/2022

- Change to use only one RawReceivePort.

# [2.0.0] - 03/09/2021

- Support null-safety.

# [1.0.0] - 30/08/2021

- Initial package.
