import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/discount_tag.dart';
import 'package:Oxygen_Mart/common/widgets/title_widget.dart';
import 'package:Oxygen_Mart/features/item/controllers/campaign_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class JustForYouView extends StatelessWidget {
  const JustForYouView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
      if (campaignController.itemCampaignList == null) {
        return const JustForYouShimmerView();
      }

      if (campaignController.itemCampaignList!.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title: 'just_for_you'.tr,
              onTap: () {
                Get.toNamed(RouteHelper.getItemCampaignRoute(isJustForYou: true));
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: campaignController.itemCampaignList!.length,
              itemBuilder: (context, index) {
                final item = campaignController.itemCampaignList![index];
                return _ModernItemCard(item: item);
              },
            ),
          ),
        ]),
      );
    });
  }
}

class _ModernItemCard extends StatelessWidget {
  final Item item;
  const _ModernItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<ItemController>().navigateToItemPage(item, context, isCampaign: true);
      },
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: const Color(0xFFFF416C).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF416C).withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image and Discount
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge - 1.5)),
                  child: CustomImage(
                    image: '${item.imageFullUrl}',
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (item.discount! > 0)
                  Positioned(
                    top: 10,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4B2B), Color(0xFFFF416C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF416C).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔥 ',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            item.discountType == 'percent' 
                                ? '${item.discount!.toStringAsFixed(0)}% OFF'
                                : '${PriceConverter.convertPrice(item.discount)} OFF',
                            style: robotoBold.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeSmall,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.discount! > 0)
                        Text(
                          PriceConverter.convertPrice(item.price),
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey.shade500,
                            decorationThickness: 1.5,
                          ),
                        ),
                      Text(
                        PriceConverter.convertPrice(item.price, discount: item.discount, discountType: item.discountType),
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge, 
                          color: const Color(0xFFFF4B2B),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class JustForYouShimmerView extends StatelessWidget {
  const JustForYouShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: TitleWidget(title: 'just_for_you'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 175,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
