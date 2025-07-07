import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:visionaid_ar/main.dart';
import 'package:visionaid_ar/screens/fully_blind_screen_tflite.dart';
import 'package:visionaid_ar/screens/settings_screen.dart';
import 'package:visionaid_ar/services/emergency_service.dart';
import '../screens/partially_blind_screen.dart';
import '../screens/color_blind_screen.dart';
import '../widgets/accessibility_option_card.dart';
import 'package:visionaid_ar/screens/ocr_camera_screen.dart';

class AccessibilityScreen extends StatefulWidget {
  @override
  _AccessibilityScreenState createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      AccessibilityOption(
        title: "Fully Blind",
        subtitle: "Navigate with audio",
        icon: Icons.visibility_off,
        onTap: () async {
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.success);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullyBlindTFLScreen(cameras: cameras),
            ),
          );
        },
      ),
      AccessibilityOption(
        title: "Partially Blind",
        subtitle: "Enhance visuals",
        icon: Icons.blur_linear,
        onTap: () async {
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.success);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PartiallyBlindScreen()),
          );
        },
      ),
      AccessibilityOption(
        title: "Color Blind",
        subtitle: "Adjust colors",
        icon: Icons.palette,
        onTap: () async {
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.success);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ColorBlindScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Accessibility Options'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _opacityAnimation,
                    builder:
                        (context, child) => Opacity(
                          opacity: _opacityAnimation.value,
                          child: Icon(
                            Icons.remove_red_eye,
                            size: 60,
                            color: Colors.deepPurple,
                          ),
                        ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Welcome to VisionAid",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Select your visual ability to get started",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 36),
                  ...options.map((opt) => AccessibilityOptionCard(option: opt)),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // OCR Floating Button
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OCRCameraScreen()),
                );
              },
              backgroundColor: Colors.deepPurple,
              icon: Icon(Icons.text_snippet, color: Colors.white),
              label: Text(
                "Smart scan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              tooltip: "Scan Text (OCR)",
            ),
          ),

          // SOS Button
          FloatingActionButton.extended(
            onPressed: () async {
              if (await Vibrate.canVibrate) {
                Vibrate.feedback(FeedbackType.error);
              }
              EmergencyService.activateEmergencyMode();
            },
            icon: Icon(Icons.phone, size: 23, color: Colors.black),
            label: Text(
              "SOS Calls",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
