import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About RePharma',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            SizedBox(height: 20),
            Text(
              'RePharma is an Egyptian Drug Platform designed to help users easily search for medicines, get detailed information, and set reminders for their medication schedules.\n\n'
              'Key features include:\n'
              '- Medicine search in both English and Arabic\n'
              '- Personalized medicine alerts and reminders\n'
              '- Latest health and pharmaceutical news\n'
              '- Contact support and user profile management\n\n'
              'Our mission is to make medicine information and reminders accessible for everyone, helping you stay healthy and organized.',
              style: TextStyle(fontSize: 18, color: Colors.blueGrey[800]),
            ),
          ],
        ),
      ),
    );
  }
} 