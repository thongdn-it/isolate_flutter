import 'dart:async';
import 'package:flutter/material.dart';

import 'package:isolate_flutter/isolate_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IsolateFlutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'IsolateFlutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IsolateFlutter _isolateFlutter;

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
            FlatButton.icon(
              label: Text('Create'),
              icon: Icon(Icons.create),
              onPressed: _onCreate,
            ),
            FlatButton.icon(
              label: Text('Start'),
              icon: Icon(Icons.play_arrow),
              onPressed: _onStart,
            ),
            FlatButton.icon(
              label: Text('Pause'),
              icon: Icon(Icons.pause),
              onPressed: _onPause,
            ),
            FlatButton.icon(
              label: Text('Resume'),
              icon: Icon(Icons.play_arrow),
              onPressed: _onResume,
            ),
            FlatButton.icon(
              label: Text('Stop'),
              icon: Icon(Icons.stop),
              onPressed: _onStop,
            ),
            Text('--- OR ---'),
            FlatButton.icon(
              label: Text('Create and start'),
              icon: Icon(Icons.playlist_play),
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
    final _value = await IsolateFlutter.createAndStart(_testFunction, 'Hello World');
    print(_value);
  }

  static Future<String> _testFunction(String message) async {
    Timer.periodic(Duration(seconds: 1), (timer) => print('$message - ${timer.tick}'));
    await Future.delayed(Duration(seconds: 30));
    return '_testFunction finish';
  }
}
