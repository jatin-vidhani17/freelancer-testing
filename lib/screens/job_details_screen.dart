import 'package:flutter/material.dart';

class JobDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile App Developer', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 10),
            Text('\$50/hr | Remote'),
            SizedBox(height: 20),
            Text('Description: Build a Flutter app for a startup.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Apply for job logic
              },
              child: Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }
}