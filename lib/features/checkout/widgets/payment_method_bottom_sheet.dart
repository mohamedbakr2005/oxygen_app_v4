import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:Oxygen_Mart/features/checkout/widgets/payment_methods_view.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final int? storeId;
  final double totalPrice;
  const PaymentMethodBottomSheet(
      {super.key,
      required this.isCashOnDeliveryActive,
      required this.isDigitalPaymentActive,
      required this.isWalletActive,
      required this.storeId,
      required this.totalPrice,
      required this.isOfflinePaymentActive});

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  @override
  void initState() {
    super.initState();
    final checkout = Get.find<CheckoutController>();

    // نرجّع الـ payment method بس علشان مايفضلش محتفظ بالاختيار القديم
    checkout.setPaymentMethod(-1, isUpdate: false);

    print(
        '=====digital payments : ${Get.find<SplashController>().configModel!.activePaymentMethodList!.first.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return SizedBox(
      width: 550,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(24),
            bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? 24 : 0),
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? Dimensions.paddingSizeSmall
                : Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ResponsiveHelper.isDesktop(context)
              ? Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(50)),
                      child: const Icon(Icons.clear),
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 4,
                    width: 35,
                    margin: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? Dimensions.paddingSizeDefault : 0),
                child: PaymentMethodsView(
                  isCashOnDeliveryActive: widget.isCashOnDeliveryActive,
                  isDigitalPaymentActive: widget.isDigitalPaymentActive,
                  isWalletActive: widget.isWalletActive,
                  storeId: widget.storeId,
                  totalPrice: widget.totalPrice,
                  isOfflinePaymentActive: widget.isOfflinePaymentActive,
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomButton(
              radius: 16,
              buttonText: 'select'.tr,
              onPressed: () => Get.back(),
            ),
          ),
        ]),
      ),
    );
  }
}
