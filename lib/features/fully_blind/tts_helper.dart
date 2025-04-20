import 'package:flutter_tts/flutter_tts.dart';

class TTSHelper {
  final FlutterTts _tts = FlutterTts();

  TTSHelper() {
    _tts.setLanguage("en-US");
    _tts.setPitch(1.0);
    _tts.setSpeechRate(0.5);
  }

  Future speak(String text) async {
    await _tts.speak(text);
  }

  Future stop() async {
    await _tts.stop();
  }
}
