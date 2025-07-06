import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_result_screen.dart';

class OCRCameraScreen extends StatefulWidget {
  @override
  _OCRCameraScreenState createState() => _OCRCameraScreenState();
}

class _OCRCameraScreenState extends State<OCRCameraScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _startOCRProcess();
  }

  Future<void> _startOCRProcess() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) {
      Navigator.pop(context); // User canceled
      return;
    }

    final inputImage = InputImage.fromFile(File(photo.path));
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    String resultText = recognizedText.text.trim();
    if (resultText.isEmpty) resultText = "No readable text found.";

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OCRResultScreen(text: resultText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
