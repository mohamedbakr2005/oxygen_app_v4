import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class PortionWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;
  final Color? iconColor;
  final Color? suffixColor;
  final Function()? onTap;

  const PortionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    this.hideDivider = false,
    this.suffix,
    this.iconColor,
    this.suffixColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveIconColor = iconColor ?? Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          child: Column(
            children: [
              Row(
                children: [
                  // 🚀 Squircle Icon Container
                  Container(
                    height: 38,
                    width: 38,
                    padding: const EdgeInsets.all(8.5),
                    decoration: BoxDecoration(
                      color: effectiveIconColor.withOpacity(isDark ? 0.18 : 0.09),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: effectiveIconColor.withOpacity(isDark ? 0.25 : 0.12),
                        width: 0.8,
                      ),
                    ),
                    child: Image.asset(
                      icon,
                      fit: BoxFit.contain,
                      color: effectiveIconColor,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  // 🚀 Title
                  Expanded(
                    child: Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  // 🚀 Suffix Badge (e.g. Points or Wallet amount)
                  if (suffix != null) ...[
                    Container(
                      margin: const EdgeInsets.only(left: 6, right: 6),
                      decoration: BoxDecoration(
                        color: (suffixColor ?? Theme.of(context).primaryColor).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (suffixColor ?? Theme.of(context).primaryColor).withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(
                        suffix!,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall + 1,
                          color: suffixColor ?? Theme.of(context).primaryColor,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],

                  // 🚀 Trailing Chevron
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.35),
                  ),
                ],
              ),

              // 🚀 Divider
              if (!hideDivider) ...[
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  thickness: 0.7,
                  indent: 50,
                  endIndent: 0,
                  color: Theme.of(context).disabledColor.withOpacity(0.1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
