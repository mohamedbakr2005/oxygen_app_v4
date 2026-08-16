import 'dart:convert';

import 'package:Oxygen_Mart/helper/facebook_pixel_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_asset_image_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/item_bottom_sheet.dart';
import 'package:Oxygen_Mart/common/widgets/quantity_button.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:universal_html/js.dart' as js;

class CartItemWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;

  const CartItemWidget(
      {super.key,
      required this.cart,
      required this.cartIndex,
      required this.isAvailable,
      required this.addOns});

  @override
  Widget build(BuildContext context) {
    double? startingPrice = _calculatePriceWithVariation(item: cart.item);
    double? endingPrice =
        _calculatePriceWithVariation(item: cart.item, isStartingPrice: false);
    String? variationText = _setupVariationText(cart: cart);
    String addOnText = _setupAddonsText(cart: cart) ?? '';

    double? discount = cart.item != null
        ? ((cart.item!.storeDiscount ?? 0) == 0
            ? cart.item!.discount
            : cart.item!.storeDiscount)
        : 0;
    String? discountType = cart.item != null
        ? ((cart.item!.storeDiscount ?? 0) == 0
            ? cart.item!.discountType
            : 'percent')
        : 'percent';
    String genericName = '';

    if (cart.item != null && cart.item!.genericName != null && cart.item!.genericName!.isNotEmpty) {
      for (String name in cart.item!.genericName!) {
        genericName += name;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) {
                Get.find<CartController>()
                    .removeFromCart(cartIndex, item: cart.item);
              },
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(
                      Get.find<LocalizationController>().isLtr
                          ? Dimensions.radiusDefault
                          : 0),
                  left: Radius.circular(Get.find<LocalizationController>().isLtr
                      ? 0
                      : Dimensions.radiusDefault)),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: !ResponsiveHelper.isMobile(context)
                ? [const BoxShadow()]
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
          ),
          child: CustomInkWell(
            onTap: () {
              ResponsiveHelper.isMobile(context)
                  ? showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (con) => ItemBottomSheet(
                          item: cart.item, cartIndex: cartIndex, cart: cart),
                    )
                  : showDialog(
                      context: context,
                      builder: (con) => Dialog(
                            child: ItemBottomSheet(
                                item: cart.item,
                                cartIndex: cartIndex,
                                cart: cart),
                          ));
            },
            radius: Dimensions.radiusDefault,
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall,
                horizontal: Dimensions.paddingSizeExtraSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          image: '${cart.item!.imageFullUrl}',
                          height: ResponsiveHelper.isDesktop(context) ? 90 : 60,
                          width: ResponsiveHelper.isDesktop(context) ? 90 : 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      isAvailable
                          ? const SizedBox()
                          : Positioned(
                              top: 0,
                              left: 0,
                              bottom: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    color: Colors.black.withOpacity(0.6)),
                                child: Text('not_available_now_break'.tr,
                                    textAlign: TextAlign.center,
                                    style: robotoRegular.copyWith(
                                      color: Colors.white,
                                      fontSize: 8,
                                    )),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            Flexible(
                              child: Text(
                                cart.item!.name!,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            (Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .vegNonVeg! &&
                                    Get.find<SplashController>()
                                        .configModel!
                                        .toggleVegNonVeg!)
                                ? CustomAssetImageWidget(
                                    cart.item!.veg == 0
                                        ? Images.nonVegImage
                                        : Images.vegImage,
                                    height: 11,
                                    width: 11,
                                  )
                                : const SizedBox(),
                            SizedBox(
                                width: cart.item!.isStoreHalalActive! &&
                                        cart.item!.isHalalItem!
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0),
                            cart.item!.isStoreHalalActive! &&
                                    cart.item!.isHalalItem!
                                ? const CustomAssetImageWidget(Images.halalTag,
                                    height: 13, width: 13)
                                : const SizedBox(),
                          ]),
                          (genericName.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Row(children: [
                                    Flexible(
                                      child: Text(
                                        genericName,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 2),
                          Wrap(children: [
                            Text(
                              '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                              '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall),
                              // textDirection: TextDirection.ltr,
                            ),
                            SizedBox(
                                width: discount! > 0
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0),
                            discount > 0
                                ? Text(
                                    '${PriceConverter.convertPrice(startingPrice)}'
                                    '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                    // textDirection: TextDirection.ltr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).disabledColor,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                    ),
                                  )
                                : const SizedBox(),
                          ]),
                          cart.item!.isPrescriptionRequired!
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          ResponsiveHelper.isDesktop(context)
                                              ? Dimensions.paddingSizeExtraSmall
                                              : 2),
                                  child: Text(
                                    '* ${'prescription_required'.tr}',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                )
                              : const SizedBox(),
                          addOnText.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${'addons'.tr}: ',
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall)),
                                        Flexible(
                                            child: Text(
                                          addOnText,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        )),
                                      ]),
                                )
                              : const SizedBox(),
                          variationText!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${'variations'.tr}: ',
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall)),
                                        Flexible(
                                            child: Text(
                                          variationText,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        )),
                                      ]),
                                )
                              : const SizedBox(),
                        ]),
                  ),
                  GetBuilder<CartController>(builder: (cartController) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault + 2),
                      child: Row(children: [
                        QuantityButton(
                          onTap: cartController.isLoading
                              ? null
                              : () {
                                  if (cart.quantity! > 1) {
                                    Get.find<CartController>().setQuantity(
                                        false,
                                        cartIndex,
                                        cart.stock,
                                        cart.quantityLimit);
                                  } else {
                                    Get.find<CartController>().removeFromCart(
                                        cartIndex,
                                        item: cart.item);
                                  }
                                },
                          isIncrement: false,
                          showRemoveIcon: cart.quantity! == 1,
                        ),
                        Text(
                          cart.quantity.toString(),
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge),
                        ),
                        QuantityButton(
                          onTap: cartController.isLoading
                              ? null
                              : () {
                                  Get.find<CartController>()
                                      .forcefullySetModule(
                                          Get.find<CartController>()
                                              .cartList[0]
                                              .item!
                                              .moduleId!);
                                  Get.find<CartController>().setQuantity(
                                      true,
                                      cartIndex,
                                      cart.stock,
                                      cart.quantityLimit);
                                  print('imceremnt');

                                  if (GetPlatform.isAndroid ||
                                      GetPlatform.isIOS) {
                                  }

                                  if (GetPlatform.isWeb) {
                                    // FacebookEvents.addToCart(
                                    //   productId: cart.item!.id.toString(),
                                    //   name: cart.item!.name.toString(),
                                    //   price: cart.item!.price!,
                                    //   quantity: cart.quantity!,
                                    // );
                                  }

                                  // fbAddToCartWeb(cart);
                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'add_to_cart',
                                    parameters: {
                                      'currency': 'EGP',
                                      'value': cart.item!.price! *
                                          cart.quantity!, // total value
                                      'items': [
                                        {
                                          'item_id': cart.item!.id!
                                              .toString(), // MUST be string
                                          'item_name': cart.item!.name!,
                                          'price': cart.item!.price!,
                                          'quantity': cart.quantity!,
                                        }
                                      ]
                                    },
                                  );

                                  print(
                                      "==================================== Add to cart => ${cart.item?.name}");
                                },
                          isIncrement: true,
                          color: cartController.isLoading
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ]),
                    );
                  }),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void fbAddToCartWeb(CartModel cart) {
    js.context.callMethod('fbq', [
      'track',
      'AddToCart',
      {
        'content_ids': [cart.item!.id.toString()],
        'content_type': "product",
        'content_name': cart.item!.name,
        'value': (cart.item!.discount != null && cart.item!.discount! > 0
                ? cart.item!.discount!.toDouble()
                : cart.item!.price!.toDouble()) *
            cart.quantity!,
        'currency': "EGP",
        'quantity': cart.quantity!,
      }
    ]);
  }

  double? _calculatePriceWithVariation(
      {required Item? item, bool isStartingPrice = true}) {
    double? startingPrice;
    double? endingPrice;
    bool newVariation = Get.find<SplashController>()
            .getModuleConfig(item!.moduleType)
            .newVariation ??
        false;

    if (item.variations!.isNotEmpty && !newVariation) {
      List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if (priceList[0]! < priceList[priceList.length - 1]!) {
        endingPrice = priceList[priceList.length - 1];
      }
    } else {
      startingPrice = item.price;
    }
    if (isStartingPrice) {
      return startingPrice;
    } else {
      return endingPrice;
    }
  }

  String? _setupVariationText({required CartModel cart}) {
    String? variationText = '';

    if (cart.item != null &&
        (Get.find<SplashController>()
                .getModuleConfig(cart.item!.moduleType)
                .newVariation ??
            false)) {
      if (cart.foodVariations != null && cart.foodVariations!.isNotEmpty) {
        for (int index = 0; index < cart.foodVariations!.length; index++) {
          if (cart.foodVariations![index].contains(true)) {
            String name = (cart.item!.foodVariations != null && cart.item!.foodVariations!.length > index)
                ? cart.item!.foodVariations![index].name ?? ''
                : '';
            variationText =
                '${variationText!}${variationText.isNotEmpty ? ', ' : ''}$name (';
            for (int i = 0; i < cart.foodVariations![index].length; i++) {
              if (cart.foodVariations![index][i]!) {
                String level = (cart.item!.foodVariations != null &&
                        cart.item!.foodVariations!.length > index &&
                        cart.item!.foodVariations![index].variationValues != null &&
                        cart.item!.foodVariations![index].variationValues!.length > i)
                    ? cart.item!.foodVariations![index].variationValues![i].level ?? ''
                    : '';
                variationText =
                    '${variationText!}${variationText.endsWith('(') ? '' : ', '}$level';
              }
            }
            variationText = '${variationText!})';
          }
        }
      }
    } else {
      if (cart.variation != null && cart.variation!.isNotEmpty && cart.item != null) {
        List<String> variationTypes = cart.variation![0].type?.split('-') ?? [];
        if (cart.item!.choiceOptions != null && variationTypes.length == cart.item!.choiceOptions!.length) {
          int index0 = 0;
          for (var choice in cart.item!.choiceOptions!) {
            variationText =
                '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
            index0 = index0 + 1;
          }
        } else if (cart.item!.variations != null && cart.item!.variations!.isNotEmpty) {
          variationText = cart.item!.variations![0].type ?? '';
        }
      }
    }
    return variationText;
  }

  String? _setupAddonsText({required CartModel cart}) {
    String addOnText = '';
    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    if (cart.addOnIds != null) {
      for (var addOn in cart.addOnIds!) {
        if (addOn != null) {
          ids.add(addOn.id);
          qtys.add(addOn.quantity);
        }
      }
    }
    if (cart.item != null && cart.item!.addOns != null) {
      for (var addOn in cart.item!.addOns!) {
        if (addOn != null && ids.contains(addOn.id)) {
          int qty = (index0 < qtys.length && qtys[index0] != null) ? qtys[index0]! : 1;
          addOnText =
              '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} ($qty)';
          index0 = index0 + 1;
        }
      }
    }
    return addOnText;
  }
}
