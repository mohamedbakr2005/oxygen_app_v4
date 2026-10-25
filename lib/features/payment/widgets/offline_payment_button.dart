import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/features/payment/domain/models/offline_method_model.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OfflinePaymentButton extends StatelessWidget {
  final bool isSelected;
  final List<OfflineMethodModel>? offlineMethodList;
  final bool isOfflinePaymentActive;
  final Function onTap;
  final CheckoutController checkoutController;
  final ParcelController? parcelController;
  final bool forParcel;
  final JustTheController tooltipController;

  const OfflinePaymentButton({
    super.key,
    required this.isSelected,
    required this.offlineMethodList,
    required this.isOfflinePaymentActive,
    required this.onTap,
    required this.checkoutController,
    this.parcelController,
    this.forParcel = false,
    required this.tooltipController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return (isOfflinePaymentActive &&
            offlineMethodList != null &&
            offlineMethodList!.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap as void Function()?,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.08)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : theme.disabledColor.withValues(alpha: 0.2),
                    width: isSelected ? 1.8 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? primary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: isSelected ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall + 2,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withValues(alpha: 0.15)
                                : theme.disabledColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 24,
                            color: isSelected ? primary : theme.hintColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            'pay_offline'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: isSelected
                                  ? primary
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: tooltipController,
                          preferredDirection: AxisDirection.up,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('note'.tr,
                                    style: robotoMedium.copyWith(
                                        color: const Color(0xff90D0FF))),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                OfflinePaymentTooltipNoteWidget(
                                  note: 'offline_payment_note_line_one'.tr,
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                OfflinePaymentTooltipNoteWidget(
                                  note: 'offline_payment_note_line_two'.tr,
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                OfflinePaymentTooltipNoteWidget(
                                  note: 'offline_payment_note_line_three'.tr,
                                ),
                              ],
                            ),
                          ),
                          child: InkWell(
                            onTap: () => tooltipController.showTooltip(),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: isSelected ? primary : theme.hintColor,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : theme.disabledColor.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 13, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                          mainAxisSpacing: Dimensions.paddingSizeSmall,
                          mainAxisExtent: 44,
                          crossAxisCount:
                              ResponsiveHelper.isDesktop(context) ? 4 : 3,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: offlineMethodList!.length,
                        itemBuilder: (context, index) {
                          bool isBankSelected = !forParcel
                              ? checkoutController
                                      .selectedOfflineBankIndex ==
                                  index
                              : parcelController?.selectedOfflineBankIndex ==
                                  index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isBankSelected
                                  ? primary
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isBankSelected
                                    ? primary
                                    : theme.disabledColor
                                        .withValues(alpha: 0.2),
                                width: isBankSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isBankSelected
                                      ? primary.withValues(alpha: 0.25)
                                      : Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomInkWell(
                              onTap: () {
                                if (!forParcel) {
                                  checkoutController.selectOfflineBank(index);
                                } else {
                                  parcelController?.selectOfflineBank(index);
                                }
                              },
                              radius: 12,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  child: Text(
                                    offlineMethodList![index].methodName!,
                                    style: robotoBold.copyWith(
                                      color: isBankSelected
                                          ? Colors.white
                                          : theme.textTheme.bodyMedium!
                                              .color,
                                      fontSize:
                                          Dimensions.fontSizeExtraSmall + 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}

class OfflinePaymentTooltipNoteWidget extends StatelessWidget {
  final String note;
  const OfflinePaymentTooltipNoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          flex: 0,
          child: Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
            child: Text(note,
                style: robotoRegular.copyWith(
                    color: Theme.of(context).cardColor))),
      ],
    );
  }
}
