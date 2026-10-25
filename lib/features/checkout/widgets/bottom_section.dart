import 'package:Oxygen_Mart/common/models/config_model.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/condition_check_box.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/coupon_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/note_prescription_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/partial_pay_view.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/prescription_image_picker_widget.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double total;
  final Module module;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int? storeId;
  final double? taxPercent;
  final double price;
  final double addOns;
  final Widget? checkoutButton;
  final bool isPrescriptionRequired;
  final double referralDiscount;
  final double variationPrice;

  const BottomSection({
    super.key,
    required this.checkoutController,
    required this.total,
    required this.module,
    required this.subTotal,
    required this.discount,
    required this.couponController,
    required this.taxIncluded,
    required this.tax,
    required this.deliveryCharge,
    required this.todayClosed,
    required this.tomorrowClosed,
    required this.orderAmount,
    this.maxCodOrderAmount,
    this.storeId,
    this.taxPercent,
    required this.price,
    required this.addOns,
    this.checkoutButton,
    required this.isPrescriptionRequired,
    required this.referralDiscount,
    required this.variationPrice,
  });

  @override
  Widget build(BuildContext context) {
    bool takeAway = checkoutController.orderType == 'take_away';
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    final theme = Theme.of(context);

    return Container(
      decoration: isDesktop
          ? BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            )
          : null,
      child: Column(
        children: [
          isDesktop
              ? _PricingView(
                  checkoutController: checkoutController,
                  module: module,
                  subTotal: subTotal,
                  discount: discount,
                  couponController: couponController,
                  taxIncluded: taxIncluded,
                  tax: tax,
                  deliveryCharge: deliveryCharge,
                  orderAmount: orderAmount,
                  storeId: storeId,
                  taxPercent: taxPercent,
                  referralDiscount: referralDiscount,
                  takeAway: takeAway,
                )
              : const SizedBox(),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          /// Coupon
          isDesktop && !isGuestLoggedIn
              ? CouponSection(
                  storeId: storeId,
                  checkoutController: checkoutController,
                  total: total,
                  price: price,
                  discount: discount,
                  addOns: addOns,
                  deliveryCharge: deliveryCharge,
                  variationPrice: variationPrice,
                )
              : const SizedBox(),

          Container(
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
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Additional Note & prescription..
                NoteAndPrescriptionSection(
                  checkoutController: checkoutController,
                  storeId: storeId,
                ),

                if (isDesktop && !isGuestLoggedIn) ...[
                  PartialPayView(
                    totalPrice: total,
                    isPrescription: storeId != null,
                  ),
                ],

                if (!isDesktop) ...[
                  _PricingView(
                    checkoutController: checkoutController,
                    module: module,
                    subTotal: subTotal,
                    discount: discount,
                    couponController: couponController,
                    taxIncluded: taxIncluded,
                    tax: tax,
                    deliveryCharge: deliveryCharge,
                    orderAmount: orderAmount,
                    storeId: storeId,
                    taxPercent: taxPercent,
                    referralDiscount: referralDiscount,
                    takeAway: takeAway,
                  ),
                ],
                const SizedBox(height: Dimensions.paddingSizeDefault),

                if (isDesktop) ...[
                  PrescriptionImagePickerWidget(
                    checkoutController: checkoutController,
                    storeId: storeId,
                    isPrescriptionRequired: isPrescriptionRequired,
                  ),
                ],

                const CheckoutCondition(),

                const SizedBox(height: Dimensions.paddingSizeDefault),
                if (isDesktop) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'total_amount'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (storeId != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  'Once_your_order_is_confirmed_you_will_receive'.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeOverSmall,
                                    color: theme.disabledColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (storeId != null) ...[
                            Text(
                              'a_notification_with_your_bill_total'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeOverSmall,
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                      PriceConverter.convertAnimationPrice(
                        checkoutController.viewTotalPrice,
                        textStyle: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge + 2,
                          color: checkoutController.isPartialPay
                              ? theme.textTheme.bodyMedium!.color
                              : theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (isDesktop) ...[
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: checkoutButton,
            ),
          ],
        ],
      ),
    );
  }
}

class _PricingView extends StatelessWidget {
  final CheckoutController checkoutController;
  final Module module;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final double orderAmount;
  final int? storeId;
  final double? taxPercent;
  final double referralDiscount;
  final bool takeAway;

  const _PricingView({
    required this.checkoutController,
    required this.module,
    required this.subTotal,
    required this.discount,
    required this.couponController,
    required this.taxIncluded,
    required this.tax,
    required this.deliveryCharge,
    required this.orderAmount,
    this.storeId,
    this.taxPercent,
    required this.referralDiscount,
    required this.takeAway,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saverDeliveryOption = checkoutController.selectedSaverDeliveryOption;
    final String? saverDeliveryType = saverDeliveryOption?.deliveryType;
    final bool showSaverDeliveryOption = !takeAway &&
        checkoutController.orderType != 'dine_in' &&
        checkoutController.store?.selfDeliverySystem != 1 &&
        (saverDeliveryType == 'express' ||
            saverDeliveryType == 'slightly_delay');
    final double saverDeliveryAdjustment = checkoutController
        .getEffectiveSaverDeliveryAdjustment(
            deliveryCharge: deliveryCharge, deliveryOption: saverDeliveryOption)
        .abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                Icons.receipt_long_rounded,
                size: 18,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              'order_summary'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        if (storeId == null) ...[
          _PricingItemRow(
            title: module.addOn! ? 'subtotal'.tr : 'item_price'.tr,
            value: PriceConverter.convertPrice(subTotal),
            isBold: true,
          ),
          const SizedBox(height: 8),
          _PricingItemRow(
            title: 'discount'.tr,
            value: '(-) ${PriceConverter.convertPrice(discount)}',
            valueColor: Colors.green.shade600,
          ),
          const SizedBox(height: 8),
        ],

        if (couponController.discount! > 0 || couponController.freeDelivery) ...[
          _PricingItemRow(
            title: 'coupon_discount'.tr,
            value: (couponController.coupon != null &&
                    couponController.coupon!.couponType == 'free_delivery')
                ? 'free_delivery'.tr
                : '(-) ${PriceConverter.convertPrice(couponController.discount)}',
            valueColor: Colors.green.shade600,
          ),
          const SizedBox(height: 8),
        ],

        if (referralDiscount > 0) ...[
          _PricingItemRow(
            title: 'referral_discount'.tr,
            value: '(-) ${PriceConverter.convertPrice(referralDiscount)}',
            valueColor: Colors.green.shade600,
          ),
          const SizedBox(height: 8),
        ],

        if (storeId == null) ...[
          _PricingItemRow(
            title: '${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''} ($taxPercent%)',
            value: (taxIncluded ? '' : '(+) ') + PriceConverter.convertPrice(tax),
          ),
          const SizedBox(height: 8),
        ],

        if (!takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && checkoutController.tips > 0) ...[
          _PricingItemRow(
            title: 'delivery_man_tips'.tr,
            value: '(+) ${PriceConverter.convertPrice(checkoutController.tips)}',
          ),
          const SizedBox(height: 8),
        ],

        if (checkoutController.store != null &&
            (checkoutController.store!.extraPackagingStatus ?? false) &&
            Get.find<CartController>().needExtraPackage) ...[
          _PricingItemRow(
            title: 'extra_packaging'.tr,
            value: '(+) ${PriceConverter.convertPrice(checkoutController.store!.extraPackagingAmount!)}',
          ),
          const SizedBox(height: 8),
        ],

        if (!(AuthHelper.isGuestLoggedIn() && checkoutController.guestAddress == null)) ...[
          _PricingItemRow(
            title: 'delivery_fee'.tr,
            value: checkoutController.distance == -1
                ? 'calculating'.tr
                : (deliveryCharge == 0 ||
                        (couponController.coupon != null &&
                            couponController.coupon!.couponType == 'free_delivery'))
                    ? 'free'.tr
                    : '(+) ${PriceConverter.convertPrice(deliveryCharge)}',
            valueColor: checkoutController.distance == -1
                ? Colors.red
                : (deliveryCharge == 0 ||
                        (couponController.coupon != null &&
                            couponController.coupon!.couponType == 'free_delivery'))
                    ? Colors.green.shade600
                    : null,
          ),
          const SizedBox(height: 8),
        ],

        if (showSaverDeliveryOption) ...[
          _PricingItemRow(
            title: saverDeliveryType == 'express'
                ? 'express_delivery_option'.tr
                : saverDeliveryType == 'slightly_delay'
                    ? 'saver_delivery_option'.tr
                    : 'standard_delivery_option'.tr,
            value: '${saverDeliveryType == 'express' ? '(+) ' : '(-) '}${PriceConverter.convertPrice(saverDeliveryAdjustment)}',
            valueColor: saverDeliveryType == 'express' ? null : Colors.green.shade600,
          ),
          const SizedBox(height: 8),
        ],

        if (Get.find<SplashController>().configModel!.additionalChargeStatus! &&
            !(AuthHelper.isGuestLoggedIn() && checkoutController.guestAddress == null)) ...[
          _PricingItemRow(
            title: Get.find<SplashController>().configModel!.additionalChargeName!,
            value: '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
          ),
          const SizedBox(height: 8),
        ],

        if (checkoutController.isPartialPay) ...[
          _PricingItemRow(
            title: 'paid_by_wallet'.tr,
            value: '(-) ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!)}',
            valueColor: Colors.green.shade600,
          ),
          const SizedBox(height: 8),
          _PricingItemRow(
            title: 'due_payment'.tr,
            value: PriceConverter.convertPrice(checkoutController.viewTotalPrice),
            isBold: true,
            valueColor: theme.primaryColor,
          ),
          const SizedBox(height: 8),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Divider(
            thickness: 1,
            color: theme.disabledColor.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

class _PricingItemRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PricingItemRow({
    required this.title,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isBold
              ? robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.textTheme.bodyLarge?.color,
                )
              : robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                ),
        ),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: isBold
              ? robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: valueColor ?? theme.textTheme.bodyLarge?.color,
                )
              : robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: valueColor ?? theme.textTheme.bodyLarge?.color,
                ),
        ),
      ],
    );
  }
}
