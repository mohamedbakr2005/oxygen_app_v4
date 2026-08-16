import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/title_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/components/custom_circle_list_view_package.dart';
import 'package:Oxygen_Mart/features/item/controllers/campaign_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class CircleListView extends StatefulWidget {
  const CircleListView({super.key});

  @override
  State<CircleListView> createState() => _CircleListViewState();
}

class _CircleListViewState extends State<CircleListView> {
  int currentIndex = 0;
  List<Item> itemCampaignList = [];

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return GetBuilder<CampaignController>(builder: (campaignController) {
      if (campaignController.itemCampaignList != null) {
        itemCampaignList = [];
        if (campaignController.itemCampaignList!.length == 1) {
          for (int i = 0; i < 3; i++) {
            itemCampaignList.add(campaignController.itemCampaignList![0]);
          }
        } else if (campaignController.itemCampaignList!.length == 2) {
          for (int i = 0; i < 3; i++) {
            itemCampaignList.add(campaignController.itemCampaignList![i % 2]);
          }
        } else {
          itemCampaignList.addAll(campaignController.itemCampaignList!);
        }
      }

      return campaignController.itemCampaignList != null
          ? itemCampaignList.isNotEmpty
              ? SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    controller: PageController(),
                    itemCount: itemCampaignList.length,
                    itemBuilder: ((context, index) {
                      return Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Gallery3D(
                                controller: Gallery3DController(
                                    itemCount: itemCampaignList.length),
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                isClip: true,
                                onItemChanged: (index) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                itemConfig: const GalleryItemConfig(
                                  width: 220,
                                  height: 200,
                                  radius: 10,
                                  isShowTransformMask: false,
                                ),
                                onClickItem: (index) {
                                  if (kDebugMode) print("currentIndex:$index");
                                },
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      final item = itemCampaignList[index];

                                      analytics.logEvent(
                                        name: 'select_item',
                                        parameters: {
                                          'item_id': item.id!,
                                          'item_name': item.name!,
                                          'list_name': 'just_for_you',
                                          'index': index,
                                          'is_campaign': true,
                                        },
                                      );

                                      Get.find<ItemController>()
                                          .navigateToItemPage(
                                        item,
                                        context,
                                        isCampaign: true,
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault),
                                      child: CustomImage(
                                        image:
                                            '${itemCampaignList[index].imageFullUrl}',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                      );
                    }),
                  ),
                )
              : const SizedBox.shrink()
          : const CircleListViewShimmerView();
    });
  }
}

class CircleListViewShimmerView extends StatelessWidget {
  const CircleListViewShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child: TitleWidget(
            title: 'just_for_you'.tr,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          child: SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
              controller: PageController(),
              itemCount: 3,
              itemBuilder: ((context, index) {
                return Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Gallery3D(
                          controller: Gallery3DController(itemCount: 3),
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          isClip: true,
                          itemConfig: const GalleryItemConfig(
                            width: 220,
                            height: 200,
                            radius: 10,
                            isShowTransformMask: false,
                          ),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                              child: Shimmer.fromColors(
                                period: const Duration(milliseconds: 2000),
                                baseColor: Colors.grey,
                                highlightColor: Colors.white,
                                enabled: true,
                                child: Container(
                                  color: Colors.grey[300],
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }
}
