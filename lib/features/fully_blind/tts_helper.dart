import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSHelper {
  static final TTSHelper _instance = TTSHelper._internal();
  final FlutterTts _flutterTts = FlutterTts();

  bool ttsEnabled = true;
  double ttsRate = 0.5;
  String ttsVoice = 'female'; // Default to female voice

  factory TTSHelper() => _instance;

  TTSHelper._internal() {
    _loadTTSSettings();
  }

  Future<void> _loadTTSSettings() async {
    final prefs = await SharedPreferences.getInstance();
    ttsEnabled = prefs.getBool('ttsEnabled') ?? true;
    ttsRate = prefs.getDouble('ttsRate') ?? 0.5;
    ttsVoice = prefs.getString('ttsVoice') ?? 'female';
    _applyTTSSettings();
  }

  Future<void> _applyTTSSettings() async {
    await _flutterTts.setSpeechRate(ttsRate);

    // Set voice based on the selected gender
    final voices = await _flutterTts.getVoices;
    final selectedVoice = voices.firstWhere(
      (voice) => voice.contains(ttsVoice),
      orElse: () => voices.first,
    );
    await _flutterTts.setVoice(selectedVoice);
  }

  Future<void> speak(String text) async {
    if (ttsEnabled) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> updateTTSSettings({
    required bool enabled,
    required double rate,
    required String voice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ttsEnabled', enabled);
    await prefs.setDouble('ttsRate', rate);
    await prefs.setString('ttsVoice', voice);

    ttsEnabled = enabled;
    ttsRate = rate;
    ttsVoice = voice;

    _applyTTSSettings();
  }
}
