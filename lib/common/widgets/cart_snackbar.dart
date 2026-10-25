import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';

void showCartSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showCustomSnackBar(
    message,
    isError: isError,
    actionLabel: actionLabel ?? (isError ? null : 'view_cart'.tr),
    onAction: onAction ?? (isError ? null : () => Get.toNamed(RouteHelper.getCartRoute())),
  );
}
