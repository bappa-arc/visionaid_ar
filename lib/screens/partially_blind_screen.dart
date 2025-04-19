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
              margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Select View Mode",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModeButton(
                          icon: Icons.remove_red_eye,
                          labelText: "Normal",
                          color: Colors.blue.shade300,
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        _buildModeButton(
                          icon: Icons.blur_on,
                          labelText: "Edge Detection",
                          color: Colors.orange.shade300,
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        _buildModeButton(
                          icon: Icons.contrast,
                          labelText: "High Contrast",
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
    required String labelText,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: Duration(milliseconds: 100),
      builder: (context, scale, child) {
        return GestureDetector(
          onTapDown: (_) => scale = 0.95, // animation start
          onTapUp: (_) => scale = 1.0, // animation end
          child: AnimatedScale(
            scale: scale,
            duration: Duration(milliseconds: 100),
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                icon,
                size: 23, // bigger icon
                color: Colors.black, // high contrast
              ),
              label: Text(
                labelText,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18, // bigger text
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color, // accessible background
                minimumSize: Size(130, 45), // large tap target
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
