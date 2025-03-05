import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class AuthService {
  static Future<User?> login(String email, String password) async {
    final url = Uri.parse('${Constant.BASE_URL}/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return User.fromJson(result['data']);
    } else {
      final errorResult = jsonDecode(response.body);
      throw '${errorResult['error'] ?? 'Unknown error occurred'}';
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