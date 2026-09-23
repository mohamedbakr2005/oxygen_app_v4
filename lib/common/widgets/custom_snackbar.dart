import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/coustom_toast.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

void showCustomSnackBar(String? message,
    {bool isError = true, bool getXSnackBar = false}) {
  if (message != null && message.isNotEmpty) {
    final String msg = message.tr;
    if (getXSnackBar) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        message: msg,
        maxWidth: 500,
        duration: const Duration(seconds: 3),
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.only(
            left: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
            bottom: 100),
        borderRadius: Dimensions.radiusSmall,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ));
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        dismissDirection: DismissDirection.endToStart,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        content: CustomToast(text: msg, isError: isError),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
