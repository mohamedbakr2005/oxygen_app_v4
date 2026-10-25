import 'package:Oxygen_Mart/util/images.dart';
import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class PaymentButtonNew extends StatelessWidget {
  final String icon;
  final String title;
  final String? amount;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showEWalletLogos;

  const PaymentButtonNew({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.onTap,
    this.amount,
    this.showEWalletLogos = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(alpha: 0.08)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primary
                  : theme.disabledColor.withValues(alpha: 0.2),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? primary.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.15)
                      : theme.disabledColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  icon,
                  width: 26,
                  height: 26,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isSelected
                            ? primary
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (amount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        amount!,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                    if (showEWalletLogos) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.disabledColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Image.asset(Images.vodafone, height: 14),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.disabledColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Image.asset(Images.etisalat, height: 14),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.disabledColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Image.asset(Images.orange, height: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : theme.disabledColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
