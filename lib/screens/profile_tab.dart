import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
          SizedBox(height: 10),
          Text('John Doe', style: Theme.of(context).textTheme.headlineSmall),
          Text('Flutter Developer | UI/UX Enthusiast'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
            child: Text('Edit Profile'),
          ),
          SizedBox(height: 20),
          Text('Skills: Flutter, Dart, Firebase'),
          Text('Portfolio: [Link to portfolio]'),
        ],
      ),
    );
  }
}