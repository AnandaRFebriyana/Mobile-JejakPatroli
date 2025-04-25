import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/components/snackbar.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/services/attendance_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

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
      required TimeOfDay checkIn,
      required double longitude,
      required double latitude,
      required String locationAddress,
      File? photo}) async {
    try {
      await AttendanceService.postCheckIn(
        id: id,
        checkIn: checkIn,
        longitude: longitude,
        latitude: latitude,
        locationAddress: locationAddress,
        photo: photo,
      );
      MyQuickAlert.success(context, 'Kehadiran berhasil tersimpan',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Get.toNamed('/menu-nav');
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