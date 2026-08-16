import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_asset_image_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_details_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  const OrderItemWidget(
      {super.key, required this.order, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    for (var addOn in orderDetails.addOns!) {
      addOnText =
          '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    String? variationText = '';
    if (orderDetails.variation!.isNotEmpty) {
      if (orderDetails.variation!.isNotEmpty) {
        List<String> variationTypes =
            orderDetails.variation![0].type!.split('-');
        if (variationTypes.length ==
            orderDetails.itemDetails!.choiceOptions!.length) {
          int index = 0;
          for (var choice in orderDetails.itemDetails!.choiceOptions!) {
            variationText =
                '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
            index = index + 1;
          }
        } else {
          variationText = orderDetails.itemDetails!.variations![0].type;
        }
      }
    } else if (orderDetails.foodVariation!.isNotEmpty) {
      for (FoodVariation variation in orderDetails.foodVariation!) {
        variationText =
            '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        if (variation.variationValues != null) {
          for (VariationValue value in variation.variationValues!) {
            variationText =
                '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
          }
        }
        variationText = '${variationText!})';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: CustomImage(
              height: 64,
              width: 64,
              fit: BoxFit.cover,
              image: '${orderDetails.imageFullUrl}',
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(
                  orderDetails.itemDetails!.name!,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                  child: Text(
                    '${'quantity'.tr}: ${orderDetails.quantity}',
                    style: robotoBold.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(children: [
                Expanded(
                    child: Text(
                  PriceConverter.convertPrice(orderDetails.price),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                )),
                ((Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .unit! &&
                            orderDetails.itemDetails!.unitType != null) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .vegNonVeg! &&
                            Get.find<SplashController>()
                                .configModel!
                                .toggleVegNonVeg!))
                    ? Get.find<SplashController>()
                            .getModuleConfig(order.moduleType)
                            .newVariation!
                        ? CustomAssetImageWidget(
                            orderDetails.itemDetails!.veg == 0
                                ? Images.nonVegImage
                                : Images.vegImage,
                            height: 14,
                            width: 14,
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ),
                            child: Text(
                              orderDetails.itemDetails!.unitType ?? '',
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor),
                            ),
                          )
                    : const SizedBox(),
                SizedBox(
                    width: orderDetails.itemDetails!.isStoreHalalActive! &&
                            orderDetails.itemDetails!.isHalalItem!
                        ? Dimensions.paddingSizeExtraSmall
                        : 0),
                orderDetails.itemDetails!.isStoreHalalActive! &&
                        orderDetails.itemDetails!.isHalalItem!
                    ? const CustomAssetImageWidget(Images.halalTag,
                        height: 15, width: 15)
                    : const SizedBox(),
              ]),
            ]),
          ),
        ]),
        (Get.find<SplashController>()
                    .getModuleConfig(order.moduleType)
                    .addOn! &&
                addOnText.isNotEmpty)
            ? Padding(
                padding:
                    const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  const SizedBox(width: 79),
                  Text('${'addons'.tr}: ',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault)),
                  Flexible(
                      child: Text(addOnText,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).disabledColor,
                          ))),
                ]),
              )
            : const SizedBox(),
        variationText!.isNotEmpty
            ? Padding(
                padding:
                    const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  const SizedBox(width: 79),
                  Text('${'variations'.tr}: ',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault)),
                  Flexible(
                      child: Text(variationText,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).disabledColor,
                          ))),
                ]),
              )
            : const SizedBox(),
      ]),
    );
  }
}
