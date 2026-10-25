import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_tool_tip_widget.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class DeliveryOptionButtonWidget extends StatefulWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final double total;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  const DeliveryOptionButtonWidget({
    super.key,
    required this.value,
    required this.title,
    required this.charge,
    required this.isFree,
    this.fromWeb = false,
    required this.total,
    required this.deliveryChargeForView,
    required this.badWeatherCharge,
    required this.extraChargeForToolTip,
  });

  @override
  State<DeliveryOptionButtonWidget> createState() =>
      _DeliveryOptionButtonWidgetState();
}

class _DeliveryOptionButtonWidgetState
    extends State<DeliveryOptionButtonWidget> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      Get.find<CheckoutController>().setOrderType(
          Get.find<SplashController>().configModel!.homeDeliveryStatus == 1 &&
                  Get.find<CheckoutController>().store!.delivery!
              ? 'delivery'
              : 'take_away',
          notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        bool select = checkoutController.orderType == widget.value;
        final theme = Theme.of(context);
        final isDelivery = widget.value == 'delivery';

        return InkWell(
          onTap: () {
            checkoutController.setOrderType(widget.value);
            checkoutController.setInstruction(-1);

            if (checkoutController.orderType == 'take_away') {
              if (checkoutController.isPartialPay) {
                double tips = 0;
                try {
                  tips = double.parse(checkoutController.tipController.text);
                } catch (_) {}
                checkoutController.checkBalanceStatus(
                    widget.total, widget.charge! + tips);
              }
            } else {
              if (checkoutController.isPartialPay) {
                checkoutController.changePartialPayment();
              } else {
                checkoutController.setPaymentMethod(-1);
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: select
                  ? theme.primaryColor.withValues(alpha: 0.08)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: select
                    ? theme.primaryColor
                    : theme.disabledColor.withValues(alpha: 0.2),
                width: select ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: select
                      ? theme.primaryColor.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: select ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall + 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: select
                        ? theme.primaryColor.withValues(alpha: 0.15)
                        : theme.disabledColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDelivery
                        ? Icons.local_shipping_rounded
                        : Icons.storefront_rounded,
                    size: 20,
                    color: select ? theme.primaryColor : theme.hintColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: select
                            ? theme.primaryColor
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isDelivery
                              ? '${'charge'.tr}: +${widget.deliveryChargeForView}'
                              : 'free'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall + 1,
                            color: !isDelivery
                                ? Colors.green.shade600
                                : theme.hintColor,
                          ),
                        ),
                        if (widget.deliveryChargeForView !=
                                PriceConverter.convertPrice(0) &&
                            isDelivery &&
                            checkoutController.extraCharge != null &&
                            (widget.deliveryChargeForView != '0') &&
                            widget.extraChargeForToolTip > 0) ...[
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          CustomToolTip(
                            message:
                                '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(widget.extraChargeForToolTip)} ${widget.badWeatherCharge > 0 ? '${'and_bad_weather_charge'.tr} ${PriceConverter.convertPrice(widget.badWeatherCharge)}' : ''}',
                            preferredDirection: AxisDirection.right,
                            child: const Icon(Icons.info_outline,
                                color: Colors.blue, size: 14),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: select ? theme.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: select
                          ? theme.primaryColor
                          : theme.disabledColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: select
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
