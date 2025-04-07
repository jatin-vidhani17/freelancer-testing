class JobPost {
  final String id;
  final String clientId;
  final String title;
  final String description;
  final double salary;
  final String category;
  final List<String> requiredSkills;
  final List<Milestone> milestones;
  final String jobType;
  final DateTime datePosted;
  final DateTime validUntil;
  
  // New fields for state and city
  final String state;
  final String city;

  JobPost({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.salary,
    required this.category,
    required this.requiredSkills,
    required this.milestones,
    required this.jobType,
    required this.datePosted,
    required this.validUntil,
    required this.state,   // Add state as a required parameter
    required this.city,    // Add city as a required parameter
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    List<Milestone> milestonesList = (json['milestones'] as List?)
            ?.map((e) => Milestone.fromJson(e))
            .toList() ??
        [];

    return JobPost(
      id: json['job_id'],
      clientId: json['client_id'],
      title: json['job_title'],
      description: json['description'] ?? '',
      salary: json['budget']?.toDouble() ?? 0.0,
      category: json['job_category'] ?? '',
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      milestones: milestonesList,
      jobType: json['payment_type'] ?? '',
      state: json['state'] ?? '',  // Parse state
      city: json['district'] ?? '',  // Parse district as city
      datePosted: DateTime.parse(json['posted_date']),
      validUntil: DateTime.now().add(const Duration(days: 30)),  // Example of valid until date
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': id,
      'client_id': clientId,
      'job_title': title,
      'description': description,
      'budget': salary,
      'job_category': category,
      'required_skills': requiredSkills,
      'milestones': milestones.map((e) => e.toJson()).toList(),
      'payment_type': jobType,
      'state': state,    // Include state in the toJson
      'district': city,  // Include city (district) in the toJson
      'posted_date': datePosted.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
    };
  }
}


// Milestone class to handle the milestone objects
class Milestone {
  final String title;
  final DateTime startDate;
  final DateTime endDate;

  Milestone({
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      title: json['title'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
