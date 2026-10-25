import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final Function? onNoPressed;

  const ConfirmationDialog({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    required this.onYesPressed,
    this.isLogOut = false,
    this.onNoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isLogOut
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Theme.of(context).cardColor,
      elevation: 10,
      child: PointerInterceptor(
        child: Container(
          width: 440,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: activeColor.withOpacity(isDark ? 0.25 : 0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🚀 1. Glowing Hero Icon Badge
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(isDark ? 0.2 : 0.1),
                  border: Border.all(
                    color: activeColor.withOpacity(isDark ? 0.35 : 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Image.asset(
                  icon,
                  fit: BoxFit.contain,
                  color: activeColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // 🚀 2. Optional Title
              if (title != null && title!.isNotEmpty) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge + 1,
                    color: isLogOut
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],

              // 🚀 3. Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  description,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault + 1,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 26),

              // 🚀 4. Action Buttons
              GetBuilder<OrderController>(builder: (orderController) {
                if (orderController.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Row(
                  children: [
                    // Button 1 (Secondary / Cancel if normal, or Confirm if isLogOut)
                    Expanded(
                      child: _buildDialogButton(
                        context,
                        title: isLogOut ? 'yes'.tr : 'no'.tr,
                        isPrimary: !isLogOut,
                        isDanger: isLogOut,
                        onTap: () {
                          if (isLogOut) {
                            onYesPressed();
                          } else {
                            if (onNoPressed != null) {
                              onNoPressed!();
                            } else {
                              Get.back();
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // Button 2 (Primary Confirm if normal, or Cancel if isLogOut)
                    Expanded(
                      child: _buildDialogButton(
                        context,
                        title: isLogOut ? 'no'.tr : 'yes'.tr,
                        isPrimary: isLogOut,
                        isDanger: false,
                        onTap: () {
                          if (isLogOut) {
                            Get.back();
                          } else {
                            onYesPressed();
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 🪄 Helper: Modern Rounded Button
  Widget _buildDialogButton(
    BuildContext context, {
    required String title,
    required bool isPrimary,
    required bool isDanger,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final errorColor = Theme.of(context).colorScheme.error;

    if (isDanger) {
      // Danger Action Button (e.g. Logout Yes or Delete)
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  errorColor,
                  errorColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: errorColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
        ),
      );
    } else if (isPrimary) {
      // Primary Action Button (e.g. Primary Confirm or Safe Dismiss)
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
        ),
      );
    } else {
      // Neutral / Secondary Outline Button
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Theme.of(context).disabledColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Theme.of(context).disabledColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
        ),
      );
    }
  }
}
