import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:patrol_track_mobile/core/models/schedule.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class ScheduleService {

  static Future<List<Schedule>> getSchedules(String token) async {
    try {
      final url = Uri.parse('${Constant.BASE_URL}/schedule');
      final response = await http.get(
        url,
        headers: {'Authorization': '$token'},
      );
        
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        List<Schedule> schedules = List<Schedule>.from(
          result['data'].map(
            (schedule) => Schedule.fromJson(schedule),
          ),
        );
        return schedules;
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
