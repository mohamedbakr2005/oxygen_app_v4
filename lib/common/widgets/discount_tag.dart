import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class DiscountTag extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? fontSize;
  final bool inLeft;
  final bool? freeDelivery;
  final bool? isFloating;
  const DiscountTag({
    super.key,
    required this.discount,
    required this.discountType,
    this.fromTop = 10,
    this.fontSize,
    this.freeDelivery = false,
    this.inLeft = true,
    this.isFloating = true,
  });

  @override
  Widget build(BuildContext context) {
    final splash = Get.find<SplashController>();
    final bool isRightSide = splash.configModel?.currencySymbolDirection == 'right';
    final String currencySymbol = splash.configModel?.currencySymbol ?? '';

    final bool hasDiscount = (discount != null && discount! > 0);
    final bool isFree = freeDelivery == true;

    if (!hasDiscount && !isFree) {
      return const SizedBox.shrink();
    }

    final bool floating = isFloating == true;

    return Positioned(
      top: fromTop,
      left: inLeft
          ? (floating ? Dimensions.paddingSizeSmall : 0)
          : null,
      right: inLeft ? null : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(floating
                ? Dimensions.radiusLarge
                : inLeft
                    ? Dimensions.radiusSmall
                    : 0),
            left: Radius.circular(floating
                ? Dimensions.radiusLarge
                : inLeft
                    ? 0
                    : Dimensions.radiusSmall),
          ),
        ),
        child: Text(
          hasDiscount
              ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
              : 'free_delivery'.tr,
          style: robotoMedium.copyWith(
            color: Theme.of(context).cardColor,
            fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 12),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
