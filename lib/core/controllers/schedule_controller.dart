import 'package:flutter/material.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/core/models/schedule.dart';
import 'package:patrol_track_mobile/core/services/schedule_service.dart';
import 'package:patrol_track_mobile/core/services/schedule_cache_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class ScheduleController {

  static Future<List<Schedule>> getSchedules(BuildContext context) async {
    try {
      // Try to get schedules from cache first
      final cachedSchedules = await ScheduleCacheService.getCachedSchedules();
      if (cachedSchedules != null) {
        print('Retrieved schedules from cache');
        return cachedSchedules;
      }

      // If no cache or cache expired, fetch from API
      String? token = await Constant.getToken();
      if (token != null) {
        List<Schedule> schedules = await ScheduleService.getSchedules(token);
        // Cache the new schedules
        await ScheduleCacheService.cacheSchedules(schedules);
        print('Fetched schedules from API and cached them');
        return schedules;
      } else {
        throw Exception('Please login first.');
      }
    } catch (error) {
      print('Error in getSchedules: $error');
      MyQuickAlert.error(
          context, 'Failed to fetch schedules: ${error.toString()}');
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Error!'),
      //       content: Text('Failed to fetch schedules: ${error.toString()}'),
      //       actions: <Widget>[
      //         TextButton(
      //           child: const Text('OK'),
      //           onPressed: () => Navigator.of(context).pop(),
      //         ),
      //       ],
      //     );
      //   },
      // );
      return [];
    }
  }
}