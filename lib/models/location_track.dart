class LocationTrack {
  final int? id;
  final double latitude;
  final double longitude;
  final int shiftId;
  final int guardId;
  final String createdAt;
  final String updatedAt;

  LocationTrack({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.shiftId,
    required this.guardId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationTrack.fromJson(Map<String, dynamic> json) {
    try {
      return LocationTrack(
        id: json['id'] != null ? int.parse(json['id'].toString()) : null,
        latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : 0.0,
        longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : 0.0,
        shiftId: json['shift_id'] != null ? int.parse(json['shift_id'].toString()) : 0,
        guardId: json['guard_id'] != null ? int.parse(json['guard_id'].toString()) : 0,
        createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error parsing LocationTrack JSON: $e');
      print('Problematic JSON: $json');
      // Return a default object with zeros to avoid crashing
      return LocationTrack(
        id: null,
        latitude: 0.0,
        longitude: 0.0,
        shiftId: 0,
        guardId: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    // Use snake_case field names as expected by the API
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'shift_id': shiftId,
      'guard_id': guardId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 