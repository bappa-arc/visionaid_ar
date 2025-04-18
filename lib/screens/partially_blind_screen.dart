import 'package:flutter/material.dart';

class PartiallyBlindScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Partially Blind Mode")),
      body: Center(
        child: Text(
          "Welcome to Partially Blind Mode",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
