import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_flutter/isolate_flutter.dart';

// Callbacks handed to an isolate must be top-level (or static) functions.

int _doubleIt(int value) => value * 2;

Future<String> _greet(String name) async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return 'Hello $name';
}

Future<int> _boom(int value) async => throw StateError('boom $value');

Future<String> _neverEnds(String message) async {
  await Future<void>.delayed(const Duration(minutes: 5));
  return message;
}

/// Ticks forever, recording progress in a file so the spawning isolate can see
/// whether the work is still running.
Future<void> _tickIntoFile(String path) async {
  var ticks = 0;
  Timer.periodic(const Duration(milliseconds: 20), (_) {
    ticks++;
    File(path).writeAsStringSync('$ticks');
  });
  await Future<void>.delayed(const Duration(minutes: 5));
}

void main() {
  test('createAndStart returns the value produced by the callback', () async {
    expect(await IsolateFlutter.createAndStart(_doubleIt, 21), 42);
  });

  test('createAndStart supports async callbacks', () async {
    expect(await IsolateFlutter.createAndStart(_greet, 'World'), 'Hello World');
  });

  test('create() spawns a paused isolate that start() runs to completion',
      () async {
    final isolate = await IsolateFlutter.create(_greet, 'Dart');

    expect(isolate, isNotNull);
    expect(isolate!.isPaused, isTrue);
    expect(isolate.isRunning, isFalse);
    expect(isolate.isStopped, isFalse);

    expect(await isolate.start<String>(), 'Hello Dart');
    expect(isolate.isStopped, isTrue);
  });

  test('errors thrown inside the isolate surface on the calling isolate',
      () async {
    await expectLater(
      IsolateFlutter.createAndStart(_boom, 1),
      throwsA(
        isA<StateError>().having((e) => e.message, 'message', 'boom 1'),
      ),
    );
  });

  test('pause/resume/stop move the isolate through its states', () async {
    final isolate = await IsolateFlutter.create(_neverEnds, 'still running');
    expect(isolate, isNotNull);

    isolate!.resume();
    expect(isolate.isRunning, isTrue);

    isolate.pause();
    expect(isolate.isPaused, isTrue);
    expect(isolate.isRunning, isFalse);

    isolate.resume();
    expect(isolate.isRunning, isTrue);

    isolate.stop();
    expect(isolate.isStopped, isTrue);
    expect(isolate.isRunning, isFalse);
    expect(isolate.isPaused, isFalse);
  });

  test('stop() halts work that is still in flight', () async {
    final dir = await Directory.systemTemp.createTemp('isolate_flutter_test');
    addTearDown(() => dir.delete(recursive: true));
    final progress = File('${dir.path}/ticks.txt');

    final isolate = await IsolateFlutter.create(_tickIntoFile, progress.path);
    isolate!.resume();

    // Let it get going, so we know we are stopping real work.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final ticksWhileRunning = int.parse(progress.readAsStringSync());
    expect(ticksWhileRunning, greaterThan(0));

    isolate.stop();

    // Well over the 20ms tick interval: nothing more may be written.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(int.parse(progress.readAsStringSync()), ticksWhileRunning);
  });

  test('several isolates can run concurrently', () async {
    final results = await Future.wait([
      IsolateFlutter.createAndStart(_doubleIt, 1, debugLabel: 'one'),
      IsolateFlutter.createAndStart(_doubleIt, 2, debugLabel: 'two'),
      IsolateFlutter.createAndStart(_doubleIt, 3, debugLabel: 'three'),
    ]);

    expect(results, [2, 4, 6]);
  });
}
