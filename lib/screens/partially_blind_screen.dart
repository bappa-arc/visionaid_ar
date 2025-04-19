import 'package:flutter/material.dart';

class PartiallyBlindScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Partially Blind Mode"),
          backgroundColor: const Color.fromARGB(255, 157, 168, 230),
        ),
        body: Column(
          children: [
            // Camera View section with border and background
            Expanded(
              flex: 8,
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Center(
                  child: Text(
                    "Camera View (Coming Soon)",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            // View Mode section with border and fixed position
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select View Mode",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModeButton(
                          icon: Icons.remove_red_eye,
                          label: "Normal",
                          color: Colors.blue.shade300,
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        _buildModeButton(
                          icon: Icons.blur_on,
                          label: "Edge Detection",
                          color: Colors.orange.shade300,
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        _buildModeButton(
                          icon: Icons.contrast,
                          label: "High Contrast",
                          color: const Color.fromARGB(255, 191, 171, 224),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
