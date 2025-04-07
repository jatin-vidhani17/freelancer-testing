import 'package:flutter/material.dart';
import 'package:freelancer_app/models/job_post.dart';
import 'package:freelancer_app/widgets/job_card.dart';
import 'package:freelancer_app/screens/profile/profile_screen.dart';
import 'package:freelancer_app/screens/settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadMoreJobs() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      // TODO: Implement job loading logic
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            // TODO: Replace with actual job posts data
            return const JobCard();
          },
        ),
      ),
      bottomNavigationBar: _isLoading
          ? const LinearProgressIndicator()
          : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}