import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'jobs_tab.dart';
import 'messages_tab.dart';
import 'settings_screen.dart';
import 'previous_jobs_tab.dart';
import 'notifications_tab.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static List<Widget> _pages = <Widget>[
    HomeTab(),
    JobsTab(),
    PreviousJobsTab(), // New tab
    MessagesTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[900],
      drawer: _buildDrawer(context),
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            radius: 16,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text('Freelancer Hub'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text('3', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsTab(),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[800],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.tealAccent[200],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                ),
                SizedBox(height: 10),
                Text('John Doe', style: TextStyle(fontSize: 18)),
                Text('john.doe@example.com',
                    style: TextStyle(color: Colors.grey[300])),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.grey[300]),
            title: Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Add profile screen navigation
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey[300]),
            title: Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey[300]),
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Add logout logic
            },
          ),
        ],
      ),
    );
  }
}
