import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class AddressConfirmDialogue extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;

  const AddressConfirmDialogue({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    required this.onYesPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = Theme.of(context).colorScheme.error;

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
              // Close button on desktop
              if (ResponsiveHelper.isDesktop(context))
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),

              // 🚀 Glowing Icon Badge
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

              // Title (if provided)
              if (title != null && title!.isNotEmpty) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge + 1,
                    color: activeColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],

              // Description
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

              // Action Buttons
              GetBuilder<LocationController>(builder: (locationController) {
                if (locationController.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Theme.of(context)
                                      .disabledColor
                                      .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.12)
                                    : Theme.of(context)
                                        .disabledColor
                                        .withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'cancel'.tr,
                              textAlign: TextAlign.center,
                              style: robotoBold.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withOpacity(0.8),
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // Delete / Confirm Button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onYesPressed(),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  activeColor,
                                  activeColor.withOpacity(0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'delete'.tr,
                              textAlign: TextAlign.center,
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                        ),
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
}
