import 'dart:io';

class Permission {
  final String permissionDate;
  final String reason;
  final File? information;

  Permission({
    required this.permissionDate,
    required this.reason,
    required this.information,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      permissionDate: json['permission_date'],
      reason: json['reason'],
      information: json['information'] != null ? File(json['information']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permission_date': permissionDate,
      'reason': reason,
      'information': information != null ? information!.path : null,
    };
  }
}
