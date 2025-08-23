import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nazra App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildMenuItem("Listen Nazra", Icons.hearing, context, "/listen"),
            _buildMenuItem("Listening Exercise", Icons.headphones, context, "/lstnex"),
            //_buildMenuItem("Compound Letters", Icons.text_fields, context, "/words"),
            //_buildMenuItem("Use of Zabar", Icons.format_quote, context, "/sentences"),
            //_buildMenuItem("Use of Zair", Icons.format_quote, context, "/zair"),
            //_buildMenuItem("Use of Paish", Icons.format_quote, context, "/paish"),
            _buildMenuItem("Speech Exercise", Icons.speaker, context, "/speech"),
            _buildMenuItem("Speech Test", Icons.speaker_notes, context, "/sptest"),
            //_buildMenuItem("Exercise", Icons.home_work, context, "/game"),
            //_buildMenuItem("Settings", Icons.settings, context, "/settings"),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, BuildContext context, String route) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
