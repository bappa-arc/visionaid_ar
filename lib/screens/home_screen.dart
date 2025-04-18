import 'package:flutter/material.dart';
import '../screens/fully_blind_screen.dart';
import '../screens/partially_blind_screen.dart';
import '../screens/color_blind_screen.dart';
import '../screens/normal_user_screen.dart';
import '../widgets/accessibility_option_card.dart';

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
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(_controller);
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
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FullyBlindScreen()),
            ),
      ),
      AccessibilityOption(
        title: "Partially Blind",
        subtitle: "Enhance visuals",
        icon: Icons.blur_linear,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PartiallyBlindScreen()),
            ),
      ),
      AccessibilityOption(
        title: "Color Blind",
        subtitle: "Adjust colors",
        icon: Icons.palette,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ColorBlindScreen()),
            ),
      ),
      AccessibilityOption(
        title: "Normal",
        subtitle: "Default settings",
        icon: Icons.visibility,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NormalUserScreen()),
            ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Accessibility Options'),
        backgroundColor: const Color.fromARGB(255, 157, 168, 230),
        actions: [
          IconButton(icon: Icon(Icons.mic), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _opacityAnimation,
                builder:
                    (context, child) => Opacity(
                      opacity: _opacityAnimation.value,
                      child: Icon(
                        Icons.remove_red_eye,
                        size: 48,
                        color: Colors.blue,
                      ),
                    ),
              ),
              SizedBox(height: 12),
              Text(
                "Select Your Visual Ability",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24),
              ...options.map((opt) => AccessibilityOptionCard(option: opt)),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // SOS action goes here
        },
        icon: Icon(Icons.phone, color: Colors.black),
        label: Text("SOS Calls"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
