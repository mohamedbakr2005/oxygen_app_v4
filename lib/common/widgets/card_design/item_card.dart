import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/add_favourite_view.dart';
import 'package:Oxygen_Mart/common/widgets/cart_count_view.dart';
import 'package:Oxygen_Mart/common/widgets/custom_asset_image_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/discount_tag.dart';
import 'package:Oxygen_Mart/common/widgets/hover/on_hover.dart';
import 'package:Oxygen_Mart/common/widgets/hover/text_hover.dart';
import 'package:Oxygen_Mart/common/widgets/not_available_widget.dart';
import 'package:Oxygen_Mart/common/widgets/organic_tag.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;

  const ItemCard({
    super.key,
    required this.item,
    this.isPopularItem = false,
    required this.isFood,
    required this.isShop,
    this.isPopularItemCart = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    double? discount =
        item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType =
        item.storeDiscount == 0 ? item.discountType : 'percent';

    // RepaintBoundary isolates this card's repaints from siblings
    return RepaintBoundary(
      child: _buildCardContent(context, discount, discountType),
    );
  }

  Widget _buildCardContent(BuildContext context, double? discount, String? discountType) {
    final cardWidget = Container(
        width: 175,
        // MODERN TWEAK 1: Ultra-soft shadow + subtle border for a clean glass/premium feel
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          color: Theme.of(context).cardColor,
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03), // Lighter, softer shadow
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8), // Pushed slightly down
            ),
          ],
        ),
        child: CustomInkWell(
          onTap: () =>
              Get.find<ItemController>().navigateToItemPage(item, context),
          radius: Dimensions.radiusLarge,
          child: _buildWithOptionalHover(
          context,
          builder: (isHovered) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MODERN TWEAK 2: Give the image more space (flex 6 instead of 5)
                  Expanded(
                    flex: 7,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // Slightly lighter background so the image pops
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.02),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withOpacity(0.1),
                              width: 1,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(Dimensions.radiusLarge),
                              topRight: Radius.circular(Dimensions.radiusLarge),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(Dimensions.radiusLarge),
                              topRight: Radius.circular(Dimensions.radiusLarge),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: CustomImage(
                                isHovered: isHovered,
                                placeholder: Images.placeholder,
                                image: '${item.imageFullUrl}',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        AddFavouriteView(item: item),
                        if (item.isStoreHalalActive! && item.isHalalItem!)
                          const Positioned(
                            top: 40,
                            right: 15,
                            child: CustomAssetImageWidget(
                              Images.halalTag,
                              height: 20,
                              width: 20,
                            ),
                          ),
                        DiscountTag(
                          discount: discount,
                          discountType: discountType,
                          freeDelivery: false,
                        ),
                        OrganicTag(item: item, placeInImage: false),
                        if (item.stock != null && item.stock! < 0)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeExtraSmall,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withOpacity(
                                        0.9), // Out of stock looks better in red/error color
                                borderRadius: const BorderRadius.only(
                                  topRight:
                                      Radius.circular(Dimensions.radiusLarge),
                                  bottomRight:
                                      Radius.circular(Dimensions.radiusLarge),
                                ),
                              ),
                              child: Text(
                                'out_of_stock'.tr,
                                style: robotoMedium.copyWith(
                                  // Slightly bolder
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                        if (!Get.find<ItemController>().isAvailable(item))
                          NotAvailableWidget(
                            radius: Dimensions.radiusLarge,
                            isAllSideRound: isPopularItem,
                          ),
                      ],
                    ),
                  ),

                  // MODERN TWEAK 3: Less flex for text, tighter layout (flex 5 to 4 or dynamic)
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeSmall,
                        Dimensions.paddingSizeSmall,
                        Dimensions.paddingSizeSmall,
                        Dimensions.paddingSizeSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: isPopularItem
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // Distribute evenly
                        children: [
                          Column(
                            crossAxisAlignment: isPopularItem
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              if (isFood || isShop)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    item.storeName ?? '',
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).disabledColor,
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      letterSpacing:
                                          0.2, // Adds a premium touch to small caps
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              Text(
                                item.name ?? '',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.9),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (discount != null && discount > 0)
                                      Text(
                                        PriceConverter.convertPrice(
                                            Get.find<ItemController>()
                                                .getStartingPrice(item)),
                                        style: robotoMedium.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color:
                                              Theme.of(context).disabledColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>()
                                            .getStartingPrice(item),
                                        discount: discount,
                                        discountType: discountType,
                                      ),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              (!isShop)
                                  ? CartCountView(item: item, index: index)
                                  : CartCountView(
                                      item: item,
                                      index: index,
                                      child: Container(
                                        height:
                                            36, // Slightly larger touch target
                                        width: 36,
                                        // MODERN TWEAK 4: Squircle shape instead of perfect circle for the button
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: Icon(
                                          isPopularItemCart
                                              ? Icons.shopping_cart_outlined
                                              : Icons
                                                  .add_rounded, // Rounded icons look more modern
                                          color: Theme.of(context).cardColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );  

    // OnHover adds AnimatedContainer + MouseRegion + BoxShadow per card.
    // On mobile, hover never fires — pure overhead × 150 cards.
    if (kIsWeb) {
      return OnHover(isItem: true, child: cardWidget);
    }
    return cardWidget;
  }

  /// On web: wraps with TextHover for hover effect.
  /// On mobile: passes false directly, skipping MouseRegion + AnimatedContainer overhead.
  Widget _buildWithOptionalHover(BuildContext context, {required Widget Function(bool isHovered) builder}) {
    if (kIsWeb) {
      return TextHover(builder: builder);
    }
    return builder(false);
  }
}
