import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_track.dart';

class LocationService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Ganti dengan URL backend Anda

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<LocationTrack>> getAllLocations() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/locations'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LocationTrack.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get locations');
    }
  }

  Future<LocationTrack> saveLocation(LocationTrack location) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/locations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(location.toJson()),
    );

    if (response.statusCode == 201) {
      return LocationTrack.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save location');
    }
  }

  Future<LocationTrack> getLocationDetails(int locationId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/locations/$locationId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return LocationTrack.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get location details');
    }
  }

  Future<List<LocationTrack>> getTrackingHistory() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/tracking-history'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LocationTrack.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get tracking history');
    }
  }
} 