import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/cart_count_view.dart';
import 'package:Oxygen_Mart/common/widgets/corner_banner/banner.dart';
import 'package:Oxygen_Mart/common/widgets/corner_banner/corner_discount_tag.dart';
import 'package:Oxygen_Mart/common/widgets/custom_favourite_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/discount_tag.dart';
import 'package:Oxygen_Mart/common/widgets/hover/text_hover.dart';
import 'package:Oxygen_Mart/common/widgets/not_available_widget.dart';
import 'package:Oxygen_Mart/common/widgets/organic_tag.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';

import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

import '../../util/images.dart';
import 'custom_asset_image_widget.dart';

class ItemWidget extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  final double? imageHeight;
  final double? imageWidth;
  final bool? isCornerTag;
  const ItemWidget(
      {super.key,
      required this.item,
      required this.isStore,
      required this.store,
      required this.index,
      required this.length,
      this.inStore = false,
      this.isCampaign = false,
      this.isFeatured = false,
      this.fromCartSuggestion = false,
      this.imageHeight,
      this.imageWidth,
      this.isCornerTag = false});

  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Get.find<SplashController>();
    final bool ltr = Get.find<LocalizationController>().isLtr;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    String genericName = '';

    if (!isStore &&
        item!.genericName != null &&
        item!.genericName!.isNotEmpty) {
      for (String name in item!.genericName!) {
        genericName += name;
      }
    }
    if (isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType =
          store!.discount != null ? store!.discount!.discountType : 'percent';
      isAvailable = store!.open == 1 && store!.active!;
    } else {
      discount = (item!.storeDiscount == 0 || isCampaign)
          ? item!.discount
          : item!.storeDiscount;
      discountType = (item!.storeDiscount == 0 || isCampaign)
          ? item!.discountType
          : 'percent';
      isAvailable = DateConverter.isAvailable(
          item!.availableTimeStarts, item!.availableTimeEnds);
    }

    return RepaintBoundary(
      child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: ResponsiveHelper.isDesktop(context)
              ? null
              : const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
            ],
          ),
          child: CustomInkWell(
            onTap: () {
              if (isStore) {
                if (store != null) {
                  if (isFeatured &&
                      splashController.moduleList != null) {
                    for (ModuleModel module
                        in splashController.moduleList!) {
                      if (module.id == store!.moduleId) {
                        splashController.setModule(module);
                        break;
                      }
                    }
                  }
                  Get.toNamed(
                    RouteHelper.getStoreRoute(
                        id: store!.id, page: isFeatured ? 'module' : 'item'),
                    arguments:
                        StoreScreen(store: store, fromModule: isFeatured),
                  );
                }
              } else {
                if (isFeatured &&
                    splashController.moduleList != null) {
                  for (ModuleModel module
                      in splashController.moduleList!) {
                    if (module.id == item!.moduleId) {
                      splashController.setModule(module);
                      break;
                    }
                  }
                }
                Get.find<ItemController>().navigateToItemPage(item, context,
                    inStore: inStore, isCampaign: isCampaign);
              }
            },
            radius: Dimensions.radiusDefault,
            // padding: ResponsiveHelper.isDesktop(context)
            //     ? EdgeInsets.all(fromCartSuggestion
            //         ? Dimensions.paddingSizeExtraSmall
            //         : Dimensions.paddingSizeSmall)
            // : const EdgeInsets.symmetric(
            //     horizontal: Dimensions.paddingSizeSmall,
            //     vertical: Dimensions.paddingSizeExtraSmall),
            child: _buildWithOptionalHover(builder: (hovered) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: desktop
                              ? 0
                              : 0 /* Dimensions.paddingSizeExtraSmall */),
                      child: Column(children: [
                        Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft:
                                  Radius.circular(Dimensions.radiusDefault),
                            ),
                            child: CustomImage(
                              isHovered: hovered,
                              image:
                                  '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                              height: imageHeight ??
                                  (desktop
                                      ? 120
                                      : length == null
                                          ? 120
                                          : ResponsiveHelper.isTab(context)
                                              ? 150
                                              : 115),
                              width: double
                                  .infinity /* imageWidth ?? (desktop ? 120 : 90) */,
                              fit: BoxFit.fill,
                            ),
                          ),
                          (isStore || isCornerTag!)
                              ? DiscountTag(
                                  discount: discount,
                                  discountType: discountType,
                                  freeDelivery:
                                      isStore ? store!.freeDelivery : false,
                                )
                              : const SizedBox(),
                          !isStore
                              ? OrganicTag(item: item!, placeInImage: true)
                              : const SizedBox(),
                          isAvailable
                              ? const SizedBox()
                              : NotAvailableWidget(isStore: isStore),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GetBuilder<FavouriteController>(
                                builder: (favouriteController) {
                              bool isWished = isStore
                                  ? favouriteController.wishStoreIdList
                                      .contains(store!.id)
                                  : favouriteController.wishItemIdList
                                      .contains(item!.id);
                              return CustomFavouriteWidget(
                                isWished: isWished,
                                isStore: isStore,
                                store: store,
                                item: item,
                              );
                            }),
                          ),
                        ]),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Padding(
                            padding: ResponsiveHelper.isDesktop(context)
                                ? EdgeInsets.all(fromCartSuggestion
                                    ? Dimensions.paddingSizeExtraSmall
                                    : Dimensions.paddingSizeSmall)
                                : const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            isStore
                                                ? store!.name!
                                                : item!.name!,
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                            width: ResponsiveHelper.isDesktop(
                                                    context)
                                                ? 20
                                                : 0),
                                      ]),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  (!isStore &&
                                          splashController
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .vegNonVeg! &&
                                          splashController
                                              .configModel!
                                              .toggleVegNonVeg!)
                                      ? Image.asset(
                                          item != null && item!.veg == 0
                                              ? Images.nonVegImage
                                              : Images.vegImage,
                                          height: 10,
                                          width: 10,
                                          fit: BoxFit.contain)
                                      : const SizedBox(),
                                  const SizedBox(),
                                  SizedBox(
                                      width: item!.isStoreHalalActive! &&
                                              item!.isHalalItem!
                                          ? Dimensions.paddingSizeExtraSmall
                                          : 0),
                                  !isStore &&
                                          item!.isStoreHalalActive! &&
                                          item!.isHalalItem!
                                      ? const CustomAssetImageWidget(
                                          Images.halalTag,
                                          height: 13,
                                          width: 13)
                                      : const SizedBox(),
                                  // const SizedBox(height: 3),
                                  // (isStore
                                  //         ? store!.address != null
                                  //         : item!.storeName != null)
                                  //     ? Text(
                                  //         isStore
                                  //             ? store!.address ?? ''
                                  //             : item!.storeName ?? '',
                                  //         style: robotoRegular.copyWith(
                                  //           fontSize:
                                  //               Dimensions.fontSizeExtraSmall,
                                  //           color:
                                  //               Theme.of(context).disabledColor,
                                  //         ),
                                  //         maxLines: 1,
                                  //         overflow: TextOverflow.ellipsis,
                                  //       )
                                  //     : const SizedBox(),
                                  (genericName.isNotEmpty)
                                      ? Flexible(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              genericName,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                      height: ((desktop || isStore) &&
                                              (isStore
                                                  ? store!.address != null
                                                  : item!.storeName != null))
                                          ? 3
                                          : 3),
                                  const SizedBox(),
                                  SizedBox(
                                      height: (!isStore && desktop) ? 3 : 0),
                                  isStore
                                      ? const SizedBox()
                                      : Row(children: [
                                          Text(
                                            PriceConverter.convertPrice(
                                                item!.price,
                                                discount: discount,
                                                discountType: discountType),
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                            // textDirection: TextDirection.ltr,
                                          ),
                                          SizedBox(
                                              width: discount! > 0
                                                  ? Dimensions
                                                      .paddingSizeExtraSmall
                                                  : 0),
                                          discount > 0
                                              ? Text(
                                                  PriceConverter.convertPrice(
                                                      item!.price),
                                                  style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeExtraSmall,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                    // decoration: TextDecoration
                                                    //     .lineThrough,
                                                  ),
                                                  textDirection:
                                                      TextDirection.ltr,
                                                )
                                              : const SizedBox(),
                                        ]),
                                ]),
                          ),
                        ),
                      ]),
                    )),
                  ]);
            }),
          ),
        ),
        (!isStore && isCornerTag! == false)
            ? Positioned(
                right: ltr ? 0 : null,
                left: ltr ? null : 0,
                child: CornerDiscountTag(
                  bannerPosition: ltr
                      ? CornerBannerPosition.topRight
                      : CornerBannerPosition.topLeft,
                  elevation: 0,
                  discount: discount,
                  discountType: discountType,
                  freeDelivery: isStore ? store!.freeDelivery : false,
                ))
            : const SizedBox(),
        Positioned(
          bottom: 110,
          left: 5,
          child: Column(
              mainAxisAlignment: isStore
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                CartCountView(
                  item: item!,
                  index: index,
                ),
              ]),
        )
      ],
    ),
    );
  }

  /// On web: wraps with TextHover for hover effect.
  /// On mobile: passes false directly, skipping MouseRegion + AnimatedContainer.
  Widget _buildWithOptionalHover({required Widget Function(bool isHovered) builder}) {
    if (kIsWeb) {
      return TextHover(builder: builder);
    }
    return builder(false);
  }
}
