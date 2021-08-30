# IsolateFlutter

[![Pub][pub_v_image_url]][pub_url]

IsolateFlutter is a useful package for you who want to make and manage Isolate. It is based on `dart:isolate` so it only support iOS and Android.

It's like [compute()](https://api.flutter.dev/flutter/foundation/compute-constant.html): *Spawn an isolate, run callback on that isolate, passing it message, and (eventually) return the value returned by callback*. But it not `top-level constant` so you can create multiple Isolates at the same time.

## Usage

### Create and start an isolate

```dart
final _value = await IsolateFlutter.createAndStart(_testFunction, 'Hello World');
print(_value);
```

### Create and manager an isolate (not run immediately)

1. Create an isolate:

    ```dart
    IsolateFlutter _isolateFlutter = await IsolateFlutter.create(_testFunction, 'Hello World');
    ```

2. Start and get the value returned by _testFunction

    ```dart
    final _value = await _isolateFlutter.start();
    print(_value);
    ```

3. Pause a running isolate

    ```dart
    _isolateFlutter.pause();
    ```

4. Resume a paused isolate

    ```dart
    _isolateFlutter.resume();
    ```

5. Stop and dispose a an isolate

    ```dart
    _isolateFlutter.stop();
    ```

### Example test function

```dart
static Future<String> _testFunction(String message) async {
    Timer.periodic(Duration(seconds: 1), (timer) => print('$message - ${timer.tick}'));
    await Future.delayed(Duration(seconds: 30));
    return '_testFunction finish';
  }
```

## Author

IsolateFlutter is developed by Thong Dang. You can contact me at thongdn.it@gmail.com

If you like my project, you can support me [![Buy Me A Coffee][buy_me_a_coffee_image_url]][buy_me_a_coffee_url] or star (like) for it.

Thank you! ❤️

[//]: # (reference links)

[pub_url]: https://pub.dev/packages/isolate_flutter
[pub_v_image_url]: https://img.shields.io/pub/v/isolate_flutter.svg
[buy_me_a_coffee_image_url]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png
[buy_me_a_coffee_url]: https://www.buymeacoffee.com/thongdn.it
