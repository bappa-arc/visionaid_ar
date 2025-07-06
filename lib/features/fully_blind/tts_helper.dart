import 'package:flutter_tts/flutter_tts.dart';

class TTSHelper {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  TTSHelper() {
    _tts.setLanguage("en-US");
    _tts.setPitch(1.0);
    _tts.setSpeechRate(0.5);

    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text, {double pitch = 1.0}) async {
    // Wait until no speech is happening
    while (_isSpeaking) {
      await Future.delayed(Duration(milliseconds: 300));
    }

    _isSpeaking = true;
    await _tts.setPitch(pitch);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  Future<bool> isSpeaking() async {
    return _isSpeaking;
  }
}
