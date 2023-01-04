library isolate_flutter;

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'package:isolate_flutter/src/isolate_flutter_status.dart';
import 'package:isolate_flutter/src/isolate_flutter_configuration.dart';

/// An Isolate Flutter.
///
/// You can create multiple isolate and manager it like start, pause, resume, stop.
class IsolateFlutter {
  IsolateFlutterStatus? _status;

  Isolate? _isolate;

  late RawReceivePort _port;

  late Completer<dynamic> _completer;

  IsolateFlutter._();

  /// Create an isolate. The isolate will start up in a paused state. To start and get the return value, call `isolateFlutter.start()`.
  ///
  /// Return the created isolate.
  ///
  /// Run `callback` on that isolate, passing it `message`, and (eventually) return the value returned by `callback`.
  ///
  /// The `callback` argument must be a top-level function, not a closure or an instance or static method of a class.
  ///
  /// `Q` is the type of the message that kicks off the computation.
  ///
  /// `R` is the type of the value returned.
  ///
  /// The `debugLabel` argument can be specified to provide a name to add to the [Timeline].
  /// This is useful when in debuggers and logging.
  static Future<IsolateFlutter?> create<Q, R>(
      ComputeCallback<Q, R> callback, Q message,
      {String? debugLabel}) async {
    final _isolateFlutter = IsolateFlutter._();

    if (_isolateFlutter._status != null) {
      // _isolateFlutter has been created
      return null;
    }

    final _debugLabel =
        debugLabel ?? 'IsolateFlutter_${_isolateFlutter.hashCode}';

    // Create Completer
    _isolateFlutter._completer = Completer<dynamic>();

    // Create ReceivePort
    _isolateFlutter._port = RawReceivePort((dynamic msg) {
      _isolateFlutter._completer.complete(msg);
      _isolateFlutter.stop();
    }, _debugLabel);

    // Swap an isolate
    try {
      final _sendPort = _isolateFlutter._port.sendPort;
      _isolateFlutter._isolate = await Isolate.spawn(
          _spawn,
          IsolateFlutterConfiguration<Q, FutureOr<R>>(
              callback, message, _sendPort, _debugLabel),
          errorsAreFatal: true,
          onError: _sendPort,
          onExit: _sendPort,
          debugName: _debugLabel,
          paused: true);
    } catch (e) {
      throw RemoteError('IsolateFlutter cann`t be created.', '');
    }

    _isolateFlutter._status = IsolateFlutterStatus.Paused;

    return _isolateFlutter;
  }

  /// Create and start an isolate.
  ///
  /// Return the value returned by `callback`.
  ///
  /// Run `callback` on that isolate, passing it `message`, and (eventually) return the value returned by `callback`.
  ///
  /// The `callback` argument must be a top-level function, not a closure or an instance or static method of a class.
  ///
  /// `Q` is the type of the message that kicks off the computation.
  ///
  /// `R` is the type of the value returned.
  ///
  /// The `debugLabel` argument can be specified to provide a name to add to the [Timeline].
  /// This is useful when in debuggers and logging.
  static Future<R?> createAndStart<Q, R>(
      ComputeCallback<Q, R> callback, Q message,
      {String? debugLabel}) async {
    final _isolateFlutter =
        await IsolateFlutter.create(callback, message, debugLabel: debugLabel);
    if (_isolateFlutter != null) {
      return _isolateFlutter.start();
    } else {
      return null;
    }
  }

  /// Start the isolate and return the value returned by `callback`.
  Future<R> start<R>() async {
    // Run and get result
    resume();
    final _result = await _completer.future;

    if (_result == null) {
      throw RemoteError('IsolateFlutter exited with null.', '');
    }

    if (_result is List<dynamic>) {
      final _type = _result.length;
      switch (_type) {
        case 1:
          return _result[0] as R;
        case 2:
          await Future<Never>.error(
              RemoteError(_result[0] as String, _result[1] as String));
        case 3:
          await Future<Never>.error(
              _result[0] as Object, _result[1] as StackTrace);
        default:
          throw RemoteError(
              'IsolateFlutter exited without result or error.', '');
      }
    } else {
      throw RemoteError('IsolateFlutter exited without result or error.', '');
    }
  }

  /// Pause the current isolate
  void pause() {
    _status = IsolateFlutterStatus.Paused;
    _isolate?.pause(_isolate?.pauseCapability);
  }

  /// Resume the current isolate
  void resume() {
    if (_isolate?.pauseCapability != null) {
      _status = IsolateFlutterStatus.Running;
      _isolate?.resume(_isolate!.pauseCapability!);
    }
  }

  /// Stop and dispose the current isolate
  void stop() {
    _isolate?.kill();

    _port.close();
    _isolate = null;
    _status = IsolateFlutterStatus.Stopped;
  }

  bool get isRunning => _status == IsolateFlutterStatus.Running;
  bool get isPaused => _status == IsolateFlutterStatus.Paused;
  bool get isStopped =>
      _status == null || _status == IsolateFlutterStatus.Stopped;
}

Future<void> _spawn<Q, R>(
    IsolateFlutterConfiguration<Q, R> configuration) async {
  late final List<dynamic> _applicationResult;

  try {
    _applicationResult = List<R>.filled(1, await (configuration.apply()));
  } catch (error, stackTrace) {
    _applicationResult = List<dynamic>.filled(3, null)
      ..[0] = error
      ..[1] = stackTrace;
  }

  Isolate.exit(configuration.resultPort, _applicationResult);
}
