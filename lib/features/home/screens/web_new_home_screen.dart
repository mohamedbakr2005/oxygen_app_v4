import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:Oxygen_Mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/module_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_category_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_flash_sale_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_highlight_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_item_that_you_love_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_just_for_you_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_most_popular_item_banner_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_most_popular_item_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_new_banner_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_special_offer_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/web_top_offers_near_me.dart';
import 'package:Oxygen_Mart/features/item/controllers/campaign_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:Oxygen_Mart/features/home/widgets/module_list_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/store_card_widget.dart';

class WebNewHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  const WebNewHomeScreen({super.key, required this.scrollController});

  @override
  State<WebNewHomeScreen> createState() => _WebNewHomeScreenState();
}

class _WebNewHomeScreenState extends State<WebNewHomeScreen> {
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();
    _isLogin = AuthHelper.isLoggedIn();
    Get.find<SplashController>().getWebSuggestedLocationStatus();

    if (_isLogin) {
      suggestAddressBottomSheet();
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (!Get.find<SplashController>().webSuggestedLocation && active) {
      Future.delayed(const Duration(seconds: 1), () {
        Get.dialog(const Center(
            child: SizedBox(
                height: 470,
                width: 550,
                child: AddressBottomSheetWidget(fromDialog: true))));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy;
    bool isFood = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.food;
    bool isShop = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;
    bool isGrocery = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.grocery;
    Get.find<BannerController>().setCurrentIndex(0, false);

    // For non-grocery modules (pharmacy, food, shop), show store list first
    // exactly like the mobile flow: pick a store → enter it
    final bool showStoreListOnly = !isGrocery && (isPharmacy || isFood || isShop);

    return Stack(clipBehavior: Clip.none, children: [
      SizedBox(height: context.height),
      CustomScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 500,
                                child: GetBuilder<BannerController>(
                                    builder: (bannerController) {
                                  return const SizedBox(
                                    width: double.infinity,
                                    child: WebNewBannerViewWidget(
                                        isFeatured: false),
                                  );
                                }),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeDefault),
                              GetBuilder<StoreController>(
                                  builder: (storeController) {
                                return GetBuilder<FlashSaleController>(
                                    builder: (flashController) {
                                  return const Expanded(
                                      child: WebFlashSaleViewWidget());
                                });
                              }),
                            ]),

                        GetBuilder<SplashController>(builder: (splashController) {
                          return (splashController.moduleList != null && splashController.moduleList!.isNotEmpty)
                              ? const SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge),
                                    child: ModuleListWidget(),
                                  ),
                                )
                              : const SizedBox();
                        }),

                        // ─── Non-Grocery modules: show store list (mobile flow) ────────────
                        if (showStoreListOnly) ...
                          [const _WebModuleStoreListSection()]
                        else ...
                          [
                            // ─── Grocery: full home content ──────────────────────────────
                            GetBuilder<CategoryController>(
                                builder: (categoryController) {
                              return categoryController.categoryList == null
                                  ? WebCategoryViewWidget(
                                      categoryController: categoryController)
                                  : categoryController.categoryList!.isEmpty
                                      ? const SizedBox()
                                      : WebCategoryViewWidget(
                                          categoryController: categoryController);
                            }),

                            _isLogin ? const SizedBox() : const SizedBox(),

                            const WebSpecialOfferView(isFood: false, isShop: false),

                            const WebHighlightWidget(),

                            const WebMostPopularItemViewWidget(isFood: false, isShop: false),

                            GetBuilder<CampaignController>(
                                builder: (campaignController) {
                              return campaignController.basicCampaignList == null
                                  ? WebMostPopularItemBannerViewWidget(
                                      campaignController: campaignController)
                                  : campaignController.basicCampaignList!.isEmpty
                                      ? const SizedBox()
                                      : WebMostPopularItemBannerViewWidget(
                                          campaignController: campaignController);
                            }),

                            const WebJustForYouViewWidget(),

                            const WebTopOffersNearMe(
                                isFood: false,
                                isPharmacy: false,
                                isShop: false),

                            const WebItemThatYouLoveViewWidget(),
                          ],
                      ])),
            ),
          ),
          SliverToBoxAdapter(
            child: GetBuilder<StoreController>(builder: (storeController) {
              return const FooterView(
                child: SizedBox(width: Dimensions.webMaxWidth),
              );
            }),
          ),
        ],
      ),
      const Positioned(
          right: 0, top: 0, bottom: 0, child: Center(child: ModuleWidget())),
    ]);
  }
}

/// Web-only widget that shows the store list for non-grocery modules.
/// Replicates the mobile "All Stores" screen behaviour on the web.
class _WebModuleStoreListSection extends StatelessWidget {
  const _WebModuleStoreListSection();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      final splashCtrl = Get.find<SplashController>();
      final moduleName = splashCtrl.module?.moduleName ?? '';
      final stores = storeController.storeModel?.stores;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault),
            child: Text(
              moduleName,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeOverLarge,
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Store grid — 3 columns on web desktop
          stores == null
              ? _WebStoreGridSkeleton()
              : stores.isEmpty
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 60),
                        child: Text('no_store_available'.tr,
                            style: robotoMedium),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: Dimensions.paddingSizeDefault,
                        mainAxisSpacing: Dimensions.paddingSizeLarge,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        return StoreCardWidget(store: stores[index]);
                      },
                    ),

          const SizedBox(height: 80),
        ],
      );
    });
  }
}

class _WebStoreGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[100]!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: Dimensions.paddingSizeDefault,
        mainAxisSpacing: Dimensions.paddingSizeLarge,
        childAspectRatio: 1.05,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner placeholder
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusDefault)),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    color: baseColor,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      Container(
                          height: 11,
                          width: 180,
                          decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
