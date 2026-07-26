// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:isolate_flutter/isolate_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IsolateFlutter Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'IsolateFlutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IsolateFlutter? _isolateFlutter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              label: const Text('Create'),
              icon: const Icon(Icons.create),
              onPressed: _onCreate,
            ),
            TextButton.icon(
              label: const Text('Start'),
              icon: const Icon(Icons.play_arrow),
              onPressed: _onStart,
            ),
            TextButton.icon(
              label: const Text('Pause'),
              icon: const Icon(Icons.pause),
              onPressed: _onPause,
            ),
            TextButton.icon(
              label: const Text('Resume'),
              icon: const Icon(Icons.play_arrow),
              onPressed: _onResume,
            ),
            TextButton.icon(
              label: const Text('Stop'),
              icon: const Icon(Icons.stop),
              onPressed: _onStop,
            ),
            const Text('--- OR ---'),
            TextButton.icon(
              label: const Text('Create and start'),
              icon: const Icon(Icons.playlist_play),
              onPressed: _onCreateAndStart,
            ),
          ],
        ),
      ),
    );
  }

  void _onCreate() async {
    print('Create Isolate');
    _isolateFlutter = await IsolateFlutter.create(_testFunction, 'Hello World');
  }

  void _onStart() async {
    print('Start Isolate');
    final _value = await _isolateFlutter?.start();
    print(_value);
  }

  void _onPause() {
    print('Pause Isolate');
    _isolateFlutter?.pause();
  }

  void _onResume() {
    print('Resume Isolate');
    _isolateFlutter?.resume();
  }

  void _onStop() {
    print('Stop Isolate');
    _isolateFlutter?.stop();
  }

  void _onCreateAndStart() async {
    print('Create And Start Isolate');
    final _value =
        await IsolateFlutter.createAndStart(_testFunction, 'Hello World');
    print(_value);
  }

  static Future<String> _testFunction(String message) async {
    Timer.periodic(
        const Duration(seconds: 1), (timer) => print('$message - ${timer.tick}'));
    await Future<void>.delayed(const Duration(seconds: 30));
    return '_testFunction finish';
  }
}
