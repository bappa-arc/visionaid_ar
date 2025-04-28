import 'package:flutter/material.dart';

class AccessibilityOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  AccessibilityOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class AccessibilityOptionCard extends StatelessWidget {
  final AccessibilityOption option;

  const AccessibilityOptionCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: option.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        child: ListTile(
          leading: Icon(option.icon, size: 32, color: Colors.blueAccent),
          title: Text(
            option.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(option.subtitle),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
