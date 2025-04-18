import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accessibility Options'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: () {
              print("Mic icon pressed");
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              print("Settings icon pressed");
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            '*Select Your Visual Ability*',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 20),

          // Fully Blind
          Card(
            child: ListTile(
              leading: Icon(Icons.visibility_off, color: Colors.black),
              title: Text('Fully Blind'),
              subtitle: Text('Navigate with audio'),
              onTap: () {
                print('Fully Blind selected');
              },
            ),
          ),

          // Partially Blind
          Card(
            child: ListTile(
              leading: Icon(Icons.remove_red_eye_outlined, color: Colors.black),
              title: Text('Partially Blind'),
              subtitle: Text('Enhance visuals'),
              onTap: () {
                print('Partially Blind selected');
              },
            ),
          ),

          // Color Blind
          Card(
            child: ListTile(
              leading: Icon(Icons.palette, color: Colors.black),
              title: Text('Color Blind'),
              subtitle: Text('Adjust colors'),
              onTap: () {
                print('Color Blind selected');
              },
            ),
          ),

          // Normal
          Card(
            child: ListTile(
              leading: Icon(Icons.visibility, color: Colors.black),
              title: Text('Normal'),
              subtitle: Text('Default settings'),
              onTap: () {
                print('Normal selected');
              },
            ),
          ),

          // SOS Calls
          Card(
            child: ListTile(
              leading: Icon(Icons.phone_in_talk, color: Colors.red),
              title: Text('SOS Calls'),
              subtitle: Text('Emergency assistance'),
              onTap: () {
                print('SOS Calls selected');
              },
            ),
          ),
        ],
      ),
    );
  }
}
