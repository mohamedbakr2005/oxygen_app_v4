import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/back_to_top.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:Oxygen_Mart/features/brands/controllers/brands_controller.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:Oxygen_Mart/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:Oxygen_Mart/features/home/controllers/advertisement_controller.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/home/screens/modules/grocery_home_screen.dart';
import 'package:Oxygen_Mart/features/home/screens/modules/food_home_screen.dart';
import 'package:Oxygen_Mart/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:Oxygen_Mart/features/home/screens/modules/shop_home_screen.dart';
import 'package:Oxygen_Mart/features/home/widgets/all_store_filter_widget.dart';
import 'package:Oxygen_Mart/common/widgets/paginated_list_view.dart';
import 'package:Oxygen_Mart/common/widgets/item_view.dart';
import 'package:Oxygen_Mart/features/reels/controllers/reels_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/module_store_list_view.dart';
import 'package:Oxygen_Mart/features/home/screens/web_new_home_screen.dart';
import 'package:Oxygen_Mart/features/home/widgets/cashback_dialog_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/cashback_logo_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/module_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:Oxygen_Mart/features/item/controllers/campaign_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/notification/controllers/notification_controller.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/features/parcel/screens/parcel_category_screen.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/smart_banner/controllers/smart_banner_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/deep_link_service.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);

    final splashCtrl = Get.find<SplashController>();
    splashCtrl.getModules();

    bool isParcel = splashCtrl.module != null && (splashCtrl.configModel!.moduleConfig?.module?.isParcel ?? false);

    if (splashCtrl.module != null && !isParcel) {
      Get.find<BogoOfferController>().getBogoHomeData();
      Get.find<HappyHourController>().getRunningHappyHour();
      final String moduleType = splashCtrl.module!.moduleType.toString();

      if (AuthHelper.isLoggedIn()) {
        Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
        if (Get.find<ProfileController>().proStatus) {
          Get.find<ProController>().getProActiveOffer(moduleType: splashCtrl.module?.moduleType);
        }
      }

      Get.find<BannerController>().getBannerList(reload);
      Get.find<BannerController>().getPromotionalBannerList(reload);
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<ReelsController>().getReelsList(offset: 1);
      Get.find<HomeController>().getTopOffer(notify: false);
      Get.find<StoreController>().getRecommendedStoreList();
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getBasicCampaignList(reload);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<ItemController>().getDiscountedItemList(reload, false, 'all');
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<StoreController>().getTopOfferStoreList(reload, false);
      Get.find<AdvertisementController>().getAdvertisementList();
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<ItemController>().getPopularItemList(reload, 'all', false);
      Get.find<ItemController>().getReviewedItemList(reload, 'all', false);
      Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
      Get.find<BrandsController>().getBrandList();

      if (moduleType == AppConstants.grocery) {
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      } else if (moduleType == AppConstants.pharmacy) {
        Get.find<ItemController>().getBasicMedicine(reload, false);
        Get.find<StoreController>().getFeaturedStoreList();
        await Get.find<ItemController>().getCommonConditions(false);
        if (Get.find<ItemController>().commonConditions != null &&
            Get.find<ItemController>().commonConditions!.isNotEmpty) {
          Get.find<ItemController>().getConditionsWiseItem(
              Get.find<ItemController>().commonConditions![0].id!, false);
        }
      } else if (moduleType == AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
    }

    if (splashCtrl.module == null && splashCtrl.configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<SmartBannerController>().getSmartBanners(notify: false);
      Get.find<StoreController>().getFeaturedStoreList();
      if (AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }

    if (isParcel) {
      Get.find<ParcelController>().getParcelCategoryList();
    }

    if (AuthHelper.isLoggedIn()) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<CouponController>().getCouponList();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final sharedPreferences = Get.find<SharedPreferences>();

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerKey = GlobalKey();
  bool searchBgShow = false;
  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();

    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();
      if ((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ?? false) &&
          Get.find<SplashController>().showReferBottomSheet) {
        if (Get.isRegistered<DeepLinkService>() && Get.find<DeepLinkService>().pendingProductId == null) {
          _showReferBottomSheet();
        }
      }
      if (mounted && Get.isRegistered<DeepLinkService>()) {
        Get.find<DeepLinkService>().onHomeDataLoaded();
      }
    });

    Get.find<SmartBannerController>().getSmartBanners(notify: false);

    if (!ResponsiveHelper.isWeb()) {
      Get.find<LocationController>().getZone(
          AddressHelper.getUserAddressFromSharedPref()!.latitude,
          AddressHelper.getUserAddressFromSharedPref()!.longitude,
          false,
          updateInAddress: true);
    }

    _scrollController.addListener(() {
      final bool showBackToTop = _scrollController.position.pixels > _backToTopThreshold;
      if (showBackToTop != _showBackToTop) {
        setState(() => _showBackToTop = showBackToTop);
      }
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      } else {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<DeepLinkService>().onHomeFirstFrameRendered();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context)
        ? Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
              insetPadding: const EdgeInsets.all(22),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: const ReferBottomSheetWidget(),
            ),
            useSafeArea: false,
          ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
            isScrollControlled: true,
            useRootNavigator: true,
            context: Get.context!,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge)),
            ),
            builder: (context) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: const ReferBottomSheetWidget(),
              );
            },
          ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if (Get.find<DeepLinkService>().pendingProductId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.find<DeepLinkService>().onHomeFirstFrameRendered();
        });
      }

      // On Web: if no module is selected yet, auto-select grocery and show loading
      if (GetPlatform.isWeb && splashController.module == null) {
        if (splashController.moduleList != null && splashController.moduleList!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final groceryModule = splashController.moduleList!.firstWhere(
              (m) => m.moduleType == AppConstants.grocery,
              orElse: () => splashController.moduleList!.first,
            );
            splashController.switchModule(groceryModule);
          });
        }
        // Show a blank loading screen — preloader handles visual
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      bool showMobileModule = !GetPlatform.isWeb && !ResponsiveHelper.isDesktop(context) &&
          splashController.module == null;
      bool isParcel = splashController.module != null &&
          (splashController.configModel!.moduleConfig?.module?.isParcel ?? false);
      bool isGrocery = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.grocery;
      bool isPharmacy = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.pharmacy;
      bool isFood = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.food;
      bool isShop = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.ecommerce;

      if(splashController.module != null) {
        print('--- ACTIVE MODULE: ${splashController.module!.moduleName} (Type: ${splashController.module!.moduleType}) ---');
      }

      // التعديل الجوهري هنا: شيلنا الـ GetBuilder بتاع الـ HomeController من حوالين الشاشة كلها
      return Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).cardColor,
        body: isParcel
            ? const ParcelCategoryScreen()
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    splashController.setRefreshing(true);
                    if (Get.find<SplashController>().module != null) {
                      await Get.find<LocationController>().syncZoneData();
                      await Get.find<BannerController>().getBannerList(true);
                      await Get.find<BannerController>().getPromotionalBannerList(true);
                      await Get.find<CategoryController>().getCategoryList(true);
                      await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
                      await Get.find<CampaignController>().getItemCampaignList(true);
                      Get.find<CampaignController>().getBasicCampaignList(true);
                      await Get.find<ItemController>().getDiscountedItemList(true, false, 'all');
                      await Get.find<ItemController>().getPopularItemList(true, 'all', false);
                      await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
                      await Get.find<StoreController>().getTopOfferStoreList(true, false);
                      await Get.find<ItemController>().getReviewedItemList(true, 'all', false);
                      await Get.find<ItemController>().getRecommendedItemList(true, 'all', false);
                      await Get.find<StoreController>().getStoreList(1, true);
                      Get.find<AdvertisementController>().getAdvertisementList();
                      if (isGrocery) {
                        await Get.find<FlashSaleController>().getFlashSale(true, true);
                      }
                      if (isPharmacy) {
                        Get.find<ItemController>().getBasicMedicine(true, true);
                        Get.find<ItemController>().getCommonConditions(true);
                      }
                      if (isShop) {
                        await Get.find<FlashSaleController>().getFlashSale(true, true);
                        Get.find<ItemController>().getFeaturedCategoriesItemList(true, true);
                        Get.find<BrandsController>().getBrandList();
                      }
                      if (AuthHelper.isLoggedIn()) {
                        await Get.find<ProfileController>().getUserInfo();
                        await Get.find<NotificationController>().getNotificationList(true);
                        Get.find<CouponController>().getCouponList();
                      }
                    } else {
                      await Get.find<BannerController>().getFeaturedBanner();
                      await Get.find<SmartBannerController>().getSmartBanners(notify: false);
                      await Get.find<SplashController>().getModules();
                      if (AuthHelper.isLoggedIn()) {
                        await Get.find<AddressController>().getAddressList();
                      }
                      await Get.find<StoreController>().getFeaturedStoreList();
                    }
                    splashController.setRefreshing(false);
                  },
                  child: ResponsiveHelper.isDesktop(context)
                      ? WebNewHomeScreen(scrollController: _scrollController)
                      : Stack(
                          children: [
                            CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            /// App Bar
                            SliverAppBar(
                              floating: true,
                              elevation: 0,
                              automaticallyImplyLeading: false,
                              surfaceTintColor: Theme.of(context).colorScheme.surface,
                              backgroundColor: ResponsiveHelper.isDesktop(context)
                                  ? Colors.transparent
                                  : Theme.of(context).colorScheme.surface,
                              title: Center(
                                  child: Container(
                                width: Dimensions.webMaxWidth,
                                height: Get.find<LocalizationController>().isLtr ? 60 : 70,
                                color: Theme.of(context).colorScheme.surface,
                                child: Row(children: [
                                  (splashController.module != null &&
                                          splashController.configModel!.module == null &&
                                          splashController.moduleList != null)
                                      ? InkWell(
                                          onTap: () {
                                            splashController.removeModule();
                                            Get.find<StoreController>().resetStoreData();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              size: 20,
                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                      width: (splashController.module != null &&
                                              splashController.configModel!.module == null &&
                                              splashController.moduleList != null &&
                                              splashController.moduleList!.length != 1)
                                          ? Dimensions.paddingSizeSmall
                                          : 0),
                                   Expanded(
                                       child: InkWell(
                                     onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                                     child: Padding(
                                       padding: EdgeInsets.symmetric(
                                         vertical: Dimensions.paddingSizeSmall,
                                         horizontal: ResponsiveHelper.isDesktop(context)
                                             ? Dimensions.paddingSizeSmall
                                             : 0,
                                       ),
                                       child: GetBuilder<LocationController>(builder: (locationController) {
                                         return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).primaryColor.withOpacity(0.10),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                    Icon(Icons.location_on_rounded, size: 11, color: Theme.of(context).primaryColor),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      AuthHelper.isLoggedIn()
                                                          ? AddressHelper.getUserAddressFromSharedPref()!.addressType!.tr
                                                          : 'your_location'.tr,
                                                      style: robotoMedium.copyWith(
                                                          color: Theme.of(context).primaryColor,
                                                          fontSize: Dimensions.fontSizeExtraSmall),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ]),
                                                ),
                                              ]),
                                              const SizedBox(height: 3),
                                              Row(children: [
                                                Flexible(
                                                  child: Text(
                                                    AddressHelper.getUserAddressFromSharedPref()!.address!,
                                                    style: robotoBold.copyWith(
                                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                                        fontSize: Dimensions.fontSizeDefault),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                Icon(Icons.keyboard_arrow_down_rounded,
                                                    color: Theme.of(context).primaryColor, size: 22),
                                              ]),
                                            ]);
                                       }),
                                   ))),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  InkWell(
                                    onTap: () {
                                      Get.back();
                                      Get.toNamed(RouteHelper.getConversationRoute());
                                    },
                                    borderRadius: BorderRadius.circular(50),
                                    child: Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.10),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(CupertinoIcons.chat_bubble_2,
                                          size: 21, color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  InkWell(
                                    child: GetBuilder<NotificationController>(builder: (notificationController) {
                                      return Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.10),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(clipBehavior: Clip.none, children: [
                                          Icon(CupertinoIcons.bell,
                                              size: 21, color: Theme.of(context).primaryColor),
                                          notificationController.hasNotification
                                              ? Positioned(
                                                  top: -3,
                                                  right: -3,
                                                  child: Container(
                                                    height: 9,
                                                    width: 9,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.error,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(width: 1.5, color: Theme.of(context).cardColor),
                                                    ),
                                                  ))
                                              : const SizedBox(),
                                        ]),
                                      );
                                    }),
                                    onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                                  ),
                                ]),
                              )),
                              actions: const [SizedBox()],
                            ),

                            /// Search Button
                            !showMobileModule
                                ? SliverPersistentHeader(
                                    pinned: true,
                                    delegate: SliverDelegate(
                                        callback: (val) {},
                                        child: Center(
                                            child: Container(
                                          height: 50,
                                          width: Dimensions.webMaxWidth,
                                          color: searchBgShow
                                              ? Get.find<ThemeController>().darkTheme
                                                  ? Theme.of(context).colorScheme.surface
                                                  : Theme.of(context).cardColor
                                              : null,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: Dimensions.paddingSizeSmall),
                                          child: InkWell(
                                            onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: Dimensions.paddingSizeDefault),
                                              margin: const EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 12,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 4),
                                                  )
                                                ],
                                              ),
                                              child: Row(children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    CupertinoIcons.search,
                                                    size: 20,
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                                Expanded(
                                                    child: Text(
                                                  (Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
                                                      ? 'search_food_or_restaurant'.tr
                                                      : 'search_item_or_store'.tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeDefault,
                                                    color: Theme.of(context).hintColor.withOpacity(0.6),
                                                  ),
                                                )),
                                              ]),
                                            ),
                                          ),
                                        ))),
                                  )
                                : const SliverToBoxAdapter(),

                            SliverToBoxAdapter(
                              child: Center(
                                  child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: !showMobileModule
                                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        isGrocery
                                            ? const GroceryHomeScreen()
                                            : isPharmacy
                                                ? const PharmacyHomeScreen()
                                                : isFood
                                                    ? FoodHomeScreen(scrollController: _scrollController)
                                                    : isShop
                                                        ? const ShopHomeScreen()
                                                        : const ModuleStoreListView(),
                                      ])
                                    : ModuleView(splashController: splashController),
                              )),
                            ),

                            !showMobileModule && !isParcel && !isPharmacy && !isFood && !isGrocery
                                ? SliverPersistentHeader(
                                    key: _headerKey,
                                    pinned: true,
                                    delegate: SliverDelegate(
                                      height: 85,
                                      callback: (val) {
                                        searchBgShow = val;
                                      },
                                      child: const AllStoreFilterWidget(),
                                    ),
                                  )
                                : const SliverToBoxAdapter(),

                            SliverToBoxAdapter(
                              child: !showMobileModule && !isParcel && !isPharmacy && !isFood && !isGrocery
                                  ? Center(
                                      child: GetBuilder<StoreController>(builder: (storeController) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: ResponsiveHelper.isDesktop(context) ? 0 : 100),
                                          child: PaginatedListView(
                                            scrollController: _scrollController,
                                            totalSize: storeController.storeModel?.totalSize,
                                            offset: storeController.storeModel?.offset,
                                            onPaginate: (int? offset) async =>
                                                await storeController.getStoreList(offset!, false),
                                            itemView: ItemsView(
                                              isStore: true,
                                              items: null,
                                              isFoodOrGrocery: (isFood || isGrocery),
                                              stores: storeController.storeModel?.stores,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: ResponsiveHelper.isDesktop(context)
                                                    ? Dimensions.paddingSizeExtraSmall
                                                    : Dimensions.paddingSizeSmall,
                                                vertical: ResponsiveHelper.isDesktop(context)
                                                    ? Dimensions.paddingSizeExtraSmall
                                                    : Dimensions.paddingSizeDefault,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                        BackToTopButton(
                          visible: _showBackToTop,
                          onTap: _scrollToTop,
                          top: 75,
                        ),
                      ],
                    ),
                ),
              ),
        // التعديل الثاني الجوهري: خلينا الـ GetBuilder يغلف الزرار ده بسسسس
        floatingActionButton: GetBuilder<HomeController>(
          builder: (homeController) {
            return AuthHelper.isLoggedIn() &&
                    homeController.cashBackOfferList != null &&
                    homeController.cashBackOfferList!.isNotEmpty
                ? homeController.showFavButton
                    ? Padding(
                        padding: EdgeInsets.only(
                            bottom: 70.0, right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
                        child: InkWell(
                          onTap: () => Get.dialog(const CashBackDialogWidget()),
                          child: const CashBackLogoWidget(),
                        ),
                      )
                    : const SizedBox()
                : const SizedBox();
          },
        ),
      );
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset == maxExtent;
    callback!(isPinned);
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