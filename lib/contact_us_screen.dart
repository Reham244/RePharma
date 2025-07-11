import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text('support@repharma.com', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text('+20 100 123 4567', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text('123 Cairo St, Nasr City, Cairo, Egypt', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 32),
            Text('Or use the form below (coming soon).', style: TextStyle(fontSize: 16, color: Colors.blueGrey[700])),
          ],
        ),
      ),
    );
  }
} 