import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/card_design/store_card_with_distance.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_new_on_view_widget.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/common/widgets/title_widget.dart';

class RecommendedStoreView extends StatelessWidget {
  const RecommendedStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.recommendedStoreList;

      return storeList != null
          ? storeList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: TitleWidget(
                        title: 'recommended_store'.tr,
                        onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute('recommended')),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                        itemCount: storeList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: Dimensions.paddingSizeDefault,
                              bottom: Dimensions.paddingSizeSmall,
                              top: Dimensions.paddingSizeSmall,
                            ),
                            child: StoreCardWithDistance(store: storeList[index]),
                          );
                        },
                      ),
                    ),
                  ]),
                )
              : const SizedBox.shrink()
          : const WebNewOnShimmerView();
    });
  }
}
