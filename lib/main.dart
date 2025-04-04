import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(FreelancerApp());
}

class FreelancerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancer Hub',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[800],
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.tealAccent[200]!,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}