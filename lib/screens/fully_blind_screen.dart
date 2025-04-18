import 'package:flutter/material.dart';
import 'package:visionaid_ar/features/tts_helper.dart';

class FullyBlindScreen extends StatelessWidget {
  final tts = TTSHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fully Blind Mode"),
        backgroundColor: const Color.fromARGB(255, 157, 168, 230),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            tts.speak("Hello! Object detection will be available soon.");
          },
          child: Text("Test Voice Output"),
        ),
      ),
    );
  }
}
