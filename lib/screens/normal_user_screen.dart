import 'package:flutter/material.dart';

class NormalUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Normal User Mode")),
      body: Center(
        child: Text(
          "Welcome to Normal User Mode",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
