import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class StoreMenuItemWidget extends StatelessWidget {
  final Item item;
  final bool inStore;
  const StoreMenuItemWidget({super.key, required this.item, this.inStore = true});

  @override
  Widget build(BuildContext context) {
    double? discount = item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType = item.storeDiscount == 0 ? item.discountType : 'percent';

    return InkWell(
      onTap: () {
        Get.find<ItemController>().navigateToItemPage(item, context, inStore: inStore, isCampaign: false);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)
          ],
        ),
        child: Row(
          children: [
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        PriceConverter.convertPrice(item.price, discount: discount, discountType: discountType),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
                        textDirection: TextDirection.ltr,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      discount! > 0 ? Text(
                        PriceConverter.convertPrice(item.price),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).disabledColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                        textDirection: TextDirection.ltr,
                      ) : const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description ?? '',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            // Image
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50), // make it circular
                    child: CustomImage(
                      image: '${item.imageFullUrl}',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
