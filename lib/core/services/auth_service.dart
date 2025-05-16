import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class AuthService {
  static Future<User?> login(String email, String password) async {
    try {
      print('Attempting login for email: $email');
      final url = Uri.parse('${Constant.BASE_URL}/login');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Login response: $result');
        
        // Get token from the response
        String? token = result['token'];
        if (token == null || token.isEmpty) {
          // Try to get token from data object if it's not at the root level
          if (result['data'] != null && result['data']['token'] != null) {
            token = result['data']['token'];
          }
        }
        
        // Save token if found
        if (token != null && token.isNotEmpty) {
          print('Saving token: ${token.substring(0, math.min(10, token.length))}...');
          await Constant.saveToken(token);
        } else {
          print('No token found in response');
        }
        
        return User.fromJson(result['data']);
      } else {
        final errorResult = jsonDecode(response.body);
        print('Login failed: ${errorResult['error'] ?? 'Unknown error'}');
        throw '${errorResult['error'] ?? 'Unknown error occurred'}';
      }
    } catch (e) {
      print('Exception in login: $e');
      throw e.toString();
    }
  }

  static Future<void> logout() async {
    final url = Uri.parse('${Constant.BASE_URL}/logout');
    String? token = await Constant.getToken();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      print('Successfully logged out');
    } else {
      print('Failed logout: ${response.reasonPhrase}');
    }
  }

  static Future<User> getUser() async {
    String? token = await Constant.getToken();
    final url = Uri.parse('${Constant.BASE_URL}/get-user');
    final response = await http.get(
      url,
      headers: {'Authorization': '$token'},
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return User.fromJson(result['data']);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}