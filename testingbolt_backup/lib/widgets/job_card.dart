import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:freelancer_app/models/job_post.dart';
import 'package:shimmer/shimmer.dart';

class JobCard extends StatefulWidget {
  const JobCard({super.key});

  @override
  _JobCardState createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late WebSocketChannel _channel;
  JobPost? _jobPost;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://websocket-app-api.onrender.com/jobs'),
      );

      _channel.stream.listen(
        (message) {
          print("WebSocket message received: $message");

          try {
            final data = json.decode(message);

            if (data['type'] == 'added' || data['type'] == 'initial') {
              var jobData = data['data'];

              if (jobData != null) {
                // Convert to JobPost model
                JobPost newJobPost = JobPost.fromJson(jobData);

                setState(() {
                  _jobPost = newJobPost;
                  _isLoading = false;
                });
              } else {
                setState(() {
                  _error = 'Job data is missing from the WebSocket message';
                  _isLoading = false;
                });
              }
            }
          } catch (e) {
            setState(() {
              _error = 'Error processing WebSocket message: $e';
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          setState(() {
            _error = 'Failed to connect to job feed: $error';
            _isLoading = false;
          });
        },
        onDone: () {
          if (_channel.closeCode != status.normalClosure) {
            setState(() {
              _error = 'WebSocket connection closed unexpectedly';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure);
    super.dispose();
  }

  void _showJobDetails(BuildContext context) {
    if (_jobPost == null) return;

    Widget _buildMilestoneDetails() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Milestones',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_jobPost!.milestones.isEmpty)
            Text('No milestones available')
          else
            Column(
              children: _jobPost!.milestones.map((milestone) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                          'Start: ${DateFormat('MMM d, yyyy').format(milestone.startDate)}'),
                      Text(
                          'End: ${DateFormat('MMM d, yyyy').format(milestone.endDate)}'),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      );
    }

    void _showJobDetails(BuildContext context) {
      if (_jobPost == null) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ), // This was the missing closing parenthesis
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Job Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: controller,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _buildMilestoneDetails(),
                      Text(
                        _jobPost!.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.business,
                        'Client ID: ${_jobPost!.clientId}',
                      ),
                      _buildDetailRow(
                        Icons.location_on,
                        '${_jobPost!.city}, ${_jobPost!.state}',
                      ),
                      _buildDetailRow(
                        Icons.attach_money,
                        '\₹${_jobPost!.salary}',
                      ),
                      _buildDetailRow(
                        Icons.category,
                        _jobPost!.category,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Required Skills',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _jobPost!.requiredSkills
                            .map((skill) => Chip(label: Text(skill)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_jobPost!.description),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Implement apply logic
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply Now'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    // Check if the current theme is dark or light
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Set the shimmer colors accordingly
    Color baseColor = isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!;
    Color highlightColor = isDarkTheme ? Colors.grey[500]! : Colors.grey[100]!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: baseColor, // Darker base color in dark mode
          highlightColor:
              highlightColor, // Lighter highlight color in dark mode
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 120,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 180,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 14,
                    color: Colors.white,
                  ),
                  Container(
                    width: 140,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _connectToWebSocket,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return _buildShimmerCard();
    }

    if (_jobPost == null) {
      return const Card(
          child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No job available')),
      ));
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _showJobDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _jobPost!.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.business, size: 16),
                  const SizedBox(width: 4),
                  Text('Client ID: ${_jobPost!.clientId}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text('${_jobPost!.city}, ${_jobPost!.state}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16),
                  const SizedBox(width: 4),
                  Text('\₹${_jobPost!.salary}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _jobPost!.jobType,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Posted: ${DateFormat('MMM d, yyyy').format(_jobPost!.datePosted)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}