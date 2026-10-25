import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartialPayView extends StatelessWidget {
  final double totalPrice;
  final bool isPrescription;
  const PartialPayView({
    super.key,
    required this.totalPrice,
    required this.isPrescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      final splash = Get.find<SplashController>();
      final profile = Get.find<ProfileController>();

      if (splash.configModel == null ||
          profile.userInfoModel == null ||
          profile.userInfoModel!.walletBalance == null) {
        return const SizedBox();
      }
      final wallet = profile.userInfoModel?.walletBalance ?? 0;

      bool shouldShow = splash.configModel!.partialPaymentStatus! &&
          !isPrescription &&
          splash.configModel!.customerWalletStatus == 1 &&
          wallet > 0;

      if (!shouldShow) return const SizedBox();

      bool isApplied = checkoutController.isPartialPay ||
          checkoutController.paymentMethodIndex == 1;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: isApplied
              ? theme.primaryColor.withValues(alpha: 0.08)
              : theme.cardColor,
          border: Border.all(
            color: isApplied
                ? theme.primaryColor
                : theme.disabledColor.withValues(alpha: 0.2),
            width: isApplied ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isApplied
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: ResponsiveHelper.isDesktop(context)
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 24,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isApplied
                              ? 'applied'.tr
                              : 'do_you_want_to_use_now'.tr,
                          style: robotoBold.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${'wallet_balance'.tr}: ${PriceConverter.convertPrice(wallet)}',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (Get.find<ProfileController>()
                              .userInfoModel!
                              .walletBalance! <
                          totalPrice) {
                        checkoutController.changePartialPayment();
                      } else {
                        if (checkoutController.paymentMethodIndex != 1) {
                          checkoutController.setPaymentMethod(1);
                        } else {
                          checkoutController.setPaymentMethod(-1);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isApplied
                            ? theme.colorScheme.error.withValues(alpha: 0.1)
                            : theme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: Text(
                        isApplied ? 'remove'.tr : 'use'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isApplied
                              ? theme.colorScheme.error
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 22,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isApplied
                                  ? 'has_paid_by_your_wallet'.tr
                                  : 'your_have_balance_in_your_wallet'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              PriceConverter.convertPrice(wallet),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (Get.find<ProfileController>()
                                  .userInfoModel!
                                  .walletBalance! <
                              totalPrice) {
                            checkoutController.changePartialPayment();
                          } else {
                            if (checkoutController.paymentMethodIndex != 1) {
                              checkoutController.setPaymentMethod(1);
                            } else {
                              checkoutController.setPaymentMethod(-1);
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isApplied
                                ? theme.colorScheme.error
                                    .withValues(alpha: 0.1)
                                : theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Text(
                            isApplied ? 'remove'.tr : 'use'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: isApplied
                                  ? theme.colorScheme.error
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }
}
