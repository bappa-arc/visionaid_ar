import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/first_time_setup_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  final prefs = await SharedPreferences.getInstance();
  final isSetupDone = prefs.getBool('isFirstTimeSetupDone') ?? false;
  runApp(AccessibilityApp(isSetupDone: isSetupDone));
}

class AccessibilityApp extends StatelessWidget {
  final bool isSetupDone;
  const AccessibilityApp({required this.isSetupDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisionAid AR',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      //home: FirstTimeSetupScreen(),
      home: isSetupDone ? AccessibilityScreen() : FirstTimeSetupScreen(),
      routes: {
        '/home': (context) => AccessibilityScreen(),
        '/setup': (context) => FirstTimeSetupScreen(),
      },
    );
  }
}
