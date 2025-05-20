import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/components/snackbar.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/services/attendance_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';
import 'package:patrol_track_mobile/controllers/location_controller.dart';

class AttendanceController {

  static Future<List<Attendance>> getAttendanceHistory(BuildContext context) async {
    try {
      String? token = await Constant.getToken();

      if (token != null) {
        List<Attendance> attendances = await AttendanceService.getAllAttendances(token);
        return attendances;
      } else {
        throw Exception('Mohon login terlebih dahulu.');
      }
    } catch (error) {
      throw 'Failed to fetch attendance history: ${error.toString()}';
    }
  }

  static Future<void> saveCheckIn(BuildContext context,
      {required int id,
      required int guard_id,
      required TimeOfDay checkIn,
      required double longitude,
      required double latitude,
      required String locationAddress,
      File? photo}) async {
    try {
      await AttendanceService.postCheckIn(
        id: id,
        guard_id: guard_id,
        checkIn: checkIn,
        longitude: longitude,
        latitude: latitude,
        locationAddress: locationAddress,
        photo: photo,
      );
      
      // Start location tracking service in the background
      try {
        print('==== STARTING BACKGROUND LOCATION TRACKING ====');
        print('Attendance ID: $id, Guard ID: $guard_id');
        
        // Try to find existing controller or create a new one
        LocationController? locationController;
        try {
          locationController = Get.find<LocationController>();
          print('Found existing LocationController');
        } catch (e) {
          print('No existing LocationController found, creating new one');
          locationController = Get.put(LocationController());
        }
        
        // Start tracking if controller is available
        if (locationController != null) {
          print('Starting tracking with controller');
          locationController.startTracking(id, guard_id);
          print('Background location tracking started for guard $guard_id');
        } else {
          print('ERROR: LocationController is null!');
        }
        print('==== BACKGROUND TRACKING SETUP COMPLETED ====');
      } catch (e) {
        print('==== ERROR STARTING LOCATION TRACKING ====');
        print('Error details: $e');
        print('==== END ERROR REPORT ====');
        // Don't show this error to the user as it's a background service
      }
      
      // Just notify the user of successful check-in without redirecting to map
      MyQuickAlert.success(context, 'Kehadiran berhasil tersimpan',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          // Return to the home screen instead of going to the map
          Get.offAllNamed('/menu-nav');
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $error');
    }
  }

  static Future<void> saveCheckOut(BuildContext context,
      {required int id, required TimeOfDay checkOut}) async {
    try {
      await AttendanceService.postCheckOut(
        id: id,
        checkOut: checkOut,
      );
      MyQuickAlert.success(context, 'Berhasil check out.');
      Get.toNamed('/menu-nav');
    } catch (error) {
      MySnackbar.failure(context, '$error');
      print('Error: $error');
    }
  }
}