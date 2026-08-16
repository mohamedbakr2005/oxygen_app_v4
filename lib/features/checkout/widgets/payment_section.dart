import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/payment_methods_view.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class PaymentSection extends StatelessWidget {
  final int? storeId;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final CheckoutController checkoutController;
  final bool isOfflinePaymentActive;

  const PaymentSection({
    super.key,
    this.storeId,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(storeId != null ? 'payment_method'.tr : 'choose_payment_method'.tr,
            style: robotoMedium),
      ]),
      !ResponsiveHelper.isDesktop(context)
          ? const Divider()
          : const SizedBox(height: Dimensions.paddingSizeSmall),
      SizedBox(
          height: !ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeSmall
              : 0),
      PaymentMethodsView(
        isCashOnDeliveryActive: isCashOnDeliveryActive,
        isDigitalPaymentActive: isDigitalPaymentActive,
        isWalletActive: isWalletActive,
        storeId: storeId,
        totalPrice: total,
        isOfflinePaymentActive: isOfflinePaymentActive,
      ),
    ]);
  }
}
