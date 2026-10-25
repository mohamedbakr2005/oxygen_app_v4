import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebDeliveryInstructionView extends StatefulWidget {
  const WebDeliveryInstructionView({super.key});

  @override
  State<WebDeliveryInstructionView> createState() =>
      _WebDeliveryInstructionViewState();
}

class _WebDeliveryInstructionViewState
    extends State<WebDeliveryInstructionView> {
  ExpansionTileController controller = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.20)),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeExtraSmall),
        child: GetBuilder<CheckoutController>(builder: (checkoutController) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('add_more_delivery_instruction'.tr,
                        style: robotoMedium),
                    IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          checkoutController.toggleExpand();
                        },
                        icon: Icon(checkoutController.isExpand
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down))
                  ],
                ),

                !checkoutController.isExpand
                    ? const SizedBox()
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                          mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
                          childAspectRatio: 4,
                          crossAxisCount: 3,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: AppConstants.deliveryInstructionList.length,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              checkoutController.selectedInstruction == index;
                          return InkWell(
                            onTap: () {
                              checkoutController.setInstruction(index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.05)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.ac_unit,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).disabledColor,
                                      size: 18),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),
                                  Expanded(
                                    child: Text(
                                      AppConstants
                                          .deliveryInstructionList[index].tr,
                                      style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).disabledColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                orderControllerInstruction(context, checkoutController),
              ]);
        }),
      ),
    );
  }

  Widget orderControllerInstruction(
      BuildContext context, CheckoutController checkoutController) {
    return checkoutController.selectedInstruction != -1
        ? Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Text(
                AppConstants
                    .deliveryInstructionList[
                        checkoutController.selectedInstruction]
                    .tr,
                style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor),
              ),
              const Spacer(),
              InkWell(
                onTap: () => checkoutController.setInstruction(-1),
                child: const Icon(Icons.clear, size: 16),
              ),
            ]),
          )
        : const SizedBox();
  }
}
