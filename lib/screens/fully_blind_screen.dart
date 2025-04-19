import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:visionaid_ar/features/tts_helper.dart';
import 'dart:io';

class FullyBlindScreen extends StatefulWidget {
  @override
  _FullyBlindScreenState createState() => _FullyBlindScreenState();
}

class _FullyBlindScreenState extends State<FullyBlindScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final tts = TTSHelper();
  late ObjectDetector _objectDetector;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initObjectDetector();
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
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Future<void> _detectObjects() async {
    try {
      await _initializeControllerFuture;

      final tempDir = await getTemporaryDirectory();
      final imagePath = join(tempDir.path, '${DateTime.now()}.jpg');
      await _controller.takePicture().then((file) async {
        final inputImage = InputImage.fromFilePath(file.path);
        final objects = await _objectDetector.processImage(inputImage);

        if (objects.isEmpty) {
          tts.speak("No object detected");
        } else {
          for (final obj in objects) {
            final label =
                obj.labels.isNotEmpty ? obj.labels.first.text : "an object";
            tts.speak("Detected $label");
          }
        }
      });
    } catch (e) {
      print("Error detecting objects: $e");
      tts.speak("Failed to detect objects");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fully Blind Mode"),
        backgroundColor: const Color.fromARGB(255, 157, 168, 230),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed:
                    () => tts.speak(
                      "Camera is active. Tap detect to identify objects.",
                    ),
                child: Text("Speak"),
              ),
              ElevatedButton(onPressed: _detectObjects, child: Text("Detect")),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
