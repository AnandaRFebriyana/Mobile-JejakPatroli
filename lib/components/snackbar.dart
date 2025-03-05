import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySnackbar {
  static void show(BuildContext context, String title, String message,
      ContentType contentType) {
    Get.snackbar(
      '',
      '',
      barBlur: 0,
      backgroundColor: Colors.transparent,
      messageText: ClipRRect(
        child: Container(
          padding: const EdgeInsets.only(top: 16.0),
          child: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: contentType,
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 500),
      isDismissible: true,
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static void success(BuildContext context, String message) {
    show(context, 'Success!', message, ContentType.success);
  }

  static void failure(BuildContext context, String message) {
    show(context, 'Error!', message, ContentType.failure);
  }

  static void help(BuildContext context, String message) {
    show(context, 'Help!', message, ContentType.help);
  }

  static void warning(BuildContext context, String message) {
    show(context, 'Warning!', message, ContentType.warning);
  }
}