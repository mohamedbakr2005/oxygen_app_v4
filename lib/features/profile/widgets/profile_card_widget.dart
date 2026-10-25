import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ProfileCardWidget extends StatelessWidget {
  final String image;
  final String title;
  final String data;
  final VoidCallback? onTap;

  const ProfileCardWidget({
    super.key,
    required this.data,
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Container(
          height: ResponsiveHelper.isDesktop(context) ? 130 : 115,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardColor,
                isDark
                    ? Theme.of(context).cardColor.withOpacity(0.85)
                    : primaryColor.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: primaryColor.withOpacity(isDark ? 0.15 : 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : primaryColor.withOpacity(0.06),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with subtle squircle background
              Container(
                height: 36,
                width: 36,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.12),
                    width: 0.8,
                  ),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),

              // Data / Value
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data,
                  textDirection: TextDirection.ltr,
                  style: robotoBold.copyWith(
                    fontSize: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeLarge
                        : Dimensions.fontSizeLarge + 1,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 3),

              // Title
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
