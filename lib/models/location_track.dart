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
    return LocationTrack(
      id: json['id'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      shiftId: json['shift_id'],
      guardId: json['guard_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
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