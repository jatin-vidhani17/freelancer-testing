import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MessagesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text('C')),
            title: Text('Client A'),
            subtitle: Text('Hey, can you start tomorrow?'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
          ListTile(
            leading: CircleAvatar(child: Text('F')),
            title: Text('Freelancer B'),
            subtitle: Text('Let’s collaborate!'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
