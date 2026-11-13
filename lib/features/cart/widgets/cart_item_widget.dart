import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_asset_image_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/item_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/cart/widgets/bogo_bundle_cart_tile.dart';
import 'package:Oxygen_Mart/features/cart/widgets/bundle_cart_tile.dart';
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

  const CartItemWidget({
    super.key,
    required this.cart,
    required this.cartIndex,
    required this.isAvailable,
    required this.addOns,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.isBogoBundle) {
      return BogoBundleCartTile(cart: cart, cartIndex: cartIndex, isAvailable: isAvailable);
    }

    if (cart.isBundle) {
      return BundleCartTile(cart: cart, cartIndex: cartIndex, isAvailable: isAvailable);
    }

    final double? startingPrice = _calculatePriceWithVariation(item: cart.item);
    final double? endingPrice =
        _calculatePriceWithVariation(item: cart.item, isStartingPrice: false);
    final String? variationText = _setupVariationText(cart: cart);
    final String addOnText = _setupAddonsText(cart: cart) ?? '';

    final double? discount = cart.item != null
        ? ((cart.item!.storeDiscount ?? 0) == 0
            ? cart.item!.discount
            : cart.item!.storeDiscount)
        : 0;
    final String? discountType = cart.item != null
        ? ((cart.item!.storeDiscount ?? 0) == 0
            ? cart.item!.discountType
            : 'percent')
        : 'percent';
    String genericName = '';

    if (cart.item != null &&
        cart.item!.genericName != null &&
        cart.item!.genericName!.isNotEmpty) {
      for (String name in cart.item!.genericName!) {
        genericName += name;
      }
    }

    final double imageSize = ResponsiveHelper.isDesktop(context) ? 90 : 74;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.22,
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
                      : 0,
                ),
                left: Radius.circular(
                  Get.find<LocalizationController>().isLtr
                      ? 0
                      : Dimensions.radiusDefault,
                ),
              ),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
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
                        item: cart.item,
                        cartIndex: cartIndex,
                        cart: cart,
                      ),
                    )
                  : showDialog(
                      context: context,
                      builder: (con) => Dialog(
                        child: ItemBottomSheet(
                          item: cart.item,
                          cartIndex: cartIndex,
                          cart: cart,
                        ),
                      ),
                    );
            },
            radius: 18,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image & Badges
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: imageSize,
                            width: imageSize,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.35),
                            child: CustomImage(
                              image: '${cart.item!.imageFullUrl}',
                              height: imageSize,
                              width: imageSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (discount != null && discount > 0)
                          Positioned(
                            top: 4,
                            left: Get.find<LocalizationController>().isLtr ? 4 : null,
                            right: Get.find<LocalizationController>().isLtr ? null : 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                discountType == 'percent'
                                    ? '-${discount.toInt()}%'
                                    : '-${PriceConverter.convertPrice(discount)}',
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        if (!isAvailable)
                          Positioned.fill(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.black.withOpacity(0.65),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'not_available_now_break'.tr,
                                      textAlign: TextAlign.center,
                                      style: robotoMedium.copyWith(
                                        color: Colors.white,
                                        fontSize: 8,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  cart.item?.name ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              if (Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .vegNonVeg! &&
                                  Get.find<SplashController>()
                                      .configModel!
                                      .toggleVegNonVeg!)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: CustomAssetImageWidget(
                                    cart.item!.veg == 0
                                        ? Images.nonVegImage
                                        : Images.vegImage,
                                    height: 12,
                                    width: 12,
                                  ),
                                ),
                              if (cart.item!.isStoreHalalActive! &&
                                  cart.item!.isHalalItem!)
                                const Padding(
                                  padding: EdgeInsets.only(top: 2, left: 4),
                                  child: CustomAssetImageWidget(
                                    Images.halalTag,
                                    height: 13,
                                    width: 13,
                                  ),
                                ),
                            ],
                          ),

                          if (genericName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                genericName,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).disabledColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          const SizedBox(height: 6),

                          // Price Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                                '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              if (discount != null && discount > 0) ...[
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  '${PriceConverter.convertPrice(startingPrice)}'
                                  '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Modern Quantity Stepper Pill
                    GetBuilder<CartController>(
                      builder: (cartController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.12),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _QuantityIconBtn(
                                icon: cart.quantity! == 1
                                    ? Icons.delete_outline_rounded
                                    : Icons.remove_rounded,
                                iconColor: cart.quantity! == 1
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.onSurface,
                                onTap: cartController.isLoading
                                    ? null
                                    : () {
                                        if (cart.quantity! > 1) {
                                          Get.find<CartController>().setQuantity(
                                            false,
                                            cartIndex,
                                            cart.stock,
                                            cart.quantityLimit,
                                          );
                                        } else {
                                          Get.find<CartController>()
                                              .removeFromCart(
                                            cartIndex,
                                            item: cart.item,
                                          );
                                        }
                                      },
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 24),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  cart.quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                              _QuantityIconBtn(
                                icon: Icons.add_rounded,
                                iconColor: cartController.isLoading
                                    ? Theme.of(context).disabledColor
                                    : Theme.of(context).primaryColor,
                                isPrimary: true,
                                onTap: cartController.isLoading
                                    ? null
                                    : () {
                                        Get.find<CartController>()
                                            .forcefullySetModule(
                                          Get.find<CartController>()
                                              .cartList[0]
                                              .item!
                                              .moduleId!,
                                        );
                                        Get.find<CartController>().setQuantity(
                                          true,
                                          cartIndex,
                                          cart.stock,
                                          cart.quantityLimit,
                                        );

                                        FirebaseAnalytics.instance.logEvent(
                                          name: 'add_to_cart',
                                          parameters: {
                                            'currency': 'EGP',
                                            'value': (cart.item?.price ?? 0) *
                                                (cart.quantity ?? 1),
                                            'items': [
                                              {
                                                'item_id': cart.item?.id
                                                        ?.toString() ??
                                                    '',
                                                'item_name':
                                                    cart.item?.name ?? '',
                                                'price': cart.item?.price ?? 0,
                                                'quantity': cart.quantity ?? 1,
                                              }
                                            ],
                                          },
                                        );
                                      },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Tags for Prescription, Addons, and Variations
                if (cart.item?.isPrescriptionRequired ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'prescription_required'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (addOnText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${'addons'.tr}: ',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              addOnText,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (variationText != null && variationText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${'variations'.tr}: ',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              variationText,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        'content_type': 'product',
        'content_name': cart.item!.name,
        'value': (cart.item!.discount != null && cart.item!.discount! > 0
                ? cart.item!.discount!.toDouble()
                : cart.item!.price!.toDouble()) *
            cart.quantity!,
        'currency': 'EGP',
        'quantity': cart.quantity!,
      }
    ]);
  }

  double? _calculatePriceWithVariation({
    required Item? item,
    bool isStartingPrice = true,
  }) {
    double? startingPrice;
    double? endingPrice;
    bool newVariation = Get.find<SplashController>()
            .getModuleConfig(item?.moduleType)
            .newVariation ??
        false;

    if (item != null && item.variations != null && item.variations!.isNotEmpty && !newVariation) {
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
      startingPrice = item?.price;
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
            String name = (cart.item!.foodVariations != null &&
                    cart.item!.foodVariations!.length > index)
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
      if (cart.variation != null &&
          cart.variation!.isNotEmpty &&
          cart.item != null) {
        List<String> variationTypes =
            cart.variation![0].type?.split('-') ?? [];
        if (cart.item!.choiceOptions != null &&
            variationTypes.length == cart.item!.choiceOptions!.length) {
          int index0 = 0;
          for (var choice in cart.item!.choiceOptions!) {
            variationText =
                '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
            index0 = index0 + 1;
          }
        } else if (cart.item!.variations != null &&
            cart.item!.variations!.isNotEmpty) {
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
        ids.add(addOn.id);
        qtys.add(addOn.quantity);
      }
    }
    if (cart.item != null && cart.item!.addOns != null) {
      for (var addOn in cart.item!.addOns!) {
        if (ids.contains(addOn.id)) {
          int qty = (index0 < qtys.length && qtys[index0] != null)
              ? qtys[index0]!
              : 1;
          addOnText =
              '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} ($qty)';
          index0 = index0 + 1;
        }
      }
    }
    return addOnText;
  }
}

class _QuantityIconBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _QuantityIconBtn({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? Theme.of(context).primaryColor.withOpacity(0.12)
          : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
