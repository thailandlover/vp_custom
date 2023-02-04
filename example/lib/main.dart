import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vp_custom/vp_custom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _vpCustomPlugin = VpCustom();

  @override
  void initState() {
    super.initState();
  }

  _play() async {
    dynamic result;
    try {
      result =
          await _vpCustomPlugin.play(
              {
                "title": "title",
                "id": '205727',
                "type": "series",
                "description": "here is the description",
                "posterPhoto": 'https://thekee-m.gcdn.co/images06012022/uploads/media/series/posters/2022-09-27/0ObHcBVUnfpzbtIB.jpg',
                "mediaUrl": "https://thekee.gcdn.co/video/m-159n/English/Animation&Family/Baby.Shark.Best.Kids.Song/S01/01.mp4",
                "playPosition": '9000',
                "userId": '77810',
                "profileId": '217588',
                "mediaType": "tvshow",
                "episodes": jsonEncode([]),
                "subtitles": jsonEncode([]),
                "subtitle": "-"
              }
          ) ?? 'UnKnown Result from play';
    } on PlatformException {
      result = 'Failed to play.';
    }
    if(kDebugMode) {
      print("result: $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _play,
            child: const Text('Play'),
          ),
        ),
      ),
    );
  }
}