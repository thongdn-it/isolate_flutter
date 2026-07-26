# IsolateFlutter

[![Pub][pub_v_image_url]][pub_url]

IsolateFlutter is a useful package for you who want to make and manage Isolate. It is based on `dart:isolate` so it only support iOS and Android.

It's like [compute()](https://api.flutter.dev/flutter/foundation/compute-constant.html): *Spawn an isolate, run callback on that isolate, passing it message, and (eventually) return the value returned by callback*. But it not `top-level constant` so you can create multiple Isolates at the same time.

## Requirements

Flutter `>=3.35.0`, Dart `^3.9.0`. Verified against Flutter 3.44.

## Installation

```yaml
dependencies:
  isolate_flutter: ^4.0.0
```

```dart
import 'package:isolate_flutter/isolate_flutter.dart';
```

## Usage

### Create and start an isolate

```dart
final _value = await IsolateFlutter.createAndStart(_testFunction, 'Hello World');
print(_value);
```

### Create and manager an isolate (not run immediately)

1. Create an isolate. It returns `null` if the isolate could not be created:

    ```dart
    final IsolateFlutter? _isolateFlutter = await IsolateFlutter.create(_testFunction, 'Hello World');
    ```

2. Start and get the value returned by _testFunction

    ```dart
    final _value = await _isolateFlutter?.start();
    print(_value);
    ```

3. Pause a running isolate

    ```dart
    _isolateFlutter?.pause();
    ```

4. Resume a paused isolate

    ```dart
    _isolateFlutter?.resume();
    ```

5. Stop and dispose a an isolate

    ```dart
    _isolateFlutter?.stop();
    ```

    `stop()` kills the isolate, so work that is still in flight is abandoned. The
    `Future` returned by `start()` never completes in that case.

### Reading the state

```dart
_isolateFlutter?.isRunning;
_isolateFlutter?.isPaused;
_isolateFlutter?.isStopped; // also true before the isolate has ever started
```

### Example test function

The callback must be a top-level function or a static method — it cannot be a
closure or an instance method, because it has to be sent to another isolate.

```dart
Future<String> _testFunction(String message) async {
  Timer.periodic(const Duration(seconds: 1), (timer) => print('$message - ${timer.tick}'));
  await Future<void>.delayed(const Duration(seconds: 30));
  return '_testFunction finish';
}
```

### Errors

If the callback throws, the error and its stack trace are forwarded to the
calling isolate, so `start()` / `createAndStart()` rethrow the original error:

```dart
try {
  await IsolateFlutter.createAndStart(_testFunction, 'Hello World');
} on StateError catch (e) {
  print(e);
}
```

## Author

IsolateFlutter is developed by Thong Dang. You can contact me at thongdn.it@gmail.com

If you like my project, you can support me [![Buy Me A Coffee][buy_me_a_coffee_image_url]][buy_me_a_coffee_url] or star (like) for it.

Thank you! ❤️

[//]: # (reference links)

[pub_url]: https://pub.dev/packages/isolate_flutter
[pub_v_image_url]: https://img.shields.io/pub/v/isolate_flutter.svg
[buy_me_a_coffee_image_url]: https://buymeacoffee.com/assets/img/custom_images/orange_img.png
[buy_me_a_coffee_url]: https://buymeacoffee.com/thongdn
