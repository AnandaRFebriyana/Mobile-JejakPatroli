import 'dart:io';

class Report {
  final int? locationId;
  final String locationName;
  final String status;
  final String description;
  final List<File> attachments;
  final DateTime createdAt;

  Report({
    this.locationId,
    required this.locationName,
    required this.status,
    required this.description,
    required this.attachments,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      locationId: json['location_id'],
      locationName: json['location_name'],
      status: json['status'],
      description: json['description'],
      attachments: json['attachment'] != null
        ? (json['attachment'] is List
            ? (json['attachment'] as List).map((path) => File(path)).toList()
            : [File(json['attachment'])])
        : [],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}