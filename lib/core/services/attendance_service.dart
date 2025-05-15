import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class AttendanceService {
  
  static Future<List<Attendance>> getAllAttendances(String token) async {
    try {
      if (token.isEmpty) {
        throw 'Token tidak tersedia. Silakan login kembali.';
      }
      
      final url = Uri.parse('${Constant.BASE_URL}/history-presence');
      print('Fetching attendance history from: $url');
      print('Using token (without Bearer): ${token.substring(0, 10)}...');
      
      final response = await http.get(
        url,
        headers: {'Authorization': token},
      );
      
      print('History presence response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        List<Attendance> attendances = List<Attendance>.from(
          result['data'].map(
            (attendances) => Attendance.fromJson(attendances),
          ),
        );
        print('Successfully parsed ${attendances.length} attendances');
        return attendances;
      } else if (response.statusCode == 401) {
        print('Authentication failed: Invalid token');
        throw 'Sesi telah berakhir. Silakan login kembali.';
      } else {
        print('Failed to load attendances: ${response.statusCode} - ${response.body}');
        throw 'Gagal memuat kehadiran. Status code: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception in getAllAttendances: $e');
      throw e.toString();
    }
  }

  static Future<Attendance?> getToday() async {
    try {
      String? token = await Constant.getToken();
      if (token == null || token.isEmpty) {
        throw 'Token tidak tersedia. Silakan login kembali.';
      }
      
      final url = Uri.parse('${Constant.BASE_URL}/today-presence');
      final response = await http.get(
        url,
        headers: {'Authorization': token},
      );

      print('Today presence response: ${response.statusCode} - ${response.body}');  // Debug log

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final data = result['data'];
        
        // Debug log to specifically check the status field
        print('Attendance data from API: $data');
        print('Status field from API: ${data['status']}');
        print('Start time: ${data['start_time']}, Check-in time: ${data['check_in_time']}');
        
        return Attendance.fromJson(data);
      } else if (response.statusCode == 401) {
        print('Authentication failed: Invalid token');
        throw 'Sesi telah berakhir. Silakan login kembali.';
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
      if (token == null || token.isEmpty) {
        throw 'Token tidak tersedia. Silakan login kembali.';
      }

      final url = Uri.parse('${Constant.BASE_URL}/check-in/$id');
      final request = http.MultipartRequest('POST', url);

      // Using token without Bearer prefix as that appears to be what the server expects
      request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';

      String formattedTime = _formatTimeOfDay(checkIn);
      request.fields['check_in_time'] = formattedTime;
      request.fields['longitude'] = longitude.toString();
      request.fields['latitude'] = latitude.toString();
      request.fields['location_address'] = locationAddress;

      if (photo != null) {
        print('Adding photo to request: ${photo.path}');
        
        if (!photo.existsSync()) {
          print('WARNING: Photo file does not exist: ${photo.path}');
        } else {
          print('Photo file exists, size: ${photo.lengthSync()} bytes');
        }
        
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      } else {
        print('No photo provided for check-in');
      }
      
      print('Sending check-in request to: $url');
      print('Request Fields: ${request.fields}');
      print('Request Headers: ${request.headers}');
      print('Request Files: ${request.files.map((f) => "${f.field}: ${f.filename}").toList()}');
      
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('Check-in Response Status: ${response.statusCode}');
      print('Check-in Response Body: ${responseBody.body}');

      if (response.statusCode == 200) {
        print('Check-in successful');
        return responseBody.body;
      } else if (response.statusCode == 401) {
        print('Authentication failed: Invalid token');
        throw 'Sesi telah berakhir. Silakan login kembali.';
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(responseBody.body);
        print('Validation Error Details: $errorData');
        
        // Extract more specific error messages if available
        String errorMessage = 'Data tidak valid';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
          errorMessage = errorData['errors'].toString();
        }
        
        throw 'Gagal membuat presensi: $errorMessage';
      } else {
        throw 'Gagal membuat presensi. Status code: ${response.statusCode}, Response: ${responseBody.body}';
      }
    } catch (e) {
      print('Error in postCheckIn: $e');
      throw Exception('Gagal membuat presensi: $e');
    }
  }

  static Future<void> postCheckOut({required int id, required TimeOfDay checkOut}) async {
    try {
      String? token = await Constant.getToken();
      if (token == null || token.isEmpty) {
        throw 'Token tidak tersedia. Silakan login kembali.';
      }
      
      final url = Uri.parse('${Constant.BASE_URL}/check-out/$id');
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';

      request.fields['check_out_time'] = _formatTimeOfDay(checkOut);
      
      print('Sending check-out request to: $url');
      print('Request Fields: ${request.fields}');
      print('Request Headers: ${request.headers}');

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      
      print('Check-out Response Status: ${response.statusCode}');
      print('Check-out Response Body: ${responseBody.body}');

      if (response.statusCode == 200) {
        print('Berhasil check out.');
      } else if (response.statusCode == 401) {
        print('Authentication failed: Invalid token');
        throw 'Sesi telah berakhir. Silakan login kembali.';
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(responseBody.body);
        print('Validation Error Details: $errorData');
        throw 'Gagal membuat check-out: ${errorData['message'] ?? 'Data tidak valid'}';
      } else {
        throw 'Gagal membuat check-out. Status code: ${response.statusCode}, Response: ${responseBody.body}';
      }
    } catch (e) {
      print('Error in postCheckOut: $e');
      throw Exception('Gagal membuat check-out: $e');
    }
  }

  static String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}