import 'package:flutter/material.dart';

class ColorBlindScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Color Blind Mode")),
      body: Center(
        child: Text(
          "Welcome to Color Blind Mode",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
