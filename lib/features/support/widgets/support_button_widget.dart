import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class SupportButtonWidget extends StatelessWidget {
  final IconData icon;
  final String? iconPath;
  final String title;
  final String? subtitle;
  final String? info;
  final Color color;
  final Function onTap;
  final String? actionText;

  const SupportButtonWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.info,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.iconPath,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = Theme.of(context).cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap as void Function()?,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: 14,
            ),
            child: Row(
              children: [
                // Squircle icon container
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: iconPath != null
                      ? Image.asset(iconPath!, height: 26, width: 26)
                      : Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                // Text column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (info != null && info!.isNotEmpty)
                        Text(
                          info!,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: Dimensions.paddingSizeSmall),

                // Trailing action pill or arrow
                if (actionText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      actionText!,
                      style: robotoBold.copyWith(
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        size: 13, color: color),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
