import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Constant {
  // static const String BASE_URL = 'http://10.0.2.2:8000/api';
  // static const String BASE_URL = 'http://127.0.0.1:8000/api';
  // static const String BASE_URL = 'https://jejakpatroli.my.id/api';
  // static const String BASE_URL = 'http://10.10.5.20:8000/api';
   static const String BASE_URL = 'http://10.10.181.176:8000/api';

  // poltek 
  static const double targetLatitude = -8.1599633;
  static const double targetLongitude = 113.7224483;
  static const double allowedDistance = 100.0;

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  static Future<void> saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}  