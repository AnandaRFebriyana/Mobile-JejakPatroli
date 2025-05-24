import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patrol_track_mobile/core/models/schedule.dart';

class ScheduleCacheService {
  static const String _cacheKey = 'cached_schedules';
  static const Duration _cacheDuration = Duration(hours: 24); // Cache valid for 24 hours
  static const String _lastUpdateKey = 'schedules_last_update';

  // Save schedules to cache
  static Future<void> cacheSchedules(List<Schedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = schedules.map((schedule) => {
      'id': schedule.id,
      'guardId': schedule.guardId,
      'name': schedule.name,
      'day': schedule.day,
      'startTime': schedule.startTime,
      'endTime': schedule.endTime,
    }).toList();
    
    await prefs.setString(_cacheKey, jsonEncode(schedulesJson));
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get schedules from cache
  static Future<List<Schedule>?> getCachedSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    
    // Check if cache is expired
    if (lastUpdate == null || 
        DateTime.fromMillisecondsSinceEpoch(lastUpdate)
            .isBefore(DateTime.now().subtract(_cacheDuration))) {
      return null;
    }

    final schedulesJson = prefs.getString(_cacheKey);
    if (schedulesJson == null) return null;

    try {
      final List<dynamic> decodedJson = jsonDecode(schedulesJson);
      return decodedJson.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      print('Error decoding cached schedules: $e');
      return null;
    }
  }

  // Clear cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_lastUpdateKey);
  }
} 