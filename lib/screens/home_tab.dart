import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<Map<String, dynamic>> _jobPosts = [];
  late WebSocketChannel _channel;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showFullDescription = false;
  bool _isConnected = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initConnection();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initConnection() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      await _connectToWebSocket();

      setState(() {
        _isConnected = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to connect: ${e.toString()}';
        _isLoading = false;
      });
      _scheduleReconnect();
    }
  }

  Future<void> _connectToWebSocket() async {
    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://websocket-app-api.onrender.com/jobs'),
    );

    _channel.stream.listen(
      (message) {
        try {
          final data = json.decode(message);
          if (data['type'] == 'added') {
            setState(() {
              _jobPosts.insert(0, data['data']); // Newest first
            });
          }
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
      onError: (error) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Connection error: ${error.toString()}';
          _isConnected = false;
        });
        _scheduleReconnect();
      },
      onDone: () {
        setState(() {
          _isConnected = false;
        });
        _scheduleReconnect();
      },
    );
  }

  void _scheduleReconnect() {
    Future.delayed(Duration(seconds: 5), () {
      if (!_isConnected) {
        _initConnection();
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _loadMoreJobs();
    }
  }

  Future<void> _loadMoreJobs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 2));

      // In production, you would make an actual API call here
      // For demo, we'll just add a loading indicator

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load more jobs';
      });
    }
  }

  Future<void> _refreshJobs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Clear existing posts
      setState(() {
        _jobPosts.clear();
      });

      // Reconnect to get fresh data
      await _initConnection();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Refresh failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isConnected ? 'Connected to live feed' : 'Connecting...',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError && _jobPosts.isEmpty) {
      return Center(
        child: ErrorPlaceholder(
          message: _errorMessage,
          onRetry: _initConnection,
        ),
      );
    }

    if (_isLoading && _jobPosts.isEmpty) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          if (_hasError)
            ConnectionStatusBanner(
              message: _errorMessage,
              isError: true,
              onRetry: _initConnection,
            ),
          if (!_isConnected)
            ConnectionStatusBanner(
              message: 'Reconnecting...',
              isError: false,
            ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshJobs,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _jobPosts.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _jobPosts.length) {
                    return _buildLoader();
                  }

                  final job = _jobPosts[index];
                  return JobPostCard(
                    job: job,
                    onToggleDescription: () {
                      setState(() {
                        _showFullDescription = !_showFullDescription;
                      });
                    },
                    showFullDescription: _showFullDescription,
                    onViewDetails: () {
                      _showJobDetails(context, job);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailsModal(job: job),
    );
  }
}

// Custom Widgets for better organization and reusability

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Loading jobs...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class ErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorPlaceholder({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }
}

class ConnectionStatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  const ConnectionStatusBanner({
    super.key,
    required this.message,
    required this.isError,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isError ? Colors.red[50] : Colors.blue[50],
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: isError ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red : Colors.blue,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'RETRY',
                style: TextStyle(
                  color: isError ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class JobPostCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onToggleDescription;
  final bool showFullDescription;
  final VoidCallback onViewDetails;

  const JobPostCard({
    super.key,
    required this.job,
    required this.onToggleDescription,
    required this.showFullDescription,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final description = job['description'] ?? 'No description provided';
    final maxLines = showFullDescription ? null : 3;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job['job_title'] ?? 'Untitled Job',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.bookmark_border,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.work_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job['job_category'] ?? 'General',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.payment, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job['payment_type'] ?? 'Not specified',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Budget: \₹${job['budget']?.toString() ?? 'Not specified'}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Description:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
            if (description.length > 100) ...[
              TextButton(
                onPressed: onToggleDescription,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  showFullDescription ? 'Read Less' : 'Read More',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (job['required_skills'] != null &&
                (job['required_skills'] as List).isNotEmpty) ...[
              Text(
                'Required Skills:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (job['required_skills'] as List)
                    .map((skill) => Chip(
                          label: Text(skill),
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted ${_getTimeAgo(job['posted_date']?['_seconds'])}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(int? seconds) {
    if (seconds == null) return 'recently';
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    final diff = DateTime.now().difference(date);

    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0)
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return 'just now';
  }
}

class JobDetailsModal extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailsModal({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              job['job_title'] ?? 'Job Details',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            //_buildDetailRow('Job ID:', job['job_id'], context),
            _buildDetailRow('Category:', job['job_category'], context),
            _buildDetailRow('Payment Type:', job['payment_type'], context),
            _buildDetailRow('Budget:', '\₹${job['budget']}', context),
            _buildDetailRow('Status:', job['status'], context),
            //_buildDetailRow('Client ID:', job['client_id'], context),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Description:',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(job['description'] ?? 'No description provided'),
            const SizedBox(height: 16),
            if (job['required_skills'] != null &&
                (job['required_skills'] as List).isNotEmpty) ...[
              Text(
                'Required Skills:',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (job['required_skills'] as List)
                    .map((skill) => Chip(
                          label: Text(skill),
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (job['milestones'] != null) ...[
              Text(
                'Milestones:',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(job['milestones'].toString()),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Add application logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Apply Now',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
