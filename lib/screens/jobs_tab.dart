import 'package:flutter/material.dart';
import 'job_details_screen.dart';

class JobsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search Jobs',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Mobile App Developer'),
                  subtitle: Text('\$50/hr | Remote'),
                  trailing: Icon(Icons.bookmark_border),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobDetailsScreen()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Graphic Designer'),
                  subtitle: Text('\$30/hr | Part-time'),
                  trailing: Icon(Icons.bookmark_border),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobDetailsScreen()),
                    );
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