import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/coustom_toast.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

void showCustomSnackBar(String? message,
    {bool isError = true, bool getXSnackBar = false, int? showDuration, String? actionLabel, VoidCallback? onAction}) {
  if (message != null && message.isNotEmpty) {
    final String msg = message.tr;
    final duration = Duration(seconds: showDuration ?? 2);

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.rawSnackbar(
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        bottom: ResponsiveHelper.isDesktop(Get.context)
            ? 40
            : (GetPlatform.isIOS ? 95 : 85),
      ),
      padding: EdgeInsets.zero,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      animationDuration: const Duration(milliseconds: 280),
      messageText: CustomToast(
        text: msg,
        isError: isError,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
