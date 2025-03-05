import 'dart:io';
import 'package:flutter/material.dart';

class Attendance {
  final int id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TimeOfDay? checkIn;
  final TimeOfDay? checkOut;
  final String? status;
  final File? photo;
  final double? longitude;
  final double? latitude;
  final String? locationAddress;

  Attendance({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.checkIn,
    this.checkOut,
    this.status,
    this.photo,
    this.longitude,
    this.latitude,
    this.locationAddress,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: _parseTimeOfDay(json['start_time'])!,
      endTime: _parseTimeOfDay(json['end_time'])!,
      checkIn: _parseTimeOfDay(json['check_in_time']),
      checkOut: _parseTimeOfDay(json['check_out_time']),
      status: json['status'] as String?,
      photo: json['photo'] != null ? File(json['photo']) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude']) : null,
      latitude: json['latitude'] != null ? double.parse(json['latitude']) : null,
      locationAddress: json['location_address'] as String?,
    );
  }

  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString != null) {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }
}