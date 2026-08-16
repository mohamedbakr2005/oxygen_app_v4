import 'package:Oxygen_Mart/util/images.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class PaymentButtonNew extends StatelessWidget {
  final String icon;
  final String title;
  final String? amount; // للمحفظة
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
    final primary = Theme.of(context).primaryColor;
    final borderColor = isSelected ? primary : Colors.grey.shade400;
    final bgColor = isSelected
        ? primary.withOpacity(0.2)
        : Theme.of(context).disabledColor.withOpacity(0.2);

    Widget content = Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: isSelected ? Border.all(color: primary, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 32, height: 32),

          const SizedBox(width: 8),
          // النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                if (amount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    amount!,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
                if (showEWalletLogos) ...[
                  // const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(Images.vodafone, height: 18),
                      const SizedBox(width: 6),
                      Image.asset(Images.etisalat, height: 18),
                      const SizedBox(width: 6),
                      Image.asset(Images.orange, height: 18),
                    ],
                  )
                ]
              ],
            ),
          ),

          // علامة الصح
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        onTap: onTap,
        child: isSelected
            ? content
            : DottedBorder(
                color: borderColor,
                strokeWidth: 1,
                dashPattern: const [6, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(Dimensions.radiusDefault),
                child: content,
              ),
      ),
    );
  }
}
