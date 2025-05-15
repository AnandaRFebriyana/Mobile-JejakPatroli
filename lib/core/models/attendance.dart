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
    // Print the raw status from JSON
    print('Raw status from JSON: ${json['status']}');
    
    final TimeOfDay? scheduledStart = _parseTimeOfDay(json['start_time']);
    final TimeOfDay? actualCheckIn = _parseTimeOfDay(json['check_in_time']);
    
    // Calculate status if not provided by API
    String? calculatedStatus = json['status'] as String?;
    if (calculatedStatus == null && scheduledStart != null && actualCheckIn != null) {
      // Convert to minutes since midnight for comparison
      int scheduledMinutes = scheduledStart.hour * 60 + scheduledStart.minute;
      int actualMinutes = actualCheckIn.hour * 60 + actualCheckIn.minute;
      
      // If check-in is more than 15 minutes late
      if (actualMinutes - scheduledMinutes > 15) {
        calculatedStatus = 'Terlambat';
        print('Calculated status: Terlambat (${actualMinutes - scheduledMinutes} minutes late)');
      } else {
        calculatedStatus = 'Hadir';
        print('Calculated status: Hadir (on time or within tolerance)');
      }
    }
    
    return Attendance(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: _parseTimeOfDay(json['start_time'])!,
      endTime: _parseTimeOfDay(json['end_time'])!,
      checkIn: _parseTimeOfDay(json['check_in_time']),
      checkOut: _parseTimeOfDay(json['check_out_time']),
      status: calculatedStatus,
      photo: json['photo'] != null ? File(json['photo']) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude']) : null,
      latitude: json['latitude'] != null ? double.parse(json['latitude']) : null,
      locationAddress: json['location_address'] as String?,
    );
  }

  // Get the attendance status considering the late threshold
  String getEffectiveStatus() {
    // Use status from server if available
    if (status != null && status!.isNotEmpty) {
      print('Using status from server: $status');
      return status!;
    }
    
    // If check-in or startTime is null, can't calculate
    if (checkIn == null) {
      print('Unable to calculate status: Check-in time is null');
      return '';
    }
    
    if (startTime == null) {
      print('Unable to calculate status: Start time is null');
      return 'Hadir'; // Default to present if we don't know the start time
    }
    
    try {
      // Convert to minutes since midnight for comparison
      int scheduledMinutes = startTime.hour * 60 + startTime.minute;
      int actualMinutes = checkIn!.hour * 60 + checkIn!.minute;
      
      int difference = actualMinutes - scheduledMinutes;
      print('Time difference: $difference minutes (scheduled: $scheduledMinutes, actual: $actualMinutes)');
      
      // If check-in is more than 15 minutes late
      if (difference > 15) {
        print('Calculated status: Terlambat ($difference minutes late)');
        return 'Terlambat';
      } else {
        print('Calculated status: Hadir (on time or within tolerance)');
        return 'Hadir';
      }
    } catch (e) {
      print('Error calculating status: $e');
      return 'Hadir'; // Default to present if there's an error
    }
  }

  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    try {
      if (timeString == null || timeString.isEmpty) {
        print('TimeOfDay parsing error: timeString is null or empty');
        return null;
      }
      
      print('Trying to parse TimeOfDay from: "$timeString"');
      final parts = timeString.split(':');
      if (parts.length < 2) {
        print('TimeOfDay parsing error: not enough parts in "$timeString"');
        return null;
      }
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Validate hour and minute
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        print('TimeOfDay parsing error: invalid hour ($hour) or minute ($minute)');
        return null;
      }
      
      print('Successfully parsed TimeOfDay: $hour:$minute');
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('TimeOfDay parsing exception for "$timeString": $e');
      return null;
    }
  }
}