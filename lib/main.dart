import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(AccessibilityApp());

class AccessibilityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessibility Options',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AccessibilityScreen(), // 👈 Using the screen from home_screen.dart
    );
  }
}
