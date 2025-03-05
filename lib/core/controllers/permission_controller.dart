import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/snackbar.dart';
import 'package:patrol_track_mobile/core/models/permission.dart';
import 'package:patrol_track_mobile/core/services/permission_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class PermissionController {
  
  static Future<void> createPermission(BuildContext context, Permission permission) async {
    try {
      String? token = await Constant.getToken();

      if (token != null) {
        bool success = await PermissionService.postPermission(token, permission);
        if (success) {
          MySnackbar.success(context, 'Permission created successfully');
          Get.toNamed('/menu-nav');
          return;
        }
      }
    } catch (error) {
      MySnackbar.failure(context, '$error');
      print('Error: $error');
    }
  }
}
