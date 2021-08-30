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
  IsolateFlutterStatus _status;

  Isolate _isolate;

  ReceivePort _resultPort, _exitPort, _errorPort;

  Completer _completer;

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
  static Future<IsolateFlutter> create<Q, R>(ComputeCallback<Q, R> callback, Q message, {String debugLabel}) async {
    final _isolateFlutter = IsolateFlutter._();

    if (_isolateFlutter._status != null) {
      // _isolateFlutter has been created
      return null;
    }

    final _debugLabel = debugLabel ?? 'IsolateFlutter_${_isolateFlutter.hashCode}';

    // Create ReceivePort
    _isolateFlutter._resultPort = ReceivePort();
    _isolateFlutter._exitPort = ReceivePort();
    _isolateFlutter._errorPort = ReceivePort();

    // Create Completer
    _isolateFlutter._completer = Completer<R>();

    // Swap an isolate
    _isolateFlutter._isolate = await Isolate.spawn(
      _spawn,
      IsolateFlutterConfiguration<Q, FutureOr<R>>(
        callback,
        message,
        _isolateFlutter._resultPort.sendPort,
        _debugLabel,
      ),
      onError: _isolateFlutter._errorPort.sendPort,
      onExit: _isolateFlutter._exitPort.sendPort,
      debugName: _debugLabel,
      paused: true,
    );

    // create listen
    _isolateFlutter._errorPort.listen((dynamic errorData) {
      if (!_isolateFlutter._completer.isCompleted) {
        _isolateFlutter._completer.completeError(errorData);
        _isolateFlutter.stop();
      }
    });

    _isolateFlutter._exitPort.listen((dynamic exitData) {
      if (!_isolateFlutter._completer.isCompleted) {
        _isolateFlutter._completer
            .completeError(Exception('IsolateFlutter -> Isolate exited without result or error.'));
        _isolateFlutter.stop();
      }
    });

    _isolateFlutter._resultPort.listen((dynamic resultData) {
      assert(resultData == null || resultData is R);
      if (!_isolateFlutter._completer.isCompleted) {
        _isolateFlutter._completer.complete(resultData as R);
        _isolateFlutter.stop();
      }
    });

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
  static Future<R> createAndStart<Q, R>(ComputeCallback<Q, R> callback, Q message, {String debugLabel}) async {
    final _isolateFlutter = await IsolateFlutter.create(callback, message, debugLabel: debugLabel);
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

    return _result;
  }

  /// Pause the current isolate
  void pause() {
    _status = IsolateFlutterStatus.Paused;
    _isolate.pause(_isolate?.pauseCapability);
  }

  /// Resume the current isolate
  void resume() {
    if (_isolate?.pauseCapability != null) {
      _status = IsolateFlutterStatus.Running;
      _isolate.resume(_isolate.pauseCapability);
    }
  }

  /// Stop and dispose the current isolate
  void stop() {
    _isolate?.kill();

    _resultPort?.close();
    _errorPort?.close();
    _exitPort?.close();

    _resultPort = null;
    _errorPort = null;
    _exitPort = null;
    _isolate = null;
    _status = IsolateFlutterStatus.Stopped;
  }

  bool get isRunning => _status == IsolateFlutterStatus.Running;
  bool get isPaused => _status == IsolateFlutterStatus.Paused;
  bool get isStopped => _status == null || _status == IsolateFlutterStatus.Stopped;
}

Future<void> _spawn<Q, R>(IsolateFlutterConfiguration<Q, FutureOr<R>> configuration) async {
  final FutureOr<R> applicationResult = await (configuration.apply() as FutureOr<R>);
  final result = await applicationResult;
  configuration.resultPort.send(result);
}
