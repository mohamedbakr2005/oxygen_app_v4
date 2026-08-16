import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class StoreHeaderInfoWidget extends StatelessWidget {
  final Store? store;
  final String distance;
  const StoreHeaderInfoWidget({super.key, required this.store, required this.distance});

  @override
  Widget build(BuildContext context) {
    if (store == null) return const SizedBox();
    
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info section
          Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store!.name ?? '',
                  style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  children: [
                    Text(
                      '${'minimum_order'.tr} ${PriceConverter.convertPrice(store!.minimumOrder)}',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Delivery Card
          Container(
            margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 5, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                // Time
                Expanded(
                  child: Column(
                    children: [
                      const Text('⏱', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('delivery_time'.tr, style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
                      const SizedBox(height: 2),
                      Text(store!.deliveryTime ?? '--', style: robotoBold.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                // Rating
                Expanded(
                  child: Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('rating'.tr, style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
                      const SizedBox(height: 2),
                      Text(
                        '${store!.avgRating?.toStringAsFixed(1) ?? '0.0'} (${store!.ratingCount ?? 0})', 
                        style: robotoBold.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Theme.of(context).disabledColor.withOpacity(0.2)),
                // Delivery By
                Expanded(
                  child: Column(
                    children: [
                      const Text('♾️', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('delivered_by'.tr, style: robotoRegular.copyWith(fontSize: 11, color: Theme.of(context).disabledColor)),
                      const SizedBox(height: 2),
                      Text(
                        store!.selfDeliverySystem == 1 ? store!.name ?? '' : 'Oxygen Mart',
                        style: robotoBold.copyWith(fontSize: 13, color: Theme.of(context).primaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



}
