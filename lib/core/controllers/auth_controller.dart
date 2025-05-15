import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/services/auth_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class AuthController {

  static Future<void> login(BuildContext context, TextEditingController email, TextEditingController password) async {
    try {
      User? user = await AuthService.login(email.text, password.text);
      if (user != null) {
        // Token is already saved in AuthService.login
        print('Login successful, navigating to home');
        Get.toNamed('/menu-nav', arguments: user);
      } else {
        throw 'Login failed: No user data received';
      }
    } catch (error) {
      print('Error in AuthController.login: $error');
      MyQuickAlert.error(context, error.toString());
    }
  }

  static Future<void> logout(BuildContext context) async {
    try {
      MyQuickAlert.confirm(
        context,
        'Apakah kamu ingin keluar',
        onConfirmBtnTap: () async {
          await AuthService.logout();
          Get.offAllNamed('/login');
        },
        onCancelBtnTap: () {
          Navigator.of(context).pop();
        },
      );
    } catch (error) {
      print(error.toString());
      MyQuickAlert.error(context, error.toString());
    }
  }
}