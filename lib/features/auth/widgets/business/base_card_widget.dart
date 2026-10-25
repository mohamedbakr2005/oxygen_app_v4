import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/features/auth/controllers/store_registration_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BaseCardWidget extends StatelessWidget {
  final StoreRegistrationController storeRegistrationController;
  final String title;
  final String? description;
  final int index;
  final Function onTap;
  const BaseCardWidget(
      {super.key,
      required this.storeRegistrationController,
      required this.title,
      required this.index,
      required this.onTap,
      this.description});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isSelected = storeRegistrationController.businessIndex == index;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardBg = Theme.of(context).cardColor;

    return InkWell(
      onTap: onTap as void Function()?,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.1),
                        primaryColor.withValues(alpha: 0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : cardBg,
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : primaryColor.withValues(alpha: 0.12),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeLarge,
            ),
            child: Column(
              crossAxisAlignment: isDesktop
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: isDesktop
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check_circle_rounded,
                          color: primaryColor, size: 18),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      title,
                      style: robotoBold.copyWith(
                        color: isSelected
                            ? primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ],
                ),
                if (isDesktop && description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    description!,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
