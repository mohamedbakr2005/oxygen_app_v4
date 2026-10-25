import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class SaverDeliveryTimeWidget extends StatelessWidget {
  final CheckoutController checkoutController;
  final double deliveryCharge;
  final double originalDeliveryCharge;
  final bool proFreeDelivery;

  const SaverDeliveryTimeWidget({super.key,
    required this.checkoutController, required this.deliveryCharge, required this.originalDeliveryCharge, this.proFreeDelivery = false,
  });

  static bool _disableSaverOptions({
    required CheckoutController controller, required double deliveryCharge, required double originalDeliveryCharge, bool proFreeDelivery = false,
  }) {
    final Modules? saverModule = controller.saverModule;
    final double? minimumDeliveryCharge = saverModule?.pivot?.minimumDeliveryCharge;
    final bool isFreeDeliveryCouponApplied = Get.find<CouponController>().freeDelivery;
    final bool belowOriginalDeliveryCharge = minimumDeliveryCharge != null
        && originalDeliveryCharge >= 0
        && originalDeliveryCharge < minimumDeliveryCharge;
    final bool hadEligibleOriginalDeliveryCharge = originalDeliveryCharge > 0 && !belowOriginalDeliveryCharge;
    return proFreeDelivery || (isFreeDeliveryCouponApplied && deliveryCharge == 0 && hadEligibleOriginalDeliveryCharge);
  }

  static bool canShow({
    required CheckoutController controller, required double deliveryCharge, required double originalDeliveryCharge, bool proFreeDelivery = false,
  }) {
    final ZoneData? saverZoneData = controller.saverZoneData;
    final Modules? saverModule = controller.saverModule;
    final double? minimumDeliveryCharge = saverModule?.pivot?.minimumDeliveryCharge;
    final bool belowCurrentDeliveryCharge = minimumDeliveryCharge != null
        && deliveryCharge >= 0
        && deliveryCharge < minimumDeliveryCharge;
    final bool hasCurrentEligibleDeliveryCharge = deliveryCharge > 0 && !belowCurrentDeliveryCharge;
    final bool isSelfDeliveryStore = controller.store?.selfDeliverySystem == 1;
    final bool disableSaverOptions = _disableSaverOptions(
      controller: controller, deliveryCharge: deliveryCharge, originalDeliveryCharge: originalDeliveryCharge, proFreeDelivery: proFreeDelivery,
    );
    return controller.orderType == 'delivery'
        && !isSelfDeliveryStore
        && saverZoneData != null
        && saverModule?.deliveryOptions != null
        && saverZoneData.status == 1
        && (saverModule?.additionalDeliveryOptionStatus ?? false)
        && (hasCurrentEligibleDeliveryCharge || disableSaverOptions);
  }

  @override
  Widget build(BuildContext context) {
    final bool disableSaverOptions = _disableSaverOptions(
      controller: checkoutController, deliveryCharge: deliveryCharge, originalDeliveryCharge: originalDeliveryCharge, proFreeDelivery: proFreeDelivery,
    );

    if(disableSaverOptions && checkoutController.saverDeliveryType != 'standard') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(checkoutController.saverDeliveryType != 'standard') {
          checkoutController.setSaverDeliveryType('standard');
        }
      });
    }

    final Modules? saverModule = checkoutController.saverModule;
    if (saverModule?.deliveryOptions == null || saverModule!.deliveryOptions!.isEmpty) {
      return const SizedBox();
    }

    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.electric_bolt_rounded,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'delivery_speed_options'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          AbsorbPointer(
            absorbing: disableSaverOptions,
            child: Opacity(
              opacity: disableSaverOptions ? 0.55 : 1,
              child: isDesktop
                  ? SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: saverModule.deliveryOptions!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                            child: SizedBox(
                              width: 290,
                              child: _SaverOptionTile(
                                checkoutController: checkoutController,
                                deliveryOption: saverModule.deliveryOptions![index],
                                deliveryCharge: deliveryCharge,
                                originalDeliveryCharge: originalDeliveryCharge,
                                isDesktop: true,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: saverModule.deliveryOptions!.length,
                      separatorBuilder: (BuildContext ctx, int idx) => const SizedBox(height: Dimensions.paddingSizeSmall),
                      itemBuilder: (BuildContext context, int index) {
                        return _SaverOptionTile(
                          checkoutController: checkoutController,
                          deliveryOption: saverModule.deliveryOptions![index],
                          deliveryCharge: deliveryCharge,
                          originalDeliveryCharge: originalDeliveryCharge,
                          isDesktop: false,
                        );
                      },
                    ),
            ),
          ),
          if (disableSaverOptions) ...<Widget>[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Text(
                    'free_delivery_applies_to_this_order_amount_so_delivery_type_charge_options_are_disabled'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SaverOptionTile extends StatelessWidget {
  final CheckoutController checkoutController;
  final DeliveryOptions deliveryOption;
  final double deliveryCharge;
  final double originalDeliveryCharge;
  final bool isDesktop;

  const _SaverOptionTile({
    required this.checkoutController, required this.deliveryOption, required this.deliveryCharge, required this.originalDeliveryCharge, required this.isDesktop,
  });

  String _getOptionTitle(String? type) {
    if (type == 'standard') {
      return 'standard_delivery_option'.tr;
    } else if (type == 'express') {
      return 'express_delivery_option'.tr;
    } else if (type == 'slightly_delay') {
      return 'saver_delivery_option'.tr;
    }
    return '${type?.tr ?? ''} ${'delivery'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isFreeDeliveryCouponApplied = Get.find<CouponController>().freeDelivery;
    final bool isSelected = checkoutController.saverDeliveryType == deliveryOption.deliveryType;
    final String storeDeliveryTime = _finalizeDeliveryTime(
      checkoutController.store?.deliveryTime ?? '',
      deliveryOption,
      checkoutController.saverModule,
    );

    final double baseCharge = isFreeDeliveryCouponApplied ? originalDeliveryCharge : deliveryCharge;
    double totalDeliveryCharge = checkoutController.getEffectiveSaverDeliveryAdjustment(
      deliveryCharge: baseCharge,
      deliveryOption: deliveryOption,
    ) + baseCharge;
    if (totalDeliveryCharge < 0) totalDeliveryCharge = 0;
    final String deliveryChargeText = PriceConverter.convertPrice(totalDeliveryCharge);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: deliveryOption.deliveryType == null
            ? null
            : () {
                checkoutController.setSaverDeliveryType(deliveryOption.deliveryType!);
              },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withValues(alpha: 0.05) : theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.disabledColor.withValues(alpha: 0.22),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _CustomRadioIndicator(
                isSelected: isSelected,
                primaryColor: theme.primaryColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _getOptionTitle(deliveryOption.deliveryType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (storeDeliveryTime.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.schedule_outlined,
                            size: 13,
                            color: theme.hintColor.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              storeDeliveryTime,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall + 1,
                                color: theme.hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      '${'total_delivery_fee'.tr}: $deliveryChargeText',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              if (deliveryOption.extraCharge != null || deliveryOption.reduceCharge != null)
                _ChargeBadgeWidget(
                  extraCharge: deliveryOption.extraCharge,
                  reduceCharge: deliveryOption.reduceCharge,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _finalizeDeliveryTime(String storeDeliveryTime, DeliveryOptions deliveryOption, Modules? saverModule) {
    String time = '';
    if (storeDeliveryTime.isNotEmpty) {
      int minTime = 0;
      int maxTime = 0;
      try {
        final RegExpMatch? match = RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*(\w+)?', caseSensitive: false).firstMatch(storeDeliveryTime);
        if (match == null) {
          throw const FormatException('Invalid delivery time format');
        }
        minTime = int.parse(match.group(1)!);
        maxTime = int.parse(match.group(2)!);
        final String timeUnit = match.group(3) ?? 'min';

        minTime = _convertToMinutes(minTime, timeUnit);
        maxTime = _convertToMinutes(maxTime, timeUnit);

        int saverMinTime = saverModule?.pivot?.minimumDeliveryTime?.value ?? 0;
        final String saverMinTimeType = saverModule?.pivot?.minimumDeliveryTime?.unit ?? 'min';
        saverMinTime = _convertToMinutes(saverMinTime, saverMinTimeType);

        if (minTime > saverMinTime && saverMinTime > 0) {
          minTime = saverMinTime;
        }

        if (maxTime < saverMinTime && saverMinTime > 0) {
          maxTime = saverMinTime;
        }

        if (deliveryOption.deliveryType == 'standard') {
          time = _formatDeliveryTime(minTime, maxTime);
        } else if (deliveryOption.deliveryType == 'express') {
          int reduceTime = deliveryOption.reduceDeliveryTime?.value ?? 0;
          final String reduceTimeType = deliveryOption.reduceDeliveryTime?.unit ?? timeUnit;
          reduceTime = _convertToMinutes(reduceTime, reduceTimeType);
          time = _formatDeliveryTime(minTime, (maxTime - reduceTime).clamp(minTime, 9999999));
        } else if (deliveryOption.deliveryType == 'slightly_delay') {
          int addTime = deliveryOption.addDeliveryTime?.value ?? 0;
          final String addTimeType = deliveryOption.addDeliveryTime?.unit ?? timeUnit;
          addTime = _convertToMinutes(addTime, addTimeType);
          time = _formatDeliveryTime(minTime, maxTime + addTime);
        }
      } catch (_) {}
    }
    return time;
  }

  int _convertToMinutes(int value, String? unit) {
    final String normalizedUnit = unit?.toLowerCase() ?? 'min';
    if (normalizedUnit.contains('day')) {
      return value * 24 * 60;
    }
    if (normalizedUnit.contains('hour') || normalizedUnit.contains('hr')) {
      return value * 60;
    }
    return value;
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes ${'minutes_short'.tr}';
    }
    final int hours = minutes ~/ 60;
    final int rem = minutes % 60;
    if (rem == 0) {
      return '$hours ${'hours_short'.tr}';
    }
    return '$hours ${'hours_short'.tr} $rem ${'minutes_short'.tr}';
  }

  String _formatDeliveryTime(int minTime, int maxTime) {
    if (minTime == maxTime || minTime == 0) {
      return '${'upto'.tr} ${_formatMinutes(maxTime)}';
    }
    return '$minTime - ${_formatMinutes(maxTime)}';
  }
}

class _ChargeBadgeWidget extends StatelessWidget {
  final double? extraCharge;
  final double? reduceCharge;

  const _ChargeBadgeWidget({
    this.extraCharge, this.reduceCharge,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExtra = extraCharge != null && extraCharge! > 0;
    final bool isReduce = reduceCharge != null && reduceCharge! > 0;

    if (!isExtra && !isReduce) return const SizedBox.shrink();

    final String text = isExtra
        ? '+ ${PriceConverter.convertPrice(extraCharge)}'
        : '- ${PriceConverter.convertPrice(reduceCharge)}';

    final Color badgeBg = isExtra
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE8F5E9);

    final Color textColor = isExtra
        ? const Color(0xFFE65100)
        : const Color(0xFF2E7D32);

    final Color borderColor = isExtra
        ? const Color(0xFFFFB74D).withValues(alpha: 0.5)
        : const Color(0xFF81C784).withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        text,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeSmall - 1,
          color: textColor,
        ),
      ),
    );
  }
}

class _CustomRadioIndicator extends StatelessWidget {
  final bool isSelected;
  final Color primaryColor;

  const _CustomRadioIndicator({
    required this.isSelected, required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              ),
            )
          : null,
    );
  }
}
