import 'package:get/get.dart';
import 'package:patrol_track_mobile/pages/auth/forgot_password.dart';
import 'package:patrol_track_mobile/pages/auth/login.dart';
import 'package:patrol_track_mobile/pages/auth/otp.dart';
import 'package:patrol_track_mobile/pages/auth/reset_password.dart';
import 'package:patrol_track_mobile/pages/home/history_presence.dart';
import 'package:patrol_track_mobile/pages/menu_nav.dart';
import 'package:patrol_track_mobile/pages/home/permission.dart';
import 'package:patrol_track_mobile/pages/report/scanner.dart';
import 'package:patrol_track_mobile/pages/home/presensi.dart';

class RouteApp {
  static final pages = [
    GetPage(name: '/login', page: () => const Login()),
    GetPage(name: '/forgot-pass', page: () => const ForgotPass()),
    GetPage(name: '/otp', page: () => const Otp()),
    GetPage(name: '/reset-pass', page: () => const ResetPassword()),
    
    GetPage(name: '/menu-nav', page: () => MenuNav()),
    GetPage(name: '/presensi', page: () => Presensi()),
    GetPage(name: '/history-presence', page: () => HistoryPresence()),
    GetPage(name: '/scanner', page: () => Scanner()),
    GetPage(name: '/permission', page: () => PermissionPage())
  ];
}