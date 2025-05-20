import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:patrol_track_mobile/core/services/report_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class ReportController {
  
  static Future<bool> checkTodayReport(BuildContext context) async {
    try {
      String? token = await Constant.getToken();
      print('ReportController: Checking today report with token: ${token?.substring(0, 10)}...');

      if (token != null) {
        bool reportedToday = await ReportService.todayReported(token);
        print('ReportController: Today report status: $reportedToday');
        return reportedToday;
      } else {
        throw Exception('Please login first.');
      }
    } catch (e) {
      print('Error while checking today\'s report: $e');
      return false;
    }
  }

  static Future<List<Report>> getReportHistory(BuildContext context) async {
    try {
      String? token = await Constant.getToken();
      print('ReportController: Getting report history with token: ${token?.substring(0, 10)}...');

      if (token != null) {
        print('ReportController: Fetching reports from API...');
        List<Report> reports = await ReportService.getAllReports(token);
        print('ReportController: Successfully fetched ${reports.length} reports');
        return reports;
      } else {
        print('ReportController: No token available');
        throw Exception('Please login first.');
      }
    } catch (e) {
      print('ReportController: Error while fetching reports: $e');
      return [];
    }
  }

  static Future<void> createReport(BuildContext context, Report report) async {
    try {
      String? token = await Constant.getToken();
      if (token == null) {
        throw 'Sesi telah berakhir. Silakan login kembali.';
      }

      await ReportService.postReport(report);
      MyQuickAlert.success(
        context,
        'Laporan berhasil dibuat',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Get.toNamed('/menu-nav');
        },
      );
    } catch (e) {
      print('Error in createReport: $e');
      MyQuickAlert.error(
        context,
        'Gagal membuat laporan: $e',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
    }
  }
}
