import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:patrol_track_mobile/core/models/schedule.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class ScheduleService {

  static Future<List<Schedule>> getSchedules(String token) async {
    try {
      final url = Uri.parse('${Constant.BASE_URL}/schedule');
      print('Fetching schedules from: $url');
      print('Using token: $token');
      
      final response = await http.get(
        url,
        headers: {'Authorization': '$token'},
      );
      
      print('Schedule response status: ${response.statusCode}');
      print('Schedule response body: ${response.body}');
        
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Decoded schedule data: ${result['data']}');
        List<Schedule> schedules = List<Schedule>.from(
          result['data'].map(
            (schedule) {
              print('Processing schedule: $schedule');
              return Schedule.fromJson(schedule);
            },
          ),
        );
        print('Successfully parsed ${schedules.length} schedules');
        return schedules;
      } else {
        print('Failed to load schedules: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      print('Exception in getSchedules: $e');
      throw Exception(e.toString());
    }
  }
}
