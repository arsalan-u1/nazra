import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text("User Name", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("Progress: 50%", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
