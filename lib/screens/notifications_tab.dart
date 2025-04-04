import 'package:flutter/material.dart';

class NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _NotificationTile(
          icon: Icons.work,
          title: 'New Job Offer',
          subtitle: 'UI Designer - \$40/hr',
          time: '2h ago',
          isUnread: true,
        ),
        _NotificationTile(
          icon: Icons.account_circle,
          title: 'Profile Viewed',
          subtitle: 'By Client X',
          time: '1d ago',
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnread ? Colors.blueGrey[800] : Colors.grey[850],
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.tealAccent[200]!.withOpacity(0.2),
          child: Icon(icon, color: Colors.tealAccent[200]),
        ),
        title: Text(title, style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        )),
        subtitle: Text(subtitle),
        trailing: Text(time, style: TextStyle(color: Colors.grey[400])),
      ),
    );
  }
}