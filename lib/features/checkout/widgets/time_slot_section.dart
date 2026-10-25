import 'package:Oxygen_Mart/common/models/config_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/time_slot_bottom_sheet.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class TimeSlotSection extends StatelessWidget {
  final int? storeId;
  final CheckoutController checkoutController;
  final List<CartModel?>? cartList;
  final JustTheController tooltipController2;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;

  const TimeSlotSection({
    super.key,
    this.storeId,
    required this.checkoutController,
    this.cartList,
    required this.tooltipController2,
    required this.tomorrowClosed,
    required this.todayClosed,
    this.module,
  });

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    final theme = Theme.of(context);

    bool shouldShow = !isGuestLoggedIn &&
        storeId == null &&
        checkoutController.store != null &&
        (checkoutController.store!.scheduleOrder ?? false) &&
        cartList != null &&
        cartList!.isNotEmpty &&
        cartList![0]!.item!.availableDateStarts == null;

    if (!shouldShow) return const SizedBox();

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
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Column(
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
                  Icons.schedule_rounded,
                  size: 18,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'preference_time'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController2,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'schedule_time_tool_tip'.tr,
                    style: robotoRegular.copyWith(color: Colors.white),
                  ),
                ),
                child: InkWell(
                  onTap: () => tooltipController2.showTooltip(),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          InkWell(
            onTap: () {
              if (ResponsiveHelper.isDesktop(context)) {
                showDialog(
                  context: context,
                  builder: (con) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TimeSlotBottomSheet(
                      tomorrowClosed: tomorrowClosed,
                      todayClosed: todayClosed,
                      module: module,
                    ),
                  ),
                );
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (con) => TimeSlotBottomSheet(
                    tomorrowClosed: tomorrowClosed,
                    todayClosed: todayClosed,
                    module: module,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall + 2,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: ((checkoutController.selectedDateSlot == 0 &&
                                todayClosed) ||
                            (checkoutController.selectedDateSlot == 1 &&
                                tomorrowClosed))
                        ? Text(
                            module!.showRestaurantText!
                                ? 'restaurant_is_closed'.tr
                                : 'store_is_closed'.tr,
                            style: robotoMedium.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          )
                        : Text(
                            checkoutController.preferableTime.isNotEmpty
                                ? checkoutController.preferableTime
                                : 'instance'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
