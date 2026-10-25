import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ItemDetailsRelatedCardWidget extends StatelessWidget {
  final Item item;
  final bool inStorePage;

  const ItemDetailsRelatedCardWidget({super.key,
    required this.item, this.inStorePage = false,
  });

  @override
  Widget build(BuildContext context) {
    final double? startingPrice = item.price;
    final double? discount = (item.availableDateStarts != null || (item.storeDiscount ?? 0) == 0)
        ? item.discount
        : item.storeDiscount;
    final String? discountType = (item.availableDateStarts != null || (item.storeDiscount ?? 0) == 0)
        ? item.discountType
        : 'percent';
    final bool hasDiscount = (discount ?? 0) > 0;
    final bool isLoggedIn = AuthHelper.isLoggedIn();

    return InkWell(
      onTap: () {
        Get.find<ItemController>().navigateToItemPage(item, context, inStore: inStorePage);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).disabledColor.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Discount tag & Favorite Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetBuilder<FavouriteController>(builder: (favouriteController) {
                  final bool isFav = favouriteController.wishItemIdList.contains(item.id);
                  return InkWell(
                    onTap: () {
                      if (isLoggedIn) {
                        if (isFav) {
                          favouriteController.removeFromFavouriteList(item.id, false);
                        } else {
                          favouriteController.addToFavouriteList(item, null, false);
                        }
                      } else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border_rounded,
                        color: isFav ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                  );
                }),
                if (hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

            // Product Image (Clean contain, not stretched)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CustomImage(
                    image: item.imageFullUrl ?? '',
                    fit: BoxFit.contain,
                    height: 100,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            // Add Button
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Get.find<ItemController>().itemDirectlyAddToCart(item, context, inStore: inStorePage);
                },
                borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 6),

            // Product Title
            Text(
              item.name ?? '',
              style: robotoMedium.copyWith(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Price & Unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType),
                    style: robotoBold.copyWith(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.unitType != null && item.unitType!.isNotEmpty)
                  Text(
                    ' / ${item.unitType}',
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
                PriceConverter.convertPrice(startingPrice),
                style: robotoRegular.copyWith(
                  fontSize: 10,
                  color: Theme.of(context).disabledColor,
                  decoration: TextDecoration.lineThrough,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
