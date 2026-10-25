import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/payment_button_new.dart';
import 'package:Oxygen_Mart/features/payment/widgets/offline_payment_button.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class PaymentMethodsView extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final int? storeId;
  final double totalPrice;

  const PaymentMethodsView({super.key,
    required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive, required this.storeId, required this.totalPrice,
    required this.isOfflinePaymentActive,
  });

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    _initLogic();
  }

  @override
  void didUpdateWidget(covariant PaymentMethodsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalPrice != widget.totalPrice) {
      _initLogic();
    }
  }

  void _initLogic() {
    final checkout = Get.find<CheckoutController>();

    if (!AuthHelper.isGuestLoggedIn()) {
      double walletBalance =
          Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
      if (walletBalance < widget.totalPrice) {
        canSelectWallet = false;
      } else {
        canSelectWallet = true;
      }

      if (checkout.isPartialPay) {
        notHideWallet = false;
        final partialMethod =
            Get.find<SplashController>().configModel?.partialPaymentMethod;
        if (partialMethod == 'cod') {
          notHideCod = true;
          notHideDigital = false;
        } else if (partialMethod == 'digital_payment') {
          notHideCod = false;
          notHideDigital = true;
        } else if (partialMethod == 'both') {
          notHideCod = true;
          notHideDigital = true;
        }
      } else {
        notHideWallet = true;
        notHideCod = true;
        notHideDigital = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      final splashController = Get.find<SplashController>();
      final activePaymentList = splashController.configModel?.activePaymentMethodList ?? [];

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          children: [
            // 1. Cash On Delivery
            if (widget.isCashOnDeliveryActive && notHideCod)
              PaymentButtonNew(
                icon: Images.codIcon,
                title: 'cash_on_delivery'.tr,
                isSelected: checkoutController.paymentMethodIndex == 0,
                onTap: () => checkoutController.setPaymentMethod(0),
              ),

            // 2. Wallet Payment
            if (widget.storeId == null &&
                widget.isWalletActive &&
                notHideWallet &&
                isLoggedIn)
              PaymentButtonNew(
                icon: Images.walletProfile,
                title:
                    '${'wallet_payment'.tr} (${Get.find<ProfileController>().userInfoModel?.walletBalance != null ? PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!) : '0'})',
                isSelected: checkoutController.paymentMethodIndex == 1,
                onTap: () {
                  if (canSelectWallet) {
                    checkoutController.setPaymentMethod(1);
                  } else if (checkoutController.isPartialPay) {
                    showCustomSnackBar(
                        'you_can_not_user_wallet_in_partial_payment'.tr);
                  } else {
                    showCustomSnackBar(
                        'your_wallet_have_not_sufficient_balance'.tr);
                  }
                },
              ),

            // 3. Bank Card (Digital Payment)
            if (widget.storeId == null &&
                widget.isDigitalPaymentActive &&
                notHideDigital)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: activePaymentList.length,
                itemBuilder: (context, index) {
                  final paymentMethod = activePaymentList[index];
                  return PaymentButtonNew(
                    icon: Images.visa,
                    title: 'bank_card'.tr,
                    isSelected: checkoutController.paymentMethodIndex == 2 &&
                        paymentMethod.getWay! == checkoutController.digitalPaymentName &&
                        checkoutController.digitalPaymentName != 'e_wallet',
                    onTap: () {
                      checkoutController.setPaymentMethod(2);
                      checkoutController.changeDigitalPaymentName(paymentMethod.getWay!);
                    },
                  );
                },
              ),

            // 4. Electronic Wallet
            if (widget.storeId == null &&
                widget.isDigitalPaymentActive &&
                notHideDigital)
              PaymentButtonNew(
                showEWalletLogos: true,
                icon: Images.eWallet,
                title: 'pay_via_wallet_online'.tr,
                isSelected: checkoutController.paymentMethodIndex == 2 &&
                    checkoutController.digitalPaymentName == 'e_wallet',
                onTap: () {
                  checkoutController.setPaymentMethod(2);
                  checkoutController.changeDigitalPaymentName('e_wallet');
                },
              ),

            // 5. Offline Payment
            OfflinePaymentButton(
              isSelected: checkoutController.paymentMethodIndex == 3,
              offlineMethodList: checkoutController.offlineMethodList,
              isOfflinePaymentActive: widget.isOfflinePaymentActive,
              onTap: () => checkoutController.setPaymentMethod(3),
              checkoutController: checkoutController,
              tooltipController: tooltipController,
            ),
          ],
        ),
      ]);
    });
  }
}
