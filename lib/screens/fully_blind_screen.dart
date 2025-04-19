import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:visionaid_ar/features/tts_helper.dart';

class FullyBlindScreen extends StatefulWidget {
  @override
  _FullyBlindScreenState createState() => _FullyBlindScreenState();
}

class _FullyBlindScreenState extends State<FullyBlindScreen> {
  CameraController? _controller;
  Future<void>? _initCameraFuture;
  final tts = TTSHelper();
  late ObjectDetector _objectDetector;

  @override
  void initState() {
    super.initState();
    _initObjectDetector();
    _initCamera();
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
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      _initCameraFuture = _controller!.initialize();
      await _initCameraFuture;
      setState(() {}); // trigger rebuild after camera is ready
    } catch (e) {
      print("Camera init error: $e");
      tts.speak("Camera initialization failed.");
    }
  }

  Future<void> _detectObjects() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;
      final tempDir = await getTemporaryDirectory();
      final imagePath = join(tempDir.path, '${DateTime.now()}.jpg');
      await _controller!.takePicture().then((file) async {
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
      print("Detection error: $e");
      tts.speak("Object detection failed.");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
      body:
          _controller == null
              ? Center(child: Text("Loading camera..."))
              : FutureBuilder(
                future: _initCameraFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        Expanded(child: CameraPreview(_controller!)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  () =>
                                      tts.speak("Camera is ready. Tap detect."),
                              child: Text("Speak"),
                            ),
                            ElevatedButton(
                              onPressed: _detectObjects,
                              child: Text("Detect"),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Camera Error: ${snapshot.error}"),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
    );
  }
}
