import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:visionaid_ar/features/fully_blind/tts_helper.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FullyBlindScreen extends StatefulWidget {
  @override
  _FullyBlindScreenState createState() => _FullyBlindScreenState();
}

class _FullyBlindScreenState extends State<FullyBlindScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initCameraFuture;
  final tts = TTSHelper();
  late ObjectDetector _objectDetector;
  bool _isDetecting = false;
  bool _keepDetecting = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isVoiceCommandActive = false;
  String _lastDetectedLabel = "";
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double screenWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _speech = stt.SpeechToText();
    Future.delayed(Duration(seconds: 1), () {
      tts.speak(
        "Welcome to VisionAid fully blind mode. Say help for available commands.",
      );
    });
    _initObjectDetector();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.stop();
  }

  void _startDetectionLoop() async {
    _isDetecting = false;
    while (_keepDetecting) {
      if (!_isDetecting && !_isVoiceCommandActive) {
        _isDetecting = true;
        //double screenWidth = MediaQuery.of(context).size.width;
        await _detectObjects(screenWidth);
        _isDetecting = false;
      }
      await Future.delayed(Duration(seconds: 5));
    }
  }

  void _initObjectDetector() {
    final options = ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.single,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<void> _initCamera() async {
    try {
      final available = await availableCameras();
      _controller = CameraController(available[0], ResolutionPreset.medium);
      _initCameraFuture = _controller!.initialize();
      await _initCameraFuture;
      _startDetectionLoop();
      setState(() {});
    } catch (e) {
      print("Camera init error: $e");
      await tts.speak("Camera initialization failed.");
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.error);
      }
    }
  }

  Future<void> _detectObjects(double screenWidth) async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      final tempDir = await getTemporaryDirectory();
      final imagePath = join(tempDir.path, '${DateTime.now()}.jpg');

      final file = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final objects = await _objectDetector.processImage(inputImage);

      if (_isVoiceCommandActive) return;

      if (objects.isEmpty) {
        await tts.speak("No object detected.");
      } else {
        List<String> descriptions = [];
        //double screenWidth = MediaQuery.of(context as BuildContext).size.width;

        for (final obj in objects) {
          final rect = obj.boundingBox;
          final centerX = rect.left + rect.width / 2;
          final width = rect.width;
          final height = rect.height;
          double area = width * height;

          String? label = obj.labels.isNotEmpty ? obj.labels.first.text : null;
          if (label == null) continue;

          String position;
          if (centerX < screenWidth * 0.33) {
            position = "on your left";
          } else if (centerX > screenWidth * 0.66) {
            position = "on your right";
          } else {
            position = "ahead";
          }

          String distance;
          if (area > 300000) {
            distance = "very close";
          } else if (area > 150000) {
            distance = "nearby";
          } else {
            distance = "a few meters away";
          }

          descriptions.add("$label $distance $position");
          _lastDetectedLabel = label;
        }

        if (descriptions.isEmpty) {
          await tts.speak("Objects detected but not recognized.");
        } else {
          final message = "Detected ${descriptions.join(", ")}.";
          await tts.speak(message);
        }

        if (await Vibrate.canVibrate) {
          Vibrate.feedback(FeedbackType.success);
        }
      }
    } catch (e) {
      print("Detection error: $e");
      await tts.speak("Object detection failed.");
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.error);
      }
    }
  }

  void _startListening() async {
    if (await tts.isSpeaking()) {
      await tts.stop();
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done') {
          _animationController.stop();
          _animationController.reset();
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        print('Speech error: $error');
        _animationController.stop();
        _animationController.reset();
        setState(() {
          _isListening = false;
        });
      },
    );

    if (!available) {
      tts.speak("Speech recognition not available");
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.error);
      }
      return;
    }

    _speech.listen(
      listenMode: stt.ListenMode.confirmation,
      partialResults: false,
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 3),
      onResult: (result) async {
        _animationController.stop();
        _animationController.reset();

        final command = result.recognizedWords.toLowerCase().trim();
        print("Heard command: $command");

        if (command.isEmpty) return;

        if (await tts.isSpeaking()) {
          await tts.stop();
        }

        if (command.contains("repeat")) {
          _keepDetecting = false;
          tts.speak("Last detected: $_lastDetectedLabel");
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.light);
          }
          _keepDetecting = true;
        } else if (command.contains("emergency")) {
          _keepDetecting = false;
          tts.speak("Emergency mode activated");
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.error);
          }
        } else if (command.contains("stop")) {
          _keepDetecting = false;
          tts.speak("Stopped detection");
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.light);
          }
        } else if (command.contains("start")) {
          _keepDetecting = true;
          _startDetectionLoop();
          tts.speak("Resumed detection");
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.light);
          }
        } else if (command.contains("help")) {
          _keepDetecting = false;
          tts.speak("Say: Repeat, Emergency, Stop, Start or Help");
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.light);
          }
          _keepDetecting = true;
        } else {
          tts.speak("Command not recognized");
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.error);
          }
        }
        _animationController.repeat(reverse: true);
        setState(() {
          _isListening = false;
        });
      },
    );

    setState(() {
      _isListening = true;
    });
  }

  @override
  void dispose() {
    _keepDetecting = false;
    _controller?.dispose();
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body:
          _controller == null
              ? Center(child: Text("Loading camera..."))
              : FutureBuilder(
                future: _initCameraFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      children: [
                        Positioned.fill(child: CameraPreview(_controller!)),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
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
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 122),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ScaleTransition(
                            scale:
                                _isListening
                                    ? _scaleAnimation
                                    : AlwaysStoppedAnimation(1.0),
                            child: GestureDetector(
                              onTap: _startListening,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 13),
                                margin: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
    );
  }
}
