import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/card_design/food_store_circular_card_widget.dart';
import 'package:Oxygen_Mart/common/widgets/card_design/store_card_with_distance.dart';
import 'package:Oxygen_Mart/common/widgets/item_shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/item_widget.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/features/home/widgets/web/widgets/store_card_widget.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/features/store/widgets/store_menu_item_widget.dart';
import 'package:Oxygen_Mart/common/widgets/card_design/item_card.dart';

class ItemsView extends StatefulWidget {
  final List<Item?>? items;
  final List<Store?>? stores;
  final bool isStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inStorePage;
  final bool isFeatured;
  final bool? isFoodOrGrocery;
  final ScrollController? scrollController;

  /// When true, returns a SliverGrid (or SliverToBoxAdapter) instead of
  /// a Column wrapping a GridView. Use this when the parent is a
  /// CustomScrollView to enable true lazy rendering.
  final bool returnSliverWidget;

  const ItemsView(
      {super.key,
      required this.stores,
      required this.items,
      required this.isStore,
      this.isScrollable = false,
      this.shimmerLength = 20,
      this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
      this.noDataText,
      this.isCampaign = false,
      this.inStorePage = false,
      this.isFeatured = false,
      this.isFoodOrGrocery = true,
      this.scrollController,
      this.returnSliverWidget = false});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {

  /// Shared grid delegate computation used by both sliver and non-sliver paths.
  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate(BuildContext context, bool isFoodCircularLayout) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisSpacing: ResponsiveHelper.isDesktop(context)
          ? Dimensions.paddingSizeExtremeLarge
          : widget.stores != null
              ? Dimensions.paddingSizeSmall
              : Dimensions.paddingSizeSmall,
      mainAxisSpacing: ResponsiveHelper.isDesktop(context)
          ? Dimensions.paddingSizeExtremeLarge
          : widget.stores != null && widget.isStore
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeSmall,
      mainAxisExtent: isFoodCircularLayout
          ? 130
          : ResponsiveHelper.isDesktop(context) && widget.isStore
              ? 220
              : ResponsiveHelper.isMobile(context)
                  ? widget.stores != null && widget.isStore
                      ? 200
                      : (widget.inStorePage && !widget.isStore)
                          ? (Get.find<SplashController>().module?.moduleType == AppConstants.ecommerce || Get.find<SplashController>().module?.moduleType == AppConstants.grocery ? 280 : 130)
                          : ResponsiveHelper.isTab(context)?250: 220
                  : (widget.inStorePage && !widget.isStore) ? 130 : 290,
      crossAxisCount: isFoodCircularLayout
          ? 3
          : ResponsiveHelper.isTab(context)? (widget.inStorePage && !widget.isStore ? 2 : 4) :ResponsiveHelper.isMobile(context)
              ? (widget.inStorePage && !widget.isStore ? (Get.find<SplashController>().module?.moduleType == AppConstants.ecommerce || Get.find<SplashController>().module?.moduleType == AppConstants.grocery ? 3 : 1) : 3)
              : ResponsiveHelper.isDesktop(context) &&
                      widget.stores != null
                  ? 4
                  : 4,
    );
  }

  /// Shared item builder used by both sliver and non-sliver paths.
  Widget _buildItem(BuildContext context, int index, int length, bool isFoodCircularLayout) {
    return widget.stores != null && widget.isStore
        ? isFoodCircularLayout
            ? FoodStoreCircularCardWidget(store: widget.stores![index])
            : widget.isFoodOrGrocery! && widget.isStore
                ? StoreCardWidget(store: widget.stores![index])
                : StoreCardWithDistance(
                    store: widget.stores![index]!,
                    fromAllStore: true)
        : (widget.inStorePage && !ResponsiveHelper.isDesktop(context))
            ? (Get.find<SplashController>().module?.moduleType == AppConstants.ecommerce || Get.find<SplashController>().module?.moduleType == AppConstants.grocery
                ? ItemCard(
                    item: widget.items![index]!,
                    isFood: Get.find<SplashController>().module?.moduleType == AppConstants.food,
                    isShop: Get.find<SplashController>().module?.moduleType == AppConstants.ecommerce || Get.find<SplashController>().module?.moduleType == AppConstants.grocery,
                    index: index,
                  )
                : StoreMenuItemWidget(
                    item: widget.items![index]!,
                    inStore: widget.inStorePage,
                  ))
            : ItemWidget(
                isStore: widget.isStore,
                item: widget.isStore ? null : widget.items![index],
                isFeatured: widget.isFeatured,
                store:
                    widget.isStore ? widget.stores![index] : null,
                index: index,
                length: length,
                isCampaign: widget.isCampaign,
                inStore: widget.inStorePage,
              );
  }

  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if (widget.isStore) {
      isNull = widget.stores == null;
      if (!isNull) {
        length = widget.stores!.length;
      }
    } else {
      isNull = widget.items == null;
      if (!isNull) {
        length = widget.items!.length;
      }
    }

    final bool isFoodCircularLayout = widget.isStore &&
        !ResponsiveHelper.isDesktop(context) &&
        Get.find<SplashController>().module?.moduleType.toString() == AppConstants.food;

    // ── Sliver mode: return SliverGrid or SliverToBoxAdapter ──
    if (widget.returnSliverWidget) {
      return _buildSliverContent(context, isNull, length, isFoodCircularLayout);
    }

    // ── Legacy mode: return Column wrapping GridView (unchanged behavior) ──
    return _buildLegacyContent(context, isNull, length, isFoodCircularLayout);
  }

  /// Returns a sliver-compatible widget for use inside CustomScrollView.
  Widget _buildSliverContent(BuildContext context, bool isNull, int length, bool isFoodCircularLayout) {
    if (!isNull && length > 0) {
      return SliverPadding(
        padding: widget.padding,
        sliver: SliverGrid(
          gridDelegate: _buildGridDelegate(context, isFoodCircularLayout),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildItem(context, index, length, isFoodCircularLayout),
            childCount: length,
            addAutomaticKeepAlives: false, // Don't keep off-screen items alive
            addRepaintBoundaries: true,
          ),
        ),
      );
    } else if (!isNull && length == 0) {
      return SliverToBoxAdapter(
        child: NoDataScreen(
          text: widget.noDataText ??
              (widget.isStore
                  ? Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .showRestaurantText!
                      ? 'no_restaurant_available'.tr
                      : 'no_store_available'.tr
                  : 'no_item_available'.tr),
        ),
      );
    } else {
      // isNull — show shimmer
      return SliverPadding(
        padding: widget.padding,
        sliver: SliverGrid(
          gridDelegate: _buildShimmerGridDelegate(context, isFoodCircularLayout),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildShimmerItem(context, isNull, index),
            childCount: widget.shimmerLength,
          ),
        ),
      );
    }
  }

  /// Returns the original Column-wrapped GridView for backward compatibility.
  Widget _buildLegacyContent(BuildContext context, bool isNull, int length, bool isFoodCircularLayout) {
    return Column(children: [
      !isNull
          ? length > 0
              ? GridView.builder(
                  gridDelegate: _buildGridDelegate(context, isFoodCircularLayout),
                  physics: widget.isScrollable
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: widget.isScrollable ? false : true,
                  controller: widget.scrollController,
                  itemCount: length,
                  padding: widget.padding,
                  addAutomaticKeepAlives: false, // Don't keep off-screen items alive
                  itemBuilder: (context, index) {
                    return _buildItem(context, index, length, isFoodCircularLayout);
                  },
                )
              : NoDataScreen(
                  text: widget.noDataText ??
                      (widget.isStore
                          ? Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'no_restaurant_available'.tr
                              : 'no_store_available'.tr
                          : 'no_item_available'.tr),
                )
          : GridView.builder(
              gridDelegate: _buildShimmerGridDelegate(context, isFoodCircularLayout),
              physics: widget.isScrollable
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              shrinkWrap: widget.isScrollable ? false : true,
              controller: widget.scrollController,
              itemCount: widget.shimmerLength,
              padding: widget.padding,
              itemBuilder: (context, index) {
                return _buildShimmerItem(context, isNull, index);
              },
            ),
    ]);
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildShimmerGridDelegate(BuildContext context, bool isFoodCircularLayout) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisSpacing: ResponsiveHelper.isDesktop(context)
          ? Dimensions.paddingSizeExtremeLarge
          : widget.stores != null
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeLarge,
      mainAxisSpacing: ResponsiveHelper.isDesktop(context)
          ? Dimensions.paddingSizeLarge
          : widget.stores != null
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeSmall,
      mainAxisExtent:
              ResponsiveHelper.isDesktop(context) && widget.isStore
                  ? 220
                  : ResponsiveHelper.isMobile(context)
                      ? widget.stores != null && widget.isStore
                          ? 200
                          : (widget.inStorePage && !widget.isStore)
                              ? (Get.find<SplashController>().module?.moduleType == AppConstants.ecommerce || Get.find<SplashController>().module?.moduleType == AppConstants.grocery ? 280 : 130)
                              : ResponsiveHelper.isTab(context)?250: 220
                      : (widget.inStorePage && !widget.isStore) ? 130 : 290,
      crossAxisCount:ResponsiveHelper.isTab(context)? (widget.inStorePage && !widget.isStore ? 2 : 4) :ResponsiveHelper.isMobile(context)
              ? (widget.inStorePage && !widget.isStore ? (Get.find<SplashController>().module?.moduleType == AppConstants.ecommerce || Get.find<SplashController>().module?.moduleType == AppConstants.grocery ? 3 : 1) : 3)
              : ResponsiveHelper.isDesktop(context) &&
                      widget.stores != null
                  ? 4
                  : 4,
    );
  }

  Widget _buildShimmerItem(BuildContext context, bool isNull, int index) {
    return widget.isStore
        ? widget.isFoodOrGrocery!
            ? const StoreCardShimmer()
            : const NewOnShimmerView()
        : ItemShimmer(
            isEnabled: isNull,
            isStore: widget.isStore,
            inStore: (Get.find<SplashController>().module?.moduleType == AppConstants.ecommerce || Get.find<SplashController>().module?.moduleType == AppConstants.grocery) ? false : widget.inStorePage,
            hasDivider: index != widget.shimmerLength - 1);
  }
}

class NewOnShimmerView extends StatelessWidget {
  const NewOnShimmerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Stack(children: [
        Container(
          // width: fromAllStore ?  MediaQuery.of(context).size.width : 260,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusDefault),
                    topRight: Radius.circular(Dimensions.radiusDefault)),
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                      ),
                      child: Icon(Icons.favorite_border,
                          color: Theme.of(context).primaryColor, size: 20),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 95),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 100,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.blue, size: 15),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Expanded(
                              child: Container(
                                height: 10,
                                width: 100,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          ]),
                        ]),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 10,
                            width: 70,
                            padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusLarge),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 65,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                          ),
                        ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        Positioned(
          top: 60,
          left: 15,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 65,
                width: 65,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
