import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/coupon/domain/models/coupon_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CouponCardWidget extends StatelessWidget {
  final CouponModel coupon;
  final int index;
  const CouponCardWidget(
      {super.key, required this.coupon, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final bool isLtr = Get.find<LocalizationController>().isLtr;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardBg = Theme.of(context).cardColor;

    String discountText = '';
    if (coupon.couponType == 'free_delivery') {
      discountText = 'free_delivery'.tr;
    } else if (coupon.discountType == 'percent') {
      final discountVal = coupon.discount;
      final formatted = (discountVal != null && discountVal == discountVal.toInt())
          ? discountVal.toInt().toString()
          : (discountVal?.toString() ?? '0');
      discountText = '$formatted% ${'off'.tr}';
    } else {
      discountText = '${PriceConverter.convertPrice(coupon.discount)} ${'off'.tr}';
    }

    String storeText = 'on_all_store'.tr;
    if (coupon.store != null && coupon.couponType == 'default') {
      storeText = coupon.store!.name ?? '';
    } else if (coupon.couponType == 'store_wise' && coupon.data != null) {
      storeText = '${'on'.tr} ${coupon.data}';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : primaryColor.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Stack(
          children: [
            // Background subtle gradient glow
            Positioned(
              top: -30,
              right: isLtr ? -30 : null,
              left: isLtr ? null : -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
                ),
              ),
            ),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left / Right section (Discount & Badge)
                  Container(
                    width: ResponsiveHelper.isDesktop(context) ? 140 : 110,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                          primaryColor.withValues(alpha: isDark ? 0.08 : 0.04),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.15),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: coupon.couponType == 'free_delivery'
                              ? Icon(Icons.local_shipping_rounded,
                                  color: primaryColor, size: 22)
                              : coupon.discountType == 'percent'
                                  ? Icon(Icons.percent_rounded,
                                      color: primaryColor, size: 22)
                                  : Icon(Icons.monetization_on_rounded,
                                      color: primaryColor, size: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          discountText,
                          textAlign: TextAlign.center,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            storeText,
                            textAlign: TextAlign.center,
                            style: robotoMedium.copyWith(
                              fontSize: 9,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dashed divider line with cutouts
                  CustomPaint(
                    size: const Size(1, double.infinity),
                    painter: _DashedLinePainter(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),

                  // Info section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  coupon.title ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (coupon.couponType == 'pro_customer')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(left: 4, right: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(Images.proPlanCrown,
                                          height: 10, width: 10, color: Colors.white),
                                      const SizedBox(width: 3),
                                      Text(
                                        'PRO',
                                        style: robotoBold.copyWith(
                                            color: Colors.white, fontSize: 8),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (coupon.startDate != null && coupon.expireDate != null)
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 13, color: Theme.of(context).hintColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${DateConverter.stringToReadableString(coupon.startDate!)} ${'to'.tr} ${DateConverter.stringToReadableString(coupon.expireDate!)}',
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 10.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 3),
                          if (coupon.minPurchase != null && coupon.minPurchase! > 0)
                            Row(
                              children: [
                                Icon(Icons.shopping_bag_outlined,
                                    size: 13, color: Theme.of(context).hintColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${'min_purchase'.tr}: ${PriceConverter.convertPrice(coupon.minPurchase)}',
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 10.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 6),

                          // Code pill & Copy action button
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Text(
                                  coupon.code ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: primaryColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              JustTheTooltip(
                                backgroundColor: cardBg,
                                controller: coupon.toolTip,
                                preferredDirection: AxisDirection.up,
                                tailLength: 10,
                                tailBaseWidth: 14,
                                triggerMode: TooltipTriggerMode.manual,
                                content: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    'coupon_code_copied'.tr,
                                    style: robotoMedium.copyWith(
                                      color: primaryColor,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    coupon.toolTip?.showTooltip();
                                    Clipboard.setData(
                                        ClipboardData(text: coupon.code ?? ''));
                                    showCustomSnackBar('coupon_code_copied'.tr,
                                        isError: false);
                                    Future.delayed(
                                        const Duration(milliseconds: 900), () {
                                      coupon.toolTip?.hideTooltip();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.copy_rounded,
                                            size: 12, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          'copy'.tr,
                                          style: robotoBold.copyWith(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double dashHeight = 5;
    const double dashSpace = 4;
    double startY = 6;
    while (startY < size.height - 6) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, min(startY + dashHeight, size.height - 6)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
