import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TipsWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  final bool isSuggested;

  const TipsWidget({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isSuggested,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        right: Dimensions.paddingSizeSmall,
        top: 2,
        bottom: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap as void Function()?,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: Dimensions.paddingSizeDefault,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.disabledColor.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? theme.primaryColor.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                title,
                textDirection: TextDirection.ltr,
                style: robotoBold.copyWith(
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ),
          ),
          if (isSuggested) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'most_tipped'.tr,
                style: robotoBold.copyWith(
                  color: theme.primaryColor,
                  fontSize: Dimensions.fontSizeExtraSmall - 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
