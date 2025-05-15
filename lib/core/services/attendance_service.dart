import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class AttendanceService {
  
  static Future<List<Attendance>> getAllAttendances(String token) async {
    final url = Uri.parse('${Constant.BASE_URL}/history-presence');
    final response = await http.get(
      url,
      headers: {'Authorization': '$token'},
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      List<Attendance> attendances = List<Attendance>.from(
        result['data'].map(
          (attendances) => Attendance.fromJson(attendances),
        ),
      );
      return attendances;
    } else {
      throw 'Gagal memuat kehadiran. Status code: ${response.statusCode}';
    }
  }

  static Future<Attendance?> getToday() async {
    try {
      String? token = await Constant.getToken();
      final url = Uri.parse('${Constant.BASE_URL}/today-presence');
      final response = await http.get(
        url,
        headers: {'Authorization': '$token'},
      );

      print('Today presence response: ${response.statusCode} - ${response.body}');  // Debug log

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return Attendance.fromJson(result['data']);
      } else if (response.statusCode == 404) {
        print('No attendance found for today');  // Debug log
        return null;
      } else {
        print('Error getting today presence: ${response.body}');  // Debug log
        throw 'Gagal memuat kehadiran hari ini. Status code: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception in getToday: $e');  // Debug log
      throw e.toString();
    }
  }

  static Future<String> postCheckIn(
      {required int id,
      required TimeOfDay checkIn,
      required double longitude,
      required double latitude,
      required String locationAddress,
      File? photo}) async {
    try {
      String? token = await Constant.getToken();

      final url = Uri.parse('${Constant.BASE_URL}/check-in/$id');
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = '$token';
      request.headers['Accept'] = 'application/json';

      request.fields['check_in_time'] = _formatTimeOfDay(checkIn);
      request.fields['longitude'] = longitude.toString();
      request.fields['latitude'] = latitude.toString();
      request.fields['location_address'] = locationAddress;

      if (photo != null) {
        print('Adding photo to request: ${photo.path}');
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      } else {
        print('No photo provided for check-in');
      }
      
      print('Sending check-in request to: $url');
      print('Request Fields: ${request.fields}');
      print('Request Headers: ${request.headers}');
      print('Request Files: ${request.files.map((f) => f.field).toList()}');
      
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('Check-in Response Status: ${response.statusCode}');
      print('Check-in Response Body: ${responseBody.body}');

      if (response.statusCode == 200) {
        return responseBody.body;
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(responseBody.body);
        print('Validation Error Details: $errorData');
        throw 'Gagal membuat presensi: ${errorData['message'] ?? 'Data tidak valid'}';
      } else {
        throw 'Gagal membuat presensi. Status code: ${response.statusCode}, Response: ${responseBody.body}';
      }
    } catch (e) {
      print('Error in postCheckIn: $e');
      throw Exception('Gagal membuat presensi: $e');
    }
  }

  static Future<void> postCheckOut({required int id, required TimeOfDay checkOut}) async {
    String? token = await Constant.getToken();

    final url = Uri.parse('${Constant.BASE_URL}/check-out/$id');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = '$token';
    request.headers['Accept'] = 'application/json';

    request.fields['check_out_time'] = _formatTimeOfDay(checkOut);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Berhasil check out.');
    } else {
      throw 'Gagal membuat presensi. Status code: ${response.statusCode}';
    }
  }

  static String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}