import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/coupon_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponSection extends StatelessWidget {
  final int? storeId;
  final CheckoutController checkoutController;
  final double total;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  final double variationPrice;

  const CouponSection({
    super.key,
    this.storeId,
    required this.checkoutController,
    required this.total,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.deliveryCharge,
    required this.variationPrice,
  });

  @override
  Widget build(BuildContext context) {
    double totalPrice = total;
    final theme = Theme.of(context);

    return storeId == null
        ? GetBuilder<CouponController>(
            builder: (couponController) {
              final bool hasDiscount = couponController.discount! > 0 ||
                  couponController.freeDelivery;

              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.disabledColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                margin: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeSmall,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.confirmation_number_rounded,
                                size: 18,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text(
                              'promo_code'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            if (ResponsiveHelper.isDesktop(context)) {
                              Get.dialog(
                                Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: CouponBottomSheet(
                                    storeId: Get.find<StoreController>()
                                        .store!
                                        .id,
                                    checkoutController: checkoutController,
                                  ),
                                ),
                              );
                            } else {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (con) => CouponBottomSheet(
                                  storeId: Get.find<StoreController>()
                                      .store!
                                      .id,
                                  checkoutController: checkoutController,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall + 2,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'add_voucher'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasDiscount
                              ? Colors.green.withValues(alpha: 0.5)
                              : theme.primaryColor.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Icon(
                            Icons.local_offer_outlined,
                            size: 20,
                            color: hasDiscount
                                ? Colors.green
                                : theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: checkoutController.couponController,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                letterSpacing: 0.5,
                              ),
                              enabled: !hasDiscount,
                              decoration: InputDecoration(
                                hintText: 'enter_promo_code'.tr,
                                hintStyle: robotoRegular.copyWith(
                                  color: theme.hintColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                  letterSpacing: 0,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (checkoutController
                                  .couponController.text.isNotEmpty) {
                                if (!hasDiscount) {
                                  if (checkoutController
                                          .couponController.text.isNotEmpty &&
                                      !couponController.isLoading) {
                                    Get.find<CouponController>()
                                        .applyCoupon(
                                      checkoutController
                                          .couponController.text,
                                      (price - discount) +
                                          addOns +
                                          variationPrice,
                                      deliveryCharge,
                                      Get.find<StoreController>().store!.id,
                                    )
                                        .then((discount) {
                                      if (discount! > 0) {
                                        showCustomSnackBar(
                                          '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                          isError: false,
                                        );
                                        if (checkoutController.isPartialPay ||
                                            checkoutController
                                                    .paymentMethodIndex ==
                                                1) {
                                          totalPrice = totalPrice - discount;
                                          checkoutController.checkBalanceStatus(
                                              totalPrice, discount);
                                        }
                                      }
                                    });
                                  } else if (checkoutController
                                      .couponController.text.isEmpty) {
                                    showCustomSnackBar('enter_a_coupon_code'.tr);
                                  }
                                } else {
                                  totalPrice = totalPrice +
                                      couponController.discount!;
                                  Get.find<CouponController>()
                                      .removeCouponData(true);
                                  checkoutController.couponController.text = '';
                                  if (checkoutController.isPartialPay ||
                                      checkoutController.paymentMethodIndex ==
                                          1) {
                                    checkoutController.checkBalanceStatus(
                                        totalPrice, 0);
                                  }
                                }
                              } else {
                                showCustomSnackBar('enter_a_coupon_code'.tr);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 44,
                              constraints: BoxConstraints(
                                minWidth: !hasDiscount ? 90 : 44,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !hasDiscount
                                    ? theme.primaryColor
                                    : theme.colorScheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: !hasDiscount
                                  ? !couponController.isLoading
                                      ? Text(
                                          'apply'.tr,
                                          style: robotoBold.copyWith(
                                            color: Colors.white,
                                            fontSize: Dimensions.fontSizeSmall + 1,
                                          ),
                                        )
                                      : const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                            strokeWidth: 2,
                                          ),
                                        )
                                  : Icon(
                                      Icons.close_rounded,
                                      color: theme.colorScheme.error,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : const SizedBox();
  }
}
