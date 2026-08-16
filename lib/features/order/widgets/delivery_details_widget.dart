import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class DeliveryDetailsWidget extends StatelessWidget {
  final bool from;
  final String? address;
  const DeliveryDetailsWidget({super.key, this.from = true, this.address});

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        from ? const Color(0xFF2F80ED) : Theme.of(context).primaryColor;

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          from ? Icons.storefront_outlined : Icons.location_on_outlined,
          size: 22,
          color: accentColor,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          from ? 'from_store'.tr : 'to'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          address ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).disabledColor,
            height: 1.35,
          ),
        )
      ])),
    ]);
  }
}
