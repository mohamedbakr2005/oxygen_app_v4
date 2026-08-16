import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/title_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class SpecialOfferView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const SpecialOfferView(
      {super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? discountedItemList = itemController.discountedItemList;

      // print()

      return discountedItemList != null
          ? discountedItemList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault),
                  child: Container(
                    width: Get.width,
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusExtraLarge),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.15),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                          Theme.of(context).cardColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -15,
                          right: -15,
                          child: Icon(
                            Icons.local_offer_rounded,
                            size: 100,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeSmall,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          Images.discountOfferIcon,
                                          height: 24,
                                          width: 24,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSmall),
                                      Text(
                                        'special_offer'.tr,
                                        style: robotoBlack.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraLarge,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => Get.toNamed(
                                        RouteHelper.getPopularItemRoute(
                                            false, true)),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusLarge),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'see_all'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_forward_ios,
                                              size: 12, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 380,
                              width: Get.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(
                                    left: Dimensions.paddingSizeDefault),
                                itemCount: discountedItemList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeDefault,
                                        right: Dimensions.paddingSizeDefault,
                                        top: Dimensions.paddingSizeSmall),
                                    child: MostPopularItemCard(
                                        item: discountedItemList[index]),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox()
          : const SpecialOfferShimmerView();
    });
  }
}

class SpecialOfferShimmerView extends StatelessWidget {
  const SpecialOfferShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Container(
        width: Get.width,
        margin:
            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeSmall,
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Container(
                          height: 25,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 310,
              width: Get.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeSmall),
                    child: Shimmer.fromColors(
                      period: const Duration(milliseconds: 2000),
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: Container(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall),
                        height: 310,
                        width: 175,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                        ),
                        child: Column(children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                                height: 15,
                                width: 100,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                                height: 20,
                                width: 150,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Container(
                                height: 15,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemShimmerView extends StatelessWidget {
  final bool isPopularItem;
  const ItemShimmerView({super.key, required this.isPopularItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Container(
        color: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title:
                  isPopularItem ? 'most_popular_items'.tr : 'special_offer'.tr,
              image: isPopularItem
                  ? Images.mostPopularIcon
                  : Images.discountOfferIcon,
            ),
          ),
          SizedBox(
            height: 300,
            width: Get.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeDefault),
                  child: Shimmer.fromColors(
                    period: const Duration(milliseconds: 2000),
                    baseColor: Colors.grey,
                    highlightColor: Colors.white,
                    enabled: true,
                    child: Container(
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall),
                      height: 300,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      child: Column(children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Column(children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                              ),
                              height: 15,
                              width: 100,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                              ),
                              height: 20,
                              width: 200,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Container(
                              height: 15,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
