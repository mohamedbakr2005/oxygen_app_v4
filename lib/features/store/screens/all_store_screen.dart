import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/card_design/food_store_circular_card_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/item_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/web_page_title_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class AllStoreScreen extends StatefulWidget {
  final bool isPopular;
  final bool isFeatured;
  final bool isNearbyStore;
  final bool isTopOfferStore;
  const AllStoreScreen({super.key, required this.isPopular, required this.isFeatured, required this.isNearbyStore, required this.isTopOfferStore});

  @override
  State<AllStoreScreen> createState() => _AllStoreScreenState();
}

class _AllStoreScreenState extends State<AllStoreScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.isFeatured) {
      Get.find<StoreController>().getFeaturedStoreList(reload: true);
    } else if (widget.isPopular) {
      Get.find<StoreController>().getPopularStoreList(true, 'all', true);
    } else if (widget.isTopOfferStore) {
      Get.find<StoreController>().getTopOfferStoreList(true, true);
    } else {
      Get.find<StoreController>().getLatestStoreList(true, 'all', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showRestaurantText = Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false;

    return GetBuilder<StoreController>(builder: (storeController) {
      return Scaffold(
        appBar: CustomAppBar(
          title: widget.isFeatured
              ? 'featured_stores'.tr
              : widget.isPopular
                  ? showRestaurantText
                      ? widget.isNearbyStore
                          ? 'best_store_nearby'.tr
                          : 'popular_restaurants'.tr
                      : widget.isNearbyStore
                          ? 'best_store_nearby'.tr
                          : 'popular_stores'.tr
                  : widget.isTopOfferStore
                      ? 'top_offers_near_me'.tr
                      : '${'new_on'.tr} ${AppConstants.appName}',
          type: widget.isFeatured ? null : storeController.type,
          onVegFilterTap: (String type) {
            if (widget.isPopular) {
              Get.find<StoreController>().getPopularStoreList(true, type, true);
            } else {
              Get.find<StoreController>().getLatestStoreList(true, type, true);
            }
          },
        ),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: RefreshIndicator(
          onRefresh: () async {
            if (widget.isFeatured) {
              await Get.find<StoreController>().getFeaturedStoreList();
            } else if (widget.isPopular) {
              await Get.find<StoreController>().getPopularStoreList(
                true,
                Get.find<StoreController>().type,
                false,
              );
            } else {
              await Get.find<StoreController>().getLatestStoreList(
                true,
                Get.find<StoreController>().type,
                false,
              );
            }
          },
          child: SingleChildScrollView(
              controller: scrollController,
              child: FooterView(
                  child: Column(
                children: [
                  WebScreenTitleWidget(
                    title: widget.isFeatured
                        ? 'featured_stores'.tr
                        : widget.isPopular
                            ? showRestaurantText
                                ? 'popular_restaurants'.tr
                                : 'popular_stores'.tr
                            : widget.isTopOfferStore
                                ? 'top_offers_near_me'.tr
                                : '${'new_on'.tr} ${AppConstants.appName}',
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: GetBuilder<StoreController>(builder: (storeController) {
                      final stores = widget.isFeatured
                          ? storeController.featuredStoreList
                          : widget.isPopular
                              ? storeController.popularStoreList
                              : widget.isTopOfferStore
                                  ? storeController.topOfferStoreList
                                  : storeController.latestStoreList;

                      final bool isFoodModule = Get.find<SplashController>().module?.moduleType.toString() == AppConstants.food;

                      if (stores != null && stores.isNotEmpty && isFoodModule) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: Dimensions.paddingSizeSmall,
                            crossAxisSpacing: Dimensions.paddingSizeSmall,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: stores.length,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          itemBuilder: (context, index) {
                            return FoodStoreCircularCardWidget(store: stores[index]);
                          },
                        );
                      }

                      return ItemsView(
                        isStore: true,
                        items: null,
                        isFeatured: widget.isFeatured,
                        noDataText: widget.isFeatured
                            ? 'no_store_available'.tr
                            : showRestaurantText
                                ? 'no_restaurant_available'.tr
                                : 'no_store_available'.tr,
                        stores: stores,
                      );
                    }),
                  ),
                  const SizedBox(height: 100),
                ],
              ))),
        ),
      );
    });
  }
}
