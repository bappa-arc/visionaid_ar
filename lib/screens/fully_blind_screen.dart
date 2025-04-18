import 'package:flutter/material.dart';

class FullyBlindScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fully Blind Mode")),
      body: Center(
        child: Text(
          "Welcome to Fully Blind Mode",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
