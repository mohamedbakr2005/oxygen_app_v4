import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/cart_count_view.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/hover/text_hover.dart';
import 'package:Oxygen_Mart/common/widgets/not_available_widget.dart';
import 'package:Oxygen_Mart/common/widgets/organic_tag.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

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

  const ItemWidget({
    super.key,
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
    this.isCornerTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Get.find<SplashController>();
    final bool desktop = ResponsiveHelper.isDesktop(context);
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    double? discount;
    String? discountType;
    bool isAvailable;

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

    final bool hasDiscount = (discount ?? 0) > 0;

    return RepaintBoundary(
      child: Container(
        margin: desktop
            ? null
            : const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CustomInkWell(
            onTap: () {
              if (isStore) {
                if (store != null) {
                  if (isFeatured && splashController.moduleList != null) {
                    for (ModuleModel module in splashController.moduleList!) {
                      if (module.id == store!.moduleId) {
                        splashController.setModule(module);
                        break;
                      }
                    }
                  }
                  Get.toNamed(
                    RouteHelper.getStoreRoute(
                      id: store!.id,
                      page: isFeatured ? 'module' : 'item',
                    ),
                    arguments:
                        StoreScreen(store: store, fromModule: isFeatured),
                  );
                }
              } else {
                if (isFeatured && splashController.moduleList != null) {
                  for (ModuleModel module in splashController.moduleList!) {
                    if (module.id == item!.moduleId) {
                      splashController.setModule(module);
                      break;
                    }
                  }
                }
                Get.find<ItemController>().navigateToItemPage(
                  item,
                  context,
                  inStore: inStore,
                  isCampaign: isCampaign,
                );
              }
            },
            radius: 18,
            child: _buildWithOptionalHover(
              builder: (hovered) {
                return Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Favorite Icon & Discount Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetBuilder<FavouriteController>(
                            builder: (favouriteController) {
                              final bool isFav = isStore
                                  ? favouriteController.wishStoreIdList
                                      .contains(store?.id)
                                  : favouriteController.wishItemIdList
                                      .contains(item?.id);
                              return InkWell(
                                onTap: () {
                                  if (isLoggedIn) {
                                    if (isFav) {
                                      if (isStore) {
                                        favouriteController
                                            .removeFromFavouriteList(
                                                store?.id, true);
                                      } else {
                                        favouriteController
                                            .removeFromFavouriteList(
                                                item?.id, false);
                                      }
                                    } else {
                                      if (isStore) {
                                        favouriteController.addToFavouriteList(
                                            null, store?.id, true);
                                      } else {
                                        favouriteController.addToFavouriteList(
                                            item, null, false);
                                      }
                                    }
                                  } else {
                                    showCustomSnackBar(
                                        'you_are_not_logged_in'.tr);
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border_rounded,
                                    color: isFav
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .disabledColor
                                            .withValues(alpha: 0.8),
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '-${discountType == 'percent' ? '${discount!.toInt()}%' : PriceConverter.convertPrice(discount)}',
                                style: robotoBold.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFFE02424),
                                ),
                              ),
                            )
                          else
                            const SizedBox(),
                        ],
                      ),

                      // Product Image
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomImage(
                                  isHovered: hovered,
                                  image: isStore
                                      ? (store?.logoFullUrl ?? '')
                                      : (item?.imageFullUrl ?? ''),
                                  fit: isStore
                                      ? BoxFit.cover
                                      : BoxFit.contain,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                                if (!isStore && item != null)
                                  OrganicTag(item: item!, placeInImage: true),
                                if (!isAvailable)
                                  Positioned.fill(
                                    child: NotAvailableWidget(
                                        isStore: isStore),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Add to Cart Button (Circular Outline)
                      if (!isStore && isAvailable)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CartCountView(
                            item: item!,
                            index: index,
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),

                      // Product Title
                      Text(
                        (isStore ? store?.name : item?.name) ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Price & Unit
                      if (!isStore) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                PriceConverter.convertPrice(
                                  item!.price,
                                  discount: discount,
                                  discountType: discountType,
                                ),
                                style: robotoBold.copyWith(
                                  fontSize: 13,
                                  color: Theme.of(context).primaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item?.unitType != null &&
                                item!.unitType!.isNotEmpty)
                              Text(
                                ' / ${item!.unitType}',
                                style: robotoRegular.copyWith(
                                  fontSize: 10,
                                  color: Theme.of(context).disabledColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        if (hasDiscount)
                          Text(
                            PriceConverter.convertPrice(item!.price),
                            style: robotoRegular.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).disabledColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ] else if (store?.address != null)
                        Text(
                          store!.address ?? '',
                          style: robotoRegular.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).disabledColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// On web: wraps with TextHover for hover effect.
  /// On mobile: passes false directly, skipping MouseRegion + AnimatedContainer.
  Widget _buildWithOptionalHover(
      {required Widget Function(bool isHovered) builder}) {
    if (kIsWeb) {
      return TextHover(builder: builder);
    }
    return builder(false);
  }
}
