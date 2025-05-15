import 'package:get/get.dart';
import 'package:patrol_track_mobile/pages/auth/forgot_password.dart';
import 'package:patrol_track_mobile/pages/auth/login.dart';
import 'package:patrol_track_mobile/pages/auth/otp.dart';
import 'package:patrol_track_mobile/pages/auth/reset_password.dart';
import 'package:patrol_track_mobile/pages/home/Schedule.dart';
import 'package:patrol_track_mobile/pages/menu_nav.dart';
import 'package:patrol_track_mobile/pages/home/permission.dart';
import 'package:patrol_track_mobile/pages/home/presensi.dart';
import 'package:patrol_track_mobile/pages/report/report.dart';
import 'package:patrol_track_mobile/screens/location_tracking_screen.dart';
import 'package:patrol_track_mobile/pages/location/location_tracking.dart';

class RouteApp {
  static final pages = [
    // Auth Routes
    GetPage(name: '/login', page: () => const Login()),
    GetPage(name: '/forgot-pass', page: () => const ForgotPass()),
    GetPage(name: '/otp', page: () => const Otp()),
    GetPage(name: '/reset-pass', page: () => const ResetPassword()),

    // Main Routes
    GetPage(name: '/menu-nav', page: () => MenuNav()),
    GetPage(name: '/presensi', page: () => Presensi()),
    GetPage(name: '/history-presence', page: () => SchedulePresence()),
    GetPage(name: '/permission', page: () => PermissionPage()),
    
    // Tracking Map Route (Legacy)
    GetPage(
      name: '/tracking-map',
      page: () {
        // Extract guard_id and shift_id from arguments or use defaults
        int guardId = Get.arguments != null && Get.arguments['guard_id'] != null
            ? Get.arguments['guard_id'] 
            : 1;  // Default guard_id
        int shiftId = Get.arguments != null && Get.arguments['shift_id'] != null
            ? Get.arguments['shift_id']
            : 1;  // Default shift_id
        return LocationTrackingScreen(guardId: guardId, shiftId: shiftId);
      },
    ),
    
    // New Firebase-capable tracking page
    GetPage(
      name: '/firebase-tracking',
      page: () {
        // Extract guard_id and shift_id from arguments or use defaults
        int guardId = Get.arguments != null && Get.arguments['guard_id'] != null
            ? Get.arguments['guard_id'] 
            : 1;  // Default guard_id
        int shiftId = Get.arguments != null && Get.arguments['shift_id'] != null
            ? Get.arguments['shift_id']
            : 1;  // Default shift_id
        return LocationTrackingPage(guardId: guardId, shiftId: shiftId);
      },
    ),

    // Report Route with scanResult validation
    GetPage(
      name: '/report',
      page: () {
        var scanResult = Get.arguments != null && Get.arguments['scanResult'] != null
            ? Get.arguments['scanResult']
            : 'default';  // Default value if scanResult is null
        return ReportPage(scanResult: scanResult);
      },
    ),
  ];
}
