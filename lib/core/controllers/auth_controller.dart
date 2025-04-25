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
      if (user != null && user.token != null) {
        await Constant.saveToken(user.token!);

        Get.toNamed('/menu-nav', arguments: user);
      }
    } catch (error) {
      print(error.toString());
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