import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/tips_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final double totalPrice;
  final Function(double x) onTotalChange;
  final int? storeId;

  const DeliveryManTipsSection({
    super.key,
    required this.takeAway,
    required this.tooltipController3,
    required this.totalPrice,
    required this.onTotalChange,
    this.storeId,
  });

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;

  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    final theme = Theme.of(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      bool shouldShow = !widget.takeAway &&
          Get.find<SplashController>().configModel!.dmTipsStatus == 1;

      if (!shouldShow) return const SizedBox.shrink();

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
          vertical: Dimensions.paddingSizeDefault,
          horizontal: Dimensions.paddingSizeLarge,
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
                    Icons.favorite_rounded,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  'delivery_man_tips'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: widget.tooltipController3,
                  preferredDirection: AxisDirection.right,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'
                          .tr,
                      style: robotoRegular.copyWith(color: Colors.white),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => widget.tooltipController3.showTooltip(),
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

            SizedBox(
              height: (checkoutController.selectedTips ==
                          AppConstants.tips.length - 1) &&
                      checkoutController.canShowTipsField
                  ? 0
                  : ResponsiveHelper.isDesktop(context)
                      ? 65
                      : 55,
              child: (checkoutController.selectedTips ==
                          AppConstants.tips.length - 1) &&
                      checkoutController.canShowTipsField
                  ? const SizedBox()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: AppConstants.tips.length,
                      itemBuilder: (context, index) {
                        return TipsWidget(
                          title: AppConstants.tips[index] == '0'
                              ? 'not_now'.tr
                              : (index != AppConstants.tips.length - 1)
                                  ? PriceConverter.convertPrice(
                                      double.parse(
                                          AppConstants.tips[index].toString()),
                                      forDM: true,
                                    )
                                  : AppConstants.tips[index].tr,
                          isSelected:
                              checkoutController.selectedTips == index,
                          isSuggested: index != 0 &&
                              AppConstants.tips[index] ==
                                  checkoutController.mostDmTipAmount.toString(),
                          onTap: () async {
                            total = total - checkoutController.tips;
                            checkoutController.updateTips(index);
                            if (checkoutController.selectedTips !=
                                AppConstants.tips.length - 1) {
                              checkoutController.addTips(
                                  double.parse(AppConstants.tips[index]));
                            }
                            if (checkoutController.selectedTips ==
                                AppConstants.tips.length - 1) {
                              checkoutController.showTipsField();
                            }
                            checkoutController.tipController.text =
                                checkoutController.tips.toString();

                            if (checkoutController.isPartialPay ||
                                checkoutController.paymentMethodIndex == 1) {
                              checkoutController.checkBalanceStatus(
                                  (total + checkoutController.tips), 0);
                            }
                          },
                        );
                      },
                    ),
            ),

            if (checkoutController.selectedTips !=
                AppConstants.tips.length - 1) ...[
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              InkWell(
                onTap: () => checkoutController.toggleDmTipSave(),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: checkoutController.isDmTipSave
                              ? theme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: checkoutController.isDmTipSave
                                ? theme.primaryColor
                                : theme.disabledColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: checkoutController.isDmTipSave
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        'save_for_later'.tr,
                        style: robotoMedium.copyWith(
                          color: theme.primaryColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (checkoutController.selectedTips ==
                AppConstants.tips.length - 1) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      titleText: 'enter_amount'.tr,
                      controller: checkoutController.tipController,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.number,
                      prefixIcon: Icons.attach_money_rounded,
                      onChanged: (String value) async {
                        if (value.isNotEmpty) {
                          try {
                            if (double.parse(value) >= 0) {
                              if (AuthHelper.isLoggedIn()) {
                                total = total - checkoutController.tips;
                                await checkoutController
                                    .addTips(double.parse(value));
                                total = total + checkoutController.tips;
                                widget.onTotalChange(total);
                                if (Get.find<ProfileController>()
                                            .userInfoModel!
                                            .walletBalance! <
                                        total &&
                                    checkoutController.paymentMethodIndex ==
                                        1) {
                                  checkoutController.checkBalanceStatus(
                                      total, 0);
                                  canCheckSmall = true;
                                } else if (Get.find<ProfileController>()
                                            .userInfoModel!
                                            .walletBalance! >
                                        total &&
                                    canCheckSmall &&
                                    checkoutController.isPartialPay) {
                                  checkoutController.checkBalanceStatus(
                                      total, 0);
                                }
                              } else {
                                checkoutController
                                    .addTips(double.parse(value));
                              }
                            } else {
                              showCustomSnackBar(
                                  'tips_can_not_be_negative'.tr);
                            }
                          } catch (e) {
                            showCustomSnackBar('invalid_input'.tr);
                            checkoutController.addTips(0.0);
                            checkoutController.tipController.text =
                                checkoutController.tipController.text.substring(
                              0,
                              checkoutController.tipController.text.length - 1,
                            );
                            checkoutController.tipController.selection =
                                TextSelection.collapsed(
                              offset: checkoutController
                                  .tipController.text.length,
                            );
                          }
                        } else {
                          checkoutController.addTips(0.0);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  InkWell(
                    onTap: () {
                      checkoutController.updateTips(0);
                      checkoutController.showTipsField();
                      if (checkoutController.isPartialPay) {
                        checkoutController.changePartialPayment();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}
