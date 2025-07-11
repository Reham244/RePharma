import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Medicine Approved: Paracetamol XR',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The Ministry of Health has approved Paracetamol XR, a new extended-release pain reliever for chronic pain management. Now available in pharmacies across Egypt.',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey[800]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Published: June 2024',
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'More news coming soon...',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 