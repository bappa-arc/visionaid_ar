import 'package:flutter/material.dart';

class AccessibilityScreen extends StatefulWidget {
  @override
  _AccessibilityScreenState createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  final List<_AccessibilityOption> options = [
    _AccessibilityOption(
      title: "Fully Blind",
      subtitle: "Navigate with audio",
      icon: Icons.visibility_off,
      onTap: () {},
    ),
    _AccessibilityOption(
      title: "Partially Blind",
      subtitle: "Enhance visuals",
      icon: Icons.blur_linear,
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
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Accessibility Options'),
  backgroundColor: const Color.fromARGB(255, 157, 168, 230),
  actions: [
    IconButton(
      icon: Icon(Icons.mic),
      onPressed: () {
        print("Mic icon pressed");
        // Add your action for the mic button here
      },
    ),
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        print("Settings icon pressed");
        // Add your action for the settings button here
      },
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) => Opacity(
                opacity: _opacityAnimation.value,
                child: Icon(Icons.remove_red_eye, size: 48, color: Colors.blue),
              ),
            ),
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
                onPressed: () {},
                icon: Icon(Icons.phone, color: const Color.fromARGB(255, 0, 0, 0)),
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
