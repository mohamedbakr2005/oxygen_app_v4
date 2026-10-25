import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ProfileButtonWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  final Color? color;
  final String? iconImage;
  final bool showDivider;

  const ProfileButtonWidget({
    super.key,
    this.icon,
    required this.title,
    required this.onTap,
    this.isButtonActive,
    this.color,
    this.iconImage,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color itemColor = color ?? Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: 12,
          ),
          child: Row(
            children: [
              // 🚀 Modern Icon Squircle Container
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: itemColor.withOpacity(isDark ? 0.3 : 0.15),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: iconImage != null
                    ? Image.asset(
                        iconImage!,
                        color: itemColor,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        icon,
                        size: 20,
                        color: itemColor,
                      ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              // 🚀 Title
              Expanded(
                child: Text(
                  title,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),

              // 🚀 Action: Switch or Chevron
              if (isButtonActive != null)
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: isButtonActive!,
                    activeColor: Theme.of(context).primaryColor,
                    trackColor: isDark
                        ? Colors.grey.shade800
                        : Theme.of(context).disabledColor.withOpacity(0.3),
                    onChanged: (bool? value) => onTap(),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.35),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
