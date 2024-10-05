import 'dart:async';
import 'dart:io';

import 'package:app_group_directory/app_group_directory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sharedDirectory = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Directory? sharedDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      sharedDirectory = await AppGroupDirectory.getAppGroupDirectory(
          'com.github.mingchen.test');
      debugPrint('getAppGroupDirectory: $sharedDirectory');
    } on PlatformException catch (ex) {
      debugPrint('Failed to call native method: $ex');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sharedDirectory = sharedDirectory.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Shared directory: $_sharedDirectory\n'),
        ),
      ),
    );
  }
}
