import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class MyQuickAlert {
  static void success(BuildContext context, String text,
      {VoidCallback? onConfirmBtnTap}) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Sukses!',
      text: text,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  static void error(BuildContext context, String text,
      {VoidCallback? onConfirmBtnTap}) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Eror!',
      text: text,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  static void warning(BuildContext context, String text,
      {VoidCallback? onConfirmBtnTap}) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Warning!',
      text: text,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  static void info(BuildContext context, String text,
      {VoidCallback? onConfirmBtnTap}) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: 'Info!',
      text: text,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  static void loading(BuildContext context, String text,
      {VoidCallback? onConfirmBtnTap}) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: text,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  static void confirm(BuildContext context, String text,
      {String confirmButtonText = 'Ya',
      String cancelButtonText = 'Tidak',
      VoidCallback? onConfirmBtnTap,
      VoidCallback? onCancelBtnTap}) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: text,
      // confirmBtnText: confirmButtonText,
      // cancelBtnText: cancelButtonText,
      onConfirmBtnTap: onConfirmBtnTap,
      onCancelBtnTap: onCancelBtnTap,
    );
  }
}