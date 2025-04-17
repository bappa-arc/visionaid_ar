import 'package:flutter/material.dart';
//import 'package:lucide_icons/lucide_icons.dart'; // Optional for better icons

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
      home: AccessibilityScreen(),
    );
  }
}

class AccessibilityScreen extends StatelessWidget {
  final List<_AccessibilityOption> options = [
    _AccessibilityOption(
      title: "Fully Blind",
      subtitle: "Navigate with audio",
      icon: Icons.accessibility_new,
      onTap: () {}, // Add your action
    ),
    _AccessibilityOption(
      title: "Partially Blind",
      subtitle: "Enhance visuals",
      icon: Icons.remove_red_eye,
      onTap: () {},
    ),
    _AccessibilityOption(
      title: "Color Blind",
      subtitle: "Adjust colors",
      icon: Icons.palette,
      onTap: () {},
    ),
    _AccessibilityOption(
      title: "Normal",
      subtitle: "Default settings",
      icon: Icons.visibility,
      onTap: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accessibility Options"),
        actions: [
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {}, // Voice control
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.remove_red_eye, size: 48, color: Colors.blue),
            SizedBox(height: 12),
            Text(
              "Select Your Visual Ability",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            ...options.map((opt) => _buildOptionCard(context, opt)),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: () {}, // SOS functionality
                icon: Icon(Icons.phone, color: Colors.white),
                label: Text("SOS Calls"),
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, _AccessibilityOption opt) {
    return GestureDetector(
      onTap: opt.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        child: ListTile(
          leading: Icon(opt.icon, size: 32, color: Colors.blueAccent),
          title: Text(opt.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          subtitle: Text(opt.subtitle),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}

class _AccessibilityOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _AccessibilityOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
