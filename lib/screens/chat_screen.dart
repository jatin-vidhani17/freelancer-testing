import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with Client A')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(title: Text('Client A: Hey, can you start tomorrow?')),
                ListTile(title: Text('You: Yes, I’m available!')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(decoration: InputDecoration(hintText: 'Type a message')),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Send message logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}