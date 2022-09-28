import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// IsolateFlutterConfiguration
class IsolateFlutterConfiguration<Q, R> {
  final ComputeCallback<Q, R> callback;
  final Q message;
  final SendPort resultPort;
  final String? debugLabel;

  IsolateFlutterConfiguration(
      this.callback, this.message, this.resultPort, this.debugLabel);

  FutureOr<R> apply() => callback(message);
}
