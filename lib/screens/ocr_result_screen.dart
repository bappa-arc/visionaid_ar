import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class OCRResultScreen extends StatefulWidget {
  final String text;

  OCRResultScreen({required this.text});

  @override
  _OCRResultScreenState createState() => _OCRResultScreenState();
}

class _OCRResultScreenState extends State<OCRResultScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speakText() async {
    await _flutterTts.setSpeechRate(0.5); // slower for clarity
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.speak(widget.text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Detected Text",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8EC5FC),
              Color(0xFFE0C3FC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Scrollable content
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 90), // bottom padding for button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.text_snippet_rounded, size: 64, color: Colors.deepPurple.shade400),
                    SizedBox(height: 18),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: Colors.white.withOpacity(0.92),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Button removed from here!
                    SizedBox(height: 24),
                  ],
                ),
              ),
              // Floating button
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _speakText,
                    icon: Icon(Icons.volume_up, size: 32),
                    label: Text(
                      "Read Aloud",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}