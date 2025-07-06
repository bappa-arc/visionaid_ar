import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:visionaid_ar/features/fully_blind/tts_helper.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';
import 'dart:async';

class FullyBlindTFLScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FullyBlindTFLScreen({super.key, required this.cameras});

  @override
  State<FullyBlindTFLScreen> createState() => _FullyBlindTFLScreenState();
}

class _FullyBlindTFLScreenState extends State<FullyBlindTFLScreen> {
  late CameraController _controller;
  Future<void>? _initCameraFuture;
  bool isModelLoaded = false;
  List<dynamic>? recognitions;
  bool _isDetecting = false;
  late TTSHelper _ttsHelper;
  DateTime lastSpokenTime = DateTime.now().subtract(const Duration(seconds: 5));
  List<String> lastSpokenLabels = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isDetectionActive = true;
  Timer? _listenTimer;

  @override
  void initState() {
    super.initState();
    _ttsHelper = TTSHelper();
    loadModel();
    initializeCamera(null);
    Future.delayed(Duration(seconds: 1), () {
      _ttsHelper.speak(
        "Welcome to VisionAid fully blind mode. Say help for available commands.",
      );
    });
    Future.delayed(Duration(seconds: 5), () {
      _startListening();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    _listenTimer?.cancel();
    super.dispose();
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: 'assets/models/detect.tflite',
      labels: 'assets/models/labelmap.txt',
    );
    setState(() {
      isModelLoaded = res != null;
    });
  }

  void initializeCamera(CameraDescription? description) async {
    _controller = CameraController(
      description ?? widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initCameraFuture = _controller.initialize();
    await _initCameraFuture;

    if (!mounted) return;

    _controller.startImageStream((CameraImage image) {
      if (isModelLoaded) runModel(image);
    });

    setState(() {});
  }

  void runModel(CameraImage image) async {
    if (!isModelLoaded ||
        _isDetecting ||
        image.planes.isEmpty ||
        !_isDetectionActive)
      return;

    _isDetecting = true;
    try {
      var results = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        model: 'SSDMobileNet',
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 1,
        threshold: 0.4,
      );

      final filtered =
          (results ?? []).where((r) {
            double confidence = r['confidenceInClass'] ?? 0.0;
            final rect = r['rect'];
            return confidence > 0.6 && (rect['w'] > 0.1 || rect['h'] > 0.1);
          }).toList();

      final currentLabels = filtered.map((r) => r['detectedClass']).toList();

      // Speak every 4 seconds if new data is available
      if (filtered.isNotEmpty &&
          DateTime.now().difference(lastSpokenTime).inSeconds > 4 &&
          !listEquals(currentLabels, lastSpokenLabels)) {
        List<String> messages = [];

        for (var r in filtered) {
          final rect = r["rect"];
          final label = r["detectedClass"] ?? "object";

          final centerX = rect["x"] + rect["w"] / 2;
          final direction =
              centerX < 0.33
                  ? "on your left"
                  : centerX > 0.66
                  ? "on your right"
                  : "in front of you";

          final distance =
              rect["h"] > 0.4
                  ? "very close"
                  : rect["h"] > 0.2
                  ? "close"
                  : "far";

          messages.add("$label $direction, $distance");
        }

        final sentence = messages.join(". ");
        _ttsHelper.speak(sentence);
        Vibrate.feedback(FeedbackType.success);
        lastSpokenTime = DateTime.now();
        lastSpokenLabels = currentLabels.cast<String>();
      }

      setState(() {
        recognitions = results;
      });
    } catch (e) {
      _ttsHelper.speak("Object detection failed. Please try again.");
      Vibrate.feedback(FeedbackType.error);
      print("Error: $e");
    }
    _isDetecting = false;
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "notListening") {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        _ttsHelper.speak("Speech recognition error.");
        Vibrate.feedback(FeedbackType.error);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          _onSpeechResult(val.recognizedWords);
          _stopListening();
        },
        localeId: "en_US",
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 2),
        partialResults: false,
      );
      _listenTimer?.cancel();
      _listenTimer = Timer(const Duration(seconds: 6), _stopListening);
    } else {
      _ttsHelper.speak("Speech recognition not available.");
      Vibrate.feedback(FeedbackType.error);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    _listenTimer?.cancel();
  }

  void _onSpeechResult(String command) async {
    command = command.toLowerCase();

    if (command.contains("exit") || command.contains("back")) {
      _ttsHelper.speak("Going back");
      Navigator.pop(context);
      Vibrate.feedback(FeedbackType.light);
    } else if (command.contains("help")) {
      _ttsHelper.speak(
        "Say: back, exit, help, start, stop, repeat, what, emergency, light on, light off.",
      );
      Vibrate.feedback(FeedbackType.light);
    } else if (command.contains("start")) {
      if (!_isDetectionActive) {
        setState(() => _isDetectionActive = true);
        _ttsHelper.speak("Object detection started.");
        Vibrate.feedback(FeedbackType.light);
      } else {
        _ttsHelper.speak("Detection is already running.");
        Vibrate.feedback(FeedbackType.heavy);
      }
    } else if (command.contains("stop")) {
      if (_isDetectionActive) {
        setState(() => _isDetectionActive = false);
        _ttsHelper.speak("Object detection stopped.");
        Vibrate.feedback(FeedbackType.light);
      } else {
        _ttsHelper.speak("Detection is already stopped.");
        Vibrate.feedback(FeedbackType.heavy);
      }
    } else if (command.contains("repeat")) {
      if (lastSpokenLabels.isNotEmpty) {
        final sentence = lastSpokenLabels.join(", ");
        _ttsHelper.speak("Last seen: $sentence");
        Vibrate.feedback(FeedbackType.success);
      } else {
        _ttsHelper.speak("Nothing detected recently.");
        Vibrate.feedback(FeedbackType.heavy);
      }
    } else if (command.contains("scan") ||
        command.contains("describe") ||
        command.contains("what")) {
      _ttsHelper.speak("Scanning now...");
      lastSpokenTime = DateTime.now().subtract(const Duration(seconds: 5));
    } else if (command.contains("emergency")) {
      _ttsHelper.speak("Emergency mode activated.");
      Vibrate.feedback(FeedbackType.error);
      // Add emergency handling logic here
    } else if (command.contains("light on")) {
      try {
        await _controller.setFlashMode(FlashMode.torch);
        _ttsHelper.speak("Flashlight turned on.");
        Vibrate.feedback(FeedbackType.light);
      } catch (_) {
        _ttsHelper.speak("Failed to turn on flashlight.");
        Vibrate.feedback(FeedbackType.heavy);
      }
    } else if (command.contains("light off")) {
      try {
        await _controller.setFlashMode(FlashMode.off);
        _ttsHelper.speak("Flashlight turned off.");
        Vibrate.feedback(FeedbackType.light);
      } catch (_) {
        _ttsHelper.speak("Failed to turn off flashlight.");
        Vibrate.feedback(FeedbackType.heavy);
      }
    } else if (command.contains("settings")) {
      Vibrate.feedback(FeedbackType.light);
      _ttsHelper.speak("Settings not available yet.");
    } else {
      _ttsHelper.speak("Command not recognized.");
      Vibrate.feedback(FeedbackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final screen = MediaQuery.of(context).size;
    final previewSize = _controller.value.previewSize!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initCameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller)),
                if (recognitions != null && recognitions!.isNotEmpty)
                  BoundingBoxes(
                    recognitions: recognitions!,
                    previewH: previewSize.height,
                    previewW: previewSize.width,
                    screenH: screen.height,
                    screenW: screen.width,
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Text(
                          "Fully Blind Mode",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black),
                            ],
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      _isListening ? _stopListening() : _startListening();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 13),
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            _isListening
                                ? const Color.fromARGB(255, 157, 168, 230)
                                : Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                          bottom: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 32,
                        color: _isListening ? Colors.redAccent : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class BoundingBoxes extends StatelessWidget {
  final List<dynamic> recognitions;
  final double previewH;
  final double previewW;
  final double screenH;
  final double screenW;

  const BoundingBoxes({
    super.key,
    required this.recognitions,
    required this.previewH,
    required this.previewW,
    required this.screenH,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    // Determine scaling factors
    double scaleX = screenW / previewW;
    double scaleY = screenH / previewH;

    return Stack(
      children:
          recognitions.map((rec) {
            final rect = rec["rect"];

            double x = rect["x"] * previewW * scaleX;
            double y = rect["y"] * previewH * scaleY;
            double w = rect["w"] * previewW * scaleX;
            double h = rect["h"] * previewH * scaleY;

            return Positioned(
              left: x,
              top: y,
              width: w,
              height: h,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Text(
                  "${rec["detectedClass"] ?? 'Unknown'} ${(rec["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    backgroundColor: Colors.black54,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
