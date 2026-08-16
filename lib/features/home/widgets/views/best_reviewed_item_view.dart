import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/title_widget.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BestReviewItemView extends StatelessWidget {
  const BestReviewItemView({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final ScrollController scrollController = ScrollController();

    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? reviewItemList = itemController.reviewedItemList;

      if (reviewItemList == null) {
        return const BestReviewItemShimmer();
      }

      if (reviewItemList.isEmpty) {
        return const SizedBox();
      }

      return Container(
        color: Theme.of(context).cardColor,
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              child: TitleWidget(
                title: 'you_may_also_like'.tr,
                onTap: () {
                  Get.toNamed(RouteHelper.getPopularItemRoute(false, false));
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            SizedBox(
              height: 260,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemCount: reviewItemList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeDefault),
                    child: _buildMinimalProductCard(
                        context, reviewItemList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMinimalProductCard(BuildContext context, Item item) {
    return InkWell(
      onTap: () {
        Get.find<ItemController>().navigateToItemPage(item, context);
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: CustomImage(
                    image: '${item.imageFullUrl}',
                    fit: BoxFit.contain,
                    height: 160,
                    width: 140,
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: 0,
                  child: InkWell(
                    onTap: () {
                      // ✅ تم التصحيح: استخدام الدالة الموجودة فعلياً في الكنترولر
                      Get.find<ItemController>()
                          .itemDirectlyAddToCart(item, context);
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  PriceConverter.convertPrice(item.price),
                  style: robotoBold.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.name ?? '',
              style: robotoRegular.copyWith(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}

class BestReviewItemShimmer extends StatelessWidget {
  const BestReviewItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 20, width: 100, color: Colors.grey[300]),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    children: [
                      Container(
                        height: 160,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(height: 15, width: 80, color: Colors.white),
                      const SizedBox(height: 5),
                      Container(height: 10, width: 100, color: Colors.white),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
