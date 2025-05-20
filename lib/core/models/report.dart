import 'dart:io';

class Report {
  final int id;
  final int guardId;
  final String status;
  final String description;
  final List<String> attachments;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.guardId,
    required this.status,
    required this.description,
    required this.attachments,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    try {
      // Parse attachments
      List<String> attachmentList = [];
      if (json['attachment'] != null) {
        if (json['attachment'] is List) {
          attachmentList = (json['attachment'] as List)
              .map((item) => item.toString())
              .toList();
        } else {
          attachmentList = [json['attachment'].toString()];
        }
      }

      return Report(
        id: json['id'] ?? 0,
        guardId: json['guard_id'] ?? 0,
        status: json['status']?.toString() ?? 'Tidak Diketahui',
        description: json['description']?.toString() ?? '',
        attachments: attachmentList,
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      );
    } catch (e) {
      print('Error parsing Report: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}