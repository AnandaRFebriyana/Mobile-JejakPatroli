import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/components/snackbar.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/services/attendance_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';
import 'package:patrol_track_mobile/controllers/location_controller.dart';
import 'package:geolocator/geolocator.dart';

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
      throw 'Gagal mengambil riwayat kehadiran. Silakan coba lagi.';
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
      }
      
      MyQuickAlert.success(context, 'Berhasil melakukan check in',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Get.offAllNamed('/menu-nav');
        },
      );
    } catch (error) {
      print('Error: $error');
      String message = error.toString();
      
      // Convert technical error messages to user-friendly messages
      if (message.contains('Token tidak tersedia')) {
        message = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else if (message.contains('Tidak ada jadwal')) {
        message = 'Tidak ada jadwal patroli untuk hari ini.';
      } else if (message.contains('Terlalu dini')) {
        message = 'Belum waktunya check in. Silakan tunggu sesuai jadwal Anda.';
      } else if (message.contains('di luar area')) {
        message = 'Anda berada di luar area yang ditentukan. Pastikan Anda berada di lokasi yang benar.';
      } else if (message.contains('photo')) {
        message = 'Foto wajib diambil untuk melakukan check in.';
      } else {
        message = 'Gagal melakukan check in. Silakan coba lagi.';
      }
      
      MyQuickAlert.info(context, message);
    }
  }

  static Future<void> saveCheckOut(BuildContext context,
      {required int id, required TimeOfDay checkOut}) async {
    try {
      await AttendanceService.postCheckOut(
        id: id,
        checkOut: checkOut,
      );
      
      // Stop location tracking after successful checkout
      try {
        final locationController = Get.find<LocationController>();
        if (locationController.isTracking.value) {
          print('Stopping location tracking after successful checkout...');
          await locationController.stopTracking();
          // Force set tracking to false to ensure it stops
          locationController.isTracking.value = false;
          print('Location tracking stopped successfully');
        }
      } catch (e) {
        print('Error stopping location tracking: $e');
      }
      
      MyQuickAlert.success(context, 'Berhasil melakukan check out',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Get.offAllNamed('/menu-nav');
        },
      );
    } catch (error) {
      print('Error: $error');
      String message = error.toString();
      
      // Convert technical error messages to user-friendly messages
      if (message.contains('Token tidak tersedia')) {
        message = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else if (message.contains('Tidak ada jadwal')) {
        message = 'Tidak ada jadwal patroli untuk hari ini.';
      } else if (message.contains('sebelum 30 menit')) {
        message = 'Belum waktunya check out. Silakan tunggu sesuai jadwal Anda.';
      } else {
        message = 'Gagal melakukan check out. Silakan coba lagi.';
      }
      
      MyQuickAlert.info(context, message);
    }
  }
}