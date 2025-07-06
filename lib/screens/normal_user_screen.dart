import 'package:flutter/material.dart';
import 'package:visionaid_ar/features/fully_blind/tts_helper.dart';

class NormalUserScreen extends StatefulWidget {
  @override
  State<NormalUserScreen> createState() => _NormalUserScreenState();
}

class _NormalUserScreenState extends State<NormalUserScreen> {
  final TTSHelper tts = TTSHelper();
  @override
  void initState() {
    super.initState();
    tts.speak("Welcome to Normal User Mode");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Normal User Mode")),
      body: Center(
        child: Text(
          "Welcome to Normal User Mode",

          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
