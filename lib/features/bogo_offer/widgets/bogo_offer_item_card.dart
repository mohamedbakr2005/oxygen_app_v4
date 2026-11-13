import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:Oxygen_Mart/features/bogo_offer/helper/bogo_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BogoOfferItemCard extends StatelessWidget {
  final BogoOfferCardModel offer;
  final int? moduleId;

  const BogoOfferItemCard({super.key, required this.offer, this.moduleId});

  @override
  Widget build(BuildContext context) {
    final String formattedLabel = BogoHelper.formatOfferLabel(
      buyQty: offer.buyQty,
      getQty: offer.getQty,
      fallback: offer.offerLabel,
    );

    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.getBogoOfferDetailsRoute(
        (offer.slug != null && offer.slug!.isNotEmpty) ? offer.slug! : '${offer.id}', moduleId: moduleId,
      )),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).disabledColor.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImage(
                  image: offer.imageFullUrl ?? '',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    formattedLabel,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            if (offer.description != null && offer.description!.isNotEmpty)
              Text(
                offer.description ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).disabledColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
