import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Tips(),
    );
  }
}

class Tips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tips'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'About Our Calendar App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Image.asset('assets/images.jpeg'), // Add this line to display the image
            SizedBox(height: 16),
            Text(
              'Welcome to our Calendar App! We\'re dedicated to helping you manage your time effectively and stay organized.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildFeatureItem('Easy event management'),
            _buildFeatureItem('Monthly and weekly views'),
            _buildFeatureItem('Intuitive user interface'),
            SizedBox(height: 16),
            Text(
              'Our Team',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildTeamMember('Joshua', 'Leader'),
            _buildTeamMember('Thomas', 'Members'),
            _buildTeamMember('Kitty', 'Members'),
            _buildTeamMember('Matthew', 'Members'),
            _buildTeamMember('Zenobio', 'Members'),
            SizedBox(height: 16),
            Text(
              'More information:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'NA',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green),
          SizedBox(width: 8),
          Text(feature, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(role, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}