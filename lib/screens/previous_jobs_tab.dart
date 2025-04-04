import 'package:flutter/material.dart';

class PreviousJobsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _JobCard(
          title: 'E-Commerce App',
          client: 'Client X',
          amount: '\$1,200',
          status: 'Completed',
          color: Colors.green,
        ),
        _JobCard(
          title: 'Portfolio Website',
          client: 'Client Y',
          amount: '\$800',
          status: 'In Progress',
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String client;
  final String amount;
  final String status;
  final Color color;

  const _JobCard({
    required this.title,
    required this.client,
    required this.amount,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Client: $client'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(amount, style: TextStyle(color: Colors.tealAccent[200])),
                Chip(
                  label: Text(status),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}