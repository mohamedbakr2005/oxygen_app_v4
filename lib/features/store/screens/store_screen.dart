import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/item_view.dart';
import 'package:Oxygen_Mart/common/widgets/item_widget.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/paginated_list_view.dart';
import 'package:Oxygen_Mart/common/widgets/web_item_view.dart';
import 'package:Oxygen_Mart/common/widgets/web_item_widget.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/category/domain/models/category_model.dart';
import 'package:Oxygen_Mart/features/checkout/screens/checkout_screen.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:Oxygen_Mart/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:Oxygen_Mart/features/bogo_offer/widgets/bogo_store_section_widget.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/bogo_offer_card_widget.dart';
import 'package:Oxygen_Mart/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:Oxygen_Mart/features/happy_hour/widgets/happy_hour_milestone_banner_widget.dart';
import 'package:Oxygen_Mart/features/store/widgets/store_bogo_offer_list_sheet.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/pro/screens/subscription_plan_screen.dart';
import 'package:Oxygen_Mart/features/pro/widgets/pro_plan_banner_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/search/widgets/custom_check_box_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/widgets/store_banner_widget.dart';
import 'package:Oxygen_Mart/features/store/widgets/store_description_view_widget.dart';
import 'package:Oxygen_Mart/features/store/widgets/store_details_screen_shimmer_widget.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_cart_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Oxygen_Mart/features/store/widgets/store_hero_widget.dart';
import 'package:Oxygen_Mart/common/widgets/back_to_top.dart';
import 'package:Oxygen_Mart/features/store/widgets/store_header_info_widget.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;
  const StoreScreen(
      {super.key,
      required this.store,
      required this.fromModule,
      this.slug = ''});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  ModuleModel? _initialModule;
  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;

  void _scrollToTop() {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    _initialModule = Get.find<SplashController>().module;
    initDataCall();
  }

  @override
  void dispose() {
    _restoreModuleContext();
    scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _restoreModuleContext() {
    if (!Get.isRegistered<SplashController>()) return;
    final splash = Get.find<SplashController>();
    if (_initialModule == null) {
      splash.setModule(null, notify: true);
      splash.selectHomeModule();
      if (Get.isRegistered<ApiClient>() && Get.isRegistered<SharedPreferences>()) {
        final addressModel = AddressHelper.getUserAddressFromSharedPref();
        Get.find<ApiClient>().updateHeader(
          Get.find<SharedPreferences>().getString(AppConstants.token),
          addressModel?.zoneIds,
          addressModel?.areaIds,
          Get.find<LocalizationController>().locale.languageCode,
          null,
          addressModel?.latitude,
          addressModel?.longitude,
          null,
        );
      }
    } else {
      splash.setModule(_initialModule, notify: true);
      if (Get.isRegistered<ApiClient>() && Get.isRegistered<SharedPreferences>()) {
        final addressModel = AddressHelper.getUserAddressFromSharedPref();
        Get.find<ApiClient>().updateHeader(
          Get.find<SharedPreferences>().getString(AppConstants.token),
          addressModel?.zoneIds,
          addressModel?.areaIds,
          Get.find<LocalizationController>().locale.languageCode,
          _initialModule!.id,
          addressModel?.latitude,
          addressModel?.longitude,
          null,
        );
      }
    }
  }

  Future<void> initDataCall() async {
    if (kDebugMode) {
      print('[STORE_SCREEN] OPEN id: ${widget.store?.id}, slug: ${widget.slug}, fromModule: ${widget.fromModule}');
      print('[STORE_SCREEN] ACTIVE MODULE: ${Get.find<SplashController>().module?.id} (${Get.find<SplashController>().module?.moduleType})');
    }
    Get.find<StoreController>().clearStoreDetails(); // Clear stale data first
    if (Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();

    // 1. Fetch Store Details (Awaited)
    final Store? storeDetails = await Get.find<StoreController>().getStoreDetails(
      Store(id: widget.store!.id),
      widget.fromModule,
      slug: widget.slug,
    );
    Get.find<StoreController>().showButtonAnimation();

    // 2. Set module context for store screen
    final int? storeModuleId = storeDetails?.moduleId ?? widget.store?.moduleId;
    ModuleModel? storeModule;
    if (storeModuleId != null && Get.find<SplashController>().moduleList != null) {
      for (final ModuleModel m in Get.find<SplashController>().moduleList!) {
        if (m.id == storeModuleId) {
          storeModule = m;
          break;
        }
      }
    }
    if (storeModule != null) {
      Get.find<SplashController>().setModule(storeModule, notify: false);
      final addressModel = AddressHelper.getUserAddressFromSharedPref();
      if (Get.isRegistered<ApiClient>() && Get.isRegistered<SharedPreferences>()) {
        Get.find<ApiClient>().updateHeader(
          Get.find<SharedPreferences>().getString(AppConstants.token),
          addressModel?.zoneIds,
          addressModel?.areaIds,
          Get.find<LocalizationController>().locale.languageCode,
          storeModule.id,
          addressModel?.latitude,
          addressModel?.longitude,
          null,
        );
      }
    }

    if (Get.find<SplashController>().proStaus && AuthHelper.isLoggedIn()) {
      Get.find<ProController>().getProActiveOffer(
        moduleType: Get.find<StoreController>().store?.moduleType ?? Get.find<SplashController>().module?.moduleType,
      );
    }

    // 3. Fetch Categories for this store's module (Awaited)
    await Get.find<CategoryController>().getCategoryList(true);
    Get.find<StoreController>().setCategoryList();

    // 4. Parallel fetch for other store-specific data
    final int? targetStoreId = widget.store!.id ?? Get.find<StoreController>().store?.id;
    if (targetStoreId != null) {
      Get.find<StoreController>().getStoreBogoOffers(targetStoreId);
      Get.find<BogoOfferController>().getBogoHomeData();
      await Future.wait([
        Get.find<StoreController>().getStoreBannerList(targetStoreId),
        Get.find<StoreController>().getRestaurantRecommendedItemList(targetStoreId, false),
        Get.find<StoreController>().getStoreItemList(targetStoreId, 1, 'all', false),
      ]);
    }

    scrollController.addListener(() {
      final bool showBackToTop = scrollController.position.pixels > _backToTopThreshold;
      if (showBackToTop != _showBackToTop) {
        setState(() => _showBackToTop = showBackToTop);
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      } else {
        if (!Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _restoreModuleContext();
        }
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: GetBuilder<StoreController>(builder: (storeController) {
          return GetBuilder<CategoryController>(builder: (categoryController) {
            Store? store;
            if (storeController.store != null &&
                storeController.store!.name != null &&
                categoryController.categoryList != null) {
              store = storeController.store;
              storeController.setCategoryList();
            }
            final String? currentModuleType =
                storeController.store?.moduleType ??
                    Get.find<SplashController>().module?.moduleType;
            final bool isPharmacy =
                currentModuleType?.toString() == AppConstants.pharmacy;
            return RefreshIndicator(
              onRefresh: () async => await initDataCall(),
              child: (storeController.store != null &&
                      storeController.store!.name != null &&
                      categoryController.categoryList != null)
                  ? Stack(
                      children: [
                        CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      slivers: [
                        ResponsiveHelper.isDesktop(context)
                            ? SliverToBoxAdapter(
                                child: Container(
                                  color: const Color(0xFF171A29),
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeLarge),
                                alignment: Alignment.center,
                                child: Center(
                                    child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall),
                                          child: Row(children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault),
                                                child: Stack(
                                                  children: [
                                                    CustomImage(
                                                      fit: BoxFit.cover,
                                                      height: 240,
                                                      width: 590,
                                                      image: store
                                                              ?.coverPhotoFullUrl ??
                                                          '',
                                                    ),
                                                    store?.discount != null
                                                        ? Positioned(
                                                            bottom: 0,
                                                            left: 0,
                                                            right: 0,
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall),
                                                              child: Text(
                                                                '${store?.discount!.discountType == 'percent' ? '${store?.discount!.discount}% ${'off'.tr}' : '${PriceConverter.convertPrice(store?.discount!.discount)} ${'off'.tr}'} '
                                                                '${'on_all_products'.tr}, ${'after_minimum_purchase'.tr} ${PriceConverter.convertPrice(store?.discount!.minPurchase)},'
                                                                ' ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(store!.discount!.startTime!)} '
                                                                '- ${DateConverter.convertTimeToTime(store.discount!.endTime!)}',
                                                                style:
                                                                    robotoMedium
                                                                        .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeLarge),
                                            Expanded(
                                                child:
                                                    StoreDescriptionViewWidget(
                                                        store: store)),
                                          ]),
                                        ))),
                              ),
                            )
                          : isPharmacy
                              ? SliverToBoxAdapter(
                                  child: _buildPharmacyGradientHeader(
                                      context, store, storeController))
                              : SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      StoreHeroWidget(store: store),
                                      StoreHeaderInfoWidget(
                                        store: store,
                                        distance: '${store?.distance != null ? store!.distance!.toStringAsFixed(2) : ((store?.latitude != null && store?.longitude != null) ? storeController.getRestaurantDistance(LatLng(double.parse(store!.latitude!), double.parse(store.longitude!))).toStringAsFixed(2) : '0')} ${'km'.tr}',
                                      ),
                                    ],
                                  ),
                                ),
                        !Get.find<SplashController>().proStaus || Get.find<ProfileController>().proStatus ? const SliverToBoxAdapter(child: SizedBox()) : SliverToBoxAdapter(
                          child: Container(
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeExtraSmall, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
                            child: ProPlanBannerWidget(
                              onSubscribe: () {
                                final Store? storeData = Get.find<StoreController>().store;
                                Get.find<ProController>().saveCurrentPath(route: RouteHelper.getStoreRoute(
                                  id: storeData?.id, page: 'store',
                                ));
                                SubscriptionPlanScreen.open();
                              },
                            ),
                          ),
                        ),
/*
                              : SliverAppBar(
                                  expandedHeight: 300,
                                  toolbarHeight: 100,
                                  pinned: true,
                                  floating: false,
                                  elevation: 0.5,
                                  backgroundColor: Theme.of(context).cardColor,
                                  leading: IconButton(
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              Theme.of(context).primaryColor),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.chevron_left,
                                          color: Theme.of(context).cardColor),
                                    ),
                                    onPressed: () => Get.back(),
                                  ),
                                  flexibleSpace: FlexibleSpaceBar(
                                    titlePadding: EdgeInsets.zero,
                                    centerTitle: true,
                                    expandedTitleScale: 1.1,
                                    title: CustomizableSpaceBarWidget(
                                      builder: (context, scrollingRate) {
                                        return Container(
                                          height: store!.discount != null
                                              ? 145
                                              : 100,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(
                                                        Dimensions
                                                            .radiusLarge)),
                                          ),
                                          child: Column(
                                            children: [
                                              store.discount != null
                                                  ? Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(1 -
                                                                scrollingRate),
                                                        borderRadius: const BorderRadius
                                                            .vertical(
                                                            top: Radius.circular(
                                                                Dimensions
                                                                    .radiusLarge)),
                                                      ),
                                                      padding: EdgeInsets.all(Dimensions
                                                              .paddingSizeExtraSmall -
                                                          (GetPlatform.isAndroid
                                                              ? (scrollingRate *
                                                                  Dimensions
                                                                      .paddingSizeExtraSmall)
                                                              : 0)),
                                                      child: Text(
                                                        '${store.discount!.discountType == 'percent' ? '${store.discount!.discount}% ${'off'.tr}' : '${PriceConverter.convertPrice(store.discount!.discount)} ${'off'.tr}'} '
                                                        '${'on_all_products'.tr}, ${'after_minimum_purchase'.tr} ${PriceConverter.convertPrice(store.discount!.minPurchase)},'
                                                        ' ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(store.discount!.startTime!)} '
                                                        '- ${DateConverter.convertTimeToTime(store.discount!.endTime!)}',
                                                        style: robotoMedium
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Colors.black
                                                              .withOpacity(1 -
                                                                  scrollingRate),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                  maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              Container(
                                                color: Theme.of(context)
                                                    .cardColor
                                                    .withOpacity(scrollingRate),
                                                padding: EdgeInsets.only(
                                                  bottom: 0,
                                                  left: Get.find<
                                                              LocalizationController>()
                                                          .isLtr
                                                      ? 40 * scrollingRate
                                                      : 0,
                                                  right: Get.find<
                                                              LocalizationController>()
                                                          .isLtr
                                                      ? 0
                                                      : 40 * scrollingRate,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Container(
                                                    height: 100,
                                                    color: Theme.of(context)
                                                        .cardColor
                                                        .withOpacity(
                                                            scrollingRate == 0.0
                                                                ? 1
                                                                : 0),
                                                    padding: EdgeInsets.only(
                                                      left: Get.find<
                                                                  LocalizationController>()
                                                              .isLtr
                                                          ? 20
                                                          : 0,
                                                      right: Get.find<
                                                                  LocalizationController>()
                                                              .isLtr
                                                          ? 0
                                                          : 20,
                                                    ),
                                                    child: Row(children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusSmall),
                                                        child: Stack(children: [
                                                          CustomImage(
                                                            image:
                                                                '${store.logoFullUrl}',
                                                            height: 60 -
                                                                (scrollingRate *
                                                                    15),
                                                            width: 70 -
                                                                (scrollingRate *
                                                                    15),
                                                            fit: BoxFit.cover,
                                                          ),
                                                          storeController.isStoreOpenNow(
                                                                  store.active!,
                                                                  store
                                                                      .schedules)
                                                              ? const SizedBox()
                                                              : Positioned(
                                                                  bottom: 0,
                                                                  left: 0,
                                                                  right: 0,
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius: const BorderRadius
                                                                          .vertical(
                                                                          bottom:
                                                                              Radius.circular(Dimensions.radiusSmall)),
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.6),
                                                                    ),
                                                                    child: Text(
                                                                      'closed_now'
                                                                          .tr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: robotoRegular.copyWith(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall),
                                                                    ),
                                                                  ),
                                                                ),
                                                        ]),
                                                      ),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall),
                                                      Expanded(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                            Row(children: [
                                                              Expanded(
                                                                  child: Text(
                                                                store.name!,
                                                                style: robotoMedium.copyWith(
                                                                    fontSize: Dimensions
                                                                            .fontSizeLarge -
                                                                        (scrollingRate *
                                                                            3),
                                                                    color: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .color),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                              const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeSmall),
                                                            ]),
                                                            const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            Text(
                                                              store.address ??
                                                                  '',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: robotoRegular.copyWith(
                                                                  fontSize: Dimensions
                                                                          .fontSizeSmall -
                                                                      (scrollingRate *
                                                                          2),
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor),
                                                            ),
                                                            SizedBox(
                                                                height: ResponsiveHelper
                                                                        .isDesktop(
                                                                            context)
                                                                    ? Dimensions
                                                                        .paddingSizeExtraSmall
                                                                    : 0),
                                                            Row(children: [
                                                              Flexible(
                                                                child: Text(
                                                                    'minimum_order'
                                                                        .tr,
                                                                    style: robotoRegular
                                                                        .copyWith(
                                                                      fontSize: Dimensions
                                                                              .fontSizeExtraSmall -
                                                                          (scrollingRate *
                                                                              2),
                                                                      color: Theme.of(
                                                                              context)
                                                                          .disabledColor,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ),
                                                              const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeExtraSmall),
                                                              Text(
                                                                PriceConverter
                                                                    .convertPrice(
                                                                        store
                                                                            .minimumOrder),
                                                                // textDirection:
                                                                //     TextDirection
                                                                //         .ltr,
                                                                style: robotoMedium.copyWith(
                                                                    fontSize: Dimensions
                                                                            .fontSizeExtraSmall -
                                                                        (scrollingRate *
                                                                            2),
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor),
                                                              ),
                                                            ]),
                                                          ])),
                                                      GetBuilder<
                                                              FavouriteController>(
                                                          builder:
                                                              (favouriteController) {
                                                        bool isWished =
                                                            favouriteController
                                                                .wishStoreIdList
                                                                .contains(
                                                                    store!.id);
                                                        return InkWell(
                                                          onTap: () {
                                                            if (AuthHelper
                                                                .isLoggedIn()) {
                                                              isWished
                                                                  ? favouriteController
                                                                      .removeFromFavouriteList(
                                                                          store!
                                                                              .id,
                                                                          true)
                                                                  : favouriteController
                                                                      .addToFavouriteList(
                                                                          null,
                                                                          store
                                                                              ?.id,
                                                                          true);
                                                            } else {
                                                              showCustomSnackBar(
                                                                  'you_are_not_logged_in'
                                                                      .tr);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall),
                                                            child: Icon(
                                                              isWished
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,
                                                              color: isWished
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : Theme.of(
                                                                          context)
                                                                      .disabledColor,
                                                              size: 24 -
                                                                  (scrollingRate *
                                                                      4),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall),
                                                      AppConstants.webHostedUrl
                                                              .isNotEmpty
                                                          ? InkWell(
                                                              onTap: () {
                                                                storeController
                                                                    .shareStore();
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault),
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall),
                                                                child: Icon(
                                                                  Icons.share,
                                                                  size: 24 -
                                                                      (scrollingRate *
                                                                          4),
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall),
                                                    ]),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    background: CustomImage(
                                      fit: BoxFit.cover,
                                      image: '${store!.coverPhotoFullUrl}',
                                    ),
                                  ),
                                  actions: const [
                                    SizedBox(),
                                  ],
                                ),
*/

                      (ResponsiveHelper.isDesktop(context) &&
                              storeController.recommendedItemModel != null &&
                              storeController
                                  .recommendedItemModel!.items!.isNotEmpty)
                          ? SliverToBoxAdapter(
                              child: Container(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.10),
                                child: Center(
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    height: ResponsiveHelper.isDesktop(context)
                                        ? 325
                                        : 125,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        Text('recommended_for_you'.tr,
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        Text('here_is_what_you_might_like'.tr,
                                            style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(context)
                                                    .disabledColor)),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall),
                                        SizedBox(
                                          height: 250,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: storeController
                                                .recommendedItemModel!
                                                .items!
                                                .length,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall),
                                            itemBuilder: (context, index) {
                                              return Container(
                                                width: 225,
                                                padding: const EdgeInsets.only(
                                                    right: Dimensions
                                                        .paddingSizeSmall,
                                                    left: Dimensions
                                                        .paddingSizeExtraSmall),
                                                margin: const EdgeInsets.only(
                                                    right: Dimensions
                                                        .paddingSizeSmall),
                                                child: WebItemWidget(
                                                  isStore: false,
                                                  item: storeController
                                                      .recommendedItemModel!
                                                      .items![index],
                                                  store: null,
                                                  index: index,
                                                  length: null,
                                                  isCampaign: false,
                                                  inStore: true,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SliverToBoxAdapter(child: SizedBox()),
                      const SliverToBoxAdapter(
                          child: SizedBox(height: Dimensions.paddingSizeSmall)),

                      ///web view..
                      ResponsiveHelper.isDesktop(context)
                          ? SliverToBoxAdapter(
                              child: FooterView(
                                child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeSmall),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 175,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: storeController
                                                      .categoryList!.length,
                                                  padding: const EdgeInsets
                                                      .only(
                                                      left: Dimensions
                                                          .paddingSizeSmall),
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        storeController
                                                            .setCategoryIndex(
                                                                index,
                                                                itemSearching:
                                                                    storeController
                                                                        .isSearching);
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            bottom: Dimensions
                                                                .paddingSizeSmall),
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: Dimensions
                                                                  .paddingSizeSmall,
                                                              vertical: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                      begin: Alignment
                                                                          .bottomRight,
                                                                      end: Alignment
                                                                          .topLeft,
                                                                      colors: <Color>[
                                                                index == storeController.categoryIndex
                                                                    ? Theme.of(
                                                                            context)
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                            0.50)
                                                                    : Colors
                                                                        .transparent,
                                                                index ==
                                                                        storeController
                                                                            .categoryIndex
                                                                    ? Theme.of(
                                                                            context)
                                                                        .cardColor
                                                                    : Colors
                                                                        .transparent,
                                                              ])),
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  storeController
                                                                      .categoryList![
                                                                          index]
                                                                      .name!,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: index ==
                                                                          storeController
                                                                              .categoryIndex
                                                                      ? robotoMedium.copyWith(
                                                                          fontSize: Dimensions
                                                                              .fontSizeSmall,
                                                                          color: Theme.of(context)
                                                                              .primaryColor)
                                                                      : robotoRegular.copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall),
                                                                ),
                                                              ]),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: storeController
                                                        .categoryList!.length *
                                                    50,
                                                width: 1,
                                                color: Theme.of(context)
                                                    .disabledColor
                                                    .withOpacity(0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeLarge),
                                        Expanded(
                                            child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeExtraSmall),
                                                  height: 45,
                                                  width: 430,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault),
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.40)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              _searchController,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .search,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        0),
                                                            hintText:
                                                                'search_for_items'
                                                                    .tr,
                                                            hintStyle: robotoRegular.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusSmall),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none),
                                                            filled: true,
                                                            fillColor: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            isDense: true,
                                                            prefixIcon: Icon(
                                                                Icons.search,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        0.50)),
                                                          ),
                                                          onSubmitted:
                                                              (String? value) {
                                                            if (value!
                                                                .isNotEmpty) {
                                                              Get.find<
                                                                      StoreController>()
                                                                  .getStoreSearchItemList(
                                                                _searchController
                                                                    .text
                                                                    .trim(),
                                                                widget.store!.id
                                                                    .toString(),
                                                                1,
                                                                storeController
                                                                    .type,
                                                              );
                                                            }
                                                          },
                                                          onChanged: (String?
                                                              value) {},
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall),
                                                      !storeController
                                                              .isSearching
                                                          ? CustomButton(
                                                              radius: Dimensions
                                                                  .radiusSmall,
                                                              height: 40,
                                                              width: 74,
                                                              buttonText:
                                                                  'search'.tr,
                                                              isBold: false,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              onPressed: () {
                                                                storeController
                                                                    .getStoreSearchItemList(
                                                                  _searchController
                                                                      .text
                                                                      .trim(),
                                                                  widget
                                                                      .store!.id
                                                                      .toString(),
                                                                  1,
                                                                  storeController
                                                                      .type,
                                                                );
                                                              },
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                _searchController
                                                                    .text = '';
                                                                storeController
                                                                    .initSearchData();
                                                                storeController
                                                                    .changeSearchStatus();
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.radiusSmall)),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 3,
                                                                    horizontal:
                                                                        Dimensions
                                                                            .paddingSizeSmall),
                                                                child: const Icon(
                                                                    Icons.clear,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall),
                                                (Get.find<SplashController>()
                                                            .configModel!
                                                            .moduleConfig!
                                                            .module!
                                                            .vegNonVeg! &&
                                                        Get.find<
                                                                SplashController>()
                                                            .configModel!
                                                            .toggleVegNonVeg!)
                                                    ? SizedBox(
                                                        width: 300,
                                                        height: 30,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount: Get.find<
                                                                  ItemController>()
                                                              .itemTypeList
                                                              .length,
                                                          padding: const EdgeInsets
                                                              .only(
                                                              left: Dimensions
                                                                  .paddingSizeSmall),
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  right: Dimensions
                                                                      .paddingSizeSmall),
                                                              child:
                                                                  CustomCheckBoxWidget(
                                                                title: Get.find<
                                                                        ItemController>()
                                                                    .itemTypeList[
                                                                        index]
                                                                    .tr,
                                                                value: storeController
                                                                        .type ==
                                                                    Get.find<ItemController>()
                                                                            .itemTypeList[
                                                                        index],
                                                                onClick: () {
                                                                  if (storeController
                                                                      .isSearching) {
                                                                    storeController
                                                                        .getStoreSearchItemList(
                                                                      storeController
                                                                          .searchText,
                                                                      widget
                                                                          .store!
                                                                          .id
                                                                          .toString(),
                                                                      1,
                                                                      Get.find<ItemController>()
                                                                              .itemTypeList[
                                                                          index],
                                                                    );
                                                                  } else {
                                                                    storeController.getStoreItemList(
                                                                        storeController
                                                                            .store!
                                                                            .id,
                                                                        1,
                                                                        Get.find<ItemController>()
                                                                            .itemTypeList[index],
                                                                        true);
                                                                  }
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                            PaginatedListView(
                                              scrollController:
                                                  scrollController,
                                              onPaginate: (int? offset) {
                                                if (storeController
                                                    .isSearching) {
                                                  storeController
                                                      .getStoreSearchItemList(
                                                    storeController.searchText,
                                                    widget.store!.id.toString(),
                                                    offset!,
                                                    storeController.type,
                                                  );
                                                } else {
                                                  storeController
                                                      .getStoreItemList(
                                                          widget.store!.id ??
                                                              storeController
                                                                  .store!.id,
                                                          offset!,
                                                          storeController.type,
                                                          false);
                                                }
                                              },
                                              totalSize:
                                                  storeController.isSearching
                                                      ? storeController
                                                          .storeSearchItemModel
                                                          ?.totalSize
                                                      : storeController
                                                          .storeItemModel
                                                          ?.totalSize,
                                              offset:
                                                  storeController.isSearching
                                                      ? storeController
                                                          .storeSearchItemModel
                                                          ?.offset
                                                      : storeController
                                                          .storeItemModel
                                                          ?.offset,
                                              itemView: WebItemsView(
                                                isStore: false,
                                                stores: null,
                                                fromStore: true,
                                                items: storeController
                                                        .isSearching
                                                    ? storeController
                                                        .storeSearchItemModel
                                                        ?.items
                                                    : (storeController
                                                                .categoryList!
                                                                .isNotEmpty &&
                                                            storeController
                                                                    .storeItemModel !=
                                                                null)
                                                        ? storeController
                                                            .storeItemModel!
                                                            .items
                                                        : null,
                                                inStorePage: true,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeSmall,
                                                  vertical: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SliverToBoxAdapter(child: SizedBox()),

                      ///mobile view..
                      ResponsiveHelper.isDesktop(context) || isPharmacy
                          ? const SliverToBoxAdapter(child: SizedBox())
                          : SliverToBoxAdapter(
                              child: Center(
                                  child: Container(
                              width: Dimensions.webMaxWidth,
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              color: Theme.of(context).cardColor,
                              child: Column(children: [

                                store?.announcementActive ?? false
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.2)),
                                        ),
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        margin: const EdgeInsets.only(
                                            top: Dimensions.paddingSizeSmall),
                                        child: Row(children: [
                                          Image.asset(Images.announcement,
                                              height: 20, width: 20),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          Flexible(
                                              child: Text(
                                                  store?.announcementMessage ??
                                                      '',
                                                  style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall))),
                                        ]),
                                      )
                                    : const SizedBox(),
                                StoreBannerWidget(
                                    storeController: storeController),
                                GetBuilder<BogoOfferController>(builder: (bogoOfferController) {
                                  final List<StoreBogoOfferModel> storeOffers = storeController.bogoOfferList ?? const <StoreBogoOfferModel>[];
                                  if (!bogoOfferController.showHomeCard || storeOffers.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeSmall),
                                    child: BogoOfferCardWidget(
                                      bordered: true,
                                      onTap: () => StoreBogoOfferListSheet.show(context, offers: storeOffers),
                                    ),
                                  );
                                }),
                                // if (storeController.bogoOfferList?.isNotEmpty ?? false)
                                //   BogoStoreSectionWidget(
                                //     offers: storeController.bogoOfferList!,
                                //     storeId: store?.id,
                                //   ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                                (!ResponsiveHelper.isDesktop(context) &&
                                        storeController.recommendedItemModel !=
                                            null &&
                                        storeController.recommendedItemModel!
                                            .items!.isNotEmpty)
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text('recommended_for_you'.tr,
                                          //     style: robotoMedium),
                                          // const SizedBox(
                                          //     height: Dimensions
                                          //         .paddingSizeExtraSmall),
                                          // SizedBox(
                                          //   height: ResponsiveHelper.isDesktop(
                                          //           context)
                                          //       ? 150
                                          //       : 130,
                                          //   child: ListView.builder(
                                          //     scrollDirection: Axis.horizontal,
                                          //     itemCount: storeController
                                          //         .recommendedItemModel!
                                          //         .items!
                                          //         .length,
                                          //     physics:
                                          //         const BouncingScrollPhysics(),
                                          //     itemBuilder: (context, index) {
                                          //       return Padding(
                                          //         padding: ResponsiveHelper
                                          //                 .isDesktop(context)
                                          //             ? const EdgeInsets
                                          //                 .symmetric(
                                          //                 vertical: 20)
                                          //             : const EdgeInsets
                                          //                 .symmetric(
                                          //                 vertical: 10),
                                          //         child: Container(
                                          //           width: ResponsiveHelper
                                          //                   .isDesktop(context)
                                          //               ? 500
                                          //               : 300,
                                          //           padding: const EdgeInsets
                                          //               .only(
                                          //               right: Dimensions
                                          //                   .paddingSizeSmall,
                                          //               left: Dimensions
                                          //                   .paddingSizeExtraSmall),
                                          //           margin: const EdgeInsets
                                          //               .only(
                                          //               right: Dimensions
                                          //                   .paddingSizeSmall),
                                          //           child: ItemWidget(
                                          //             isStore: false,
                                          //             item: storeController
                                          //                 .recommendedItemModel!
                                          //                 .items![index],
                                          //             store: null,
                                          //             index: index,
                                          //             length: null,
                                          //             isCampaign: false,
                                          //             inStore: true,
                                          //           ),
                                          //         ),
                                          //       );
                                          //     },
                                          //   ),
                                          // ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ]),
                            ))),

                      // Pharmacy-specific quick actions + categories section
                      (!ResponsiveHelper.isDesktop(context) &&
                              Get.find<SplashController>()
                                      .module
                                      ?.moduleType
                                      .toString() ==
                                  AppConstants.pharmacy)
                          ? SliverToBoxAdapter(
                              child: _buildPharmacyStoreContent(
                                  context, storeController))
                          : const SliverToBoxAdapter(child: SizedBox()),

                      ResponsiveHelper.isDesktop(context) || isPharmacy
                          ? const SliverToBoxAdapter(child: SizedBox())
                          : (storeController.categoryList!.isNotEmpty)
                              ? SliverPersistentHeader(
                                  pinned: true,
                                  delegate: SliverDelegate(
                                      height: 50,
                                      child: Center(
                                          child: Container(
                                        width: Dimensions.webMaxWidth,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5,
                                                spreadRadius: 1)
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall),
                                        child: Column(
                                          children: [

                                            SizedBox(
                                              height: 30,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: storeController
                                                    .categoryList!.length,
                                                padding: const EdgeInsets.only(
                                                    left: Dimensions
                                                        .paddingSizeSmall),
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () => storeController
                                                        .setCategoryIndex(
                                                            index),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeDefault,
                                                          vertical: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      margin: const EdgeInsets
                                                          .only(
                                                          right: Dimensions
                                                              .paddingSizeSmall),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(20),
                                                        color: index ==
                                                                storeController
                                                                    .categoryIndex
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : const Color(0xFFF5F5F5),
                                                      ),
                                                      child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              storeController
                                                                  .categoryList![
                                                                      index]
                                                                  .name!,
                                                              style: index ==
                                                                      storeController
                                                                          .categoryIndex
                                                                  ? robotoMedium.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeSmall,
                                                                      color: Colors.white)
                                                                  : robotoRegular
                                                                      .copyWith(
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall,
                                                                          color: Theme.of(context).textTheme.bodyLarge?.color),
                                                            ),
                                                          ]),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))),
                                )
                              : const SliverToBoxAdapter(child: SizedBox()),

                      ResponsiveHelper.isDesktop(context) || isPharmacy
                          ? const SliverToBoxAdapter(child: SizedBox())
                          : SliverToBoxAdapter(
                              child: Container(
                              width: Dimensions.webMaxWidth,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: PaginatedListView(
                                scrollController: scrollController,
                                onPaginate: (int? offset) =>
                                    storeController.getStoreItemList(
                                        widget.store!.id ??
                                            storeController.store!.id,
                                        offset!,
                                        storeController.type,
                                        false),
                                totalSize:
                                    storeController.storeItemModel?.totalSize,
                                offset: storeController.storeItemModel?.offset,
                                itemView: ItemsView(
                                  isStore: false,
                                  stores: null,
                                  items: (storeController
                                              .categoryList!.isNotEmpty &&
                                          storeController.storeItemModel !=
                                              null)
                                      ? storeController.storeItemModel!.items
                                      : null,
                                  inStorePage: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeSmall,
                                  ),
                                ),
                              ),
                            )),
                    ],
                  ),
                  BackToTopButton(
                    visible: _showBackToTop,
                    onTap: _scrollToTop,
                    top: 75,
                  ),
                ],
              )
                : const StoreDetailsScreenShimmerWidget(),
            );
          });
        }),
        floatingActionButton:
            GetBuilder<StoreController>(builder: (storeController) {
          return Visibility(
            visible: storeController.showFavButton &&
                Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .orderAttachment! &&
                (storeController.store != null &&
                    storeController.store!.prescriptionOrder!) &&
                Get.find<SplashController>().configModel!.prescriptionStatus! &&
                AuthHelper.isLoggedIn(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(2, 2))
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: storeController.currentState == true
                      ? 0
                      : ResponsiveHelper.isDesktop(context)
                          ? 180
                          : 150,
                  height: 30,
                  curve: Curves.linear,
                  child: Center(
                    child: Text(
                      'prescription_order'.tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(
                    RouteHelper.getCheckoutRoute('prescription',
                        storeId: storeController.store!.id),
                    arguments: CheckoutScreen(
                        fromCart: false,
                        cartList: null,
                        storeId: storeController.store!.id),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Image.asset(Images.prescriptionIcon,
                        height: 25, width: 25),
                  ),
                ),
              ]),
            ),
          );
        }),
        bottomNavigationBar: GetBuilder<StoreController>(builder: (storeController) {
          return GetBuilder<CartController>(builder: (cartController) {
            if (ResponsiveHelper.isDesktop(context)) return const SizedBox();
            final Store? currentStore = storeController.store ?? widget.store;
            final int? currentStoreId = widget.store?.id ?? currentStore?.id;
            final bool hasCart = cartController.cartList.isNotEmpty;
            final bool? isHappyHourRunning = currentStore?.isHappyHourRunning;

            return GetBuilder<HappyHourController>(builder: (happyHourController) {
              final bool bannerVisible = currentStoreId != null && happyHourController.showStoreBanner(isHappyHourRunning);
              if (!hasCart && !bannerVisible) return const SizedBox();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bannerVisible)
                    HappyHourMilestoneBannerWidget(
                      subtotal: cartController.subTotal,
                      isHappyHourRunning: isHappyHourRunning,
                      storeId: currentStoreId,
                      bottomInset: !hasCart ? MediaQuery.of(context).padding.bottom : 0,
                      tappable: false,
                    ),
                  if (hasCart)
                    const BottomCartWidget(),
                ],
              );
            });
          });
        }),
      ),
    );
  }

  Widget _buildPharmacyGradientHeader(
      BuildContext context, Store? store, StoreController storeController) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.75)
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: back + store name + cart
              Row(
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  const Spacer(),
                  // Store name + subtitle centred
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        store?.name ?? '',
                        style: robotoBold.copyWith(
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        store?.address ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Cart icon with badge
                  GetBuilder<CartController>(builder: (cartController) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
                          child: const Icon(Icons.shopping_cart_outlined,
                              color: Colors.white, size: 26),
                        ),
                        if (cartController.cartList.isNotEmpty)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${cartController.cartList.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              // Capsule search bar
              InkWell(
                onTap: () =>
                    Get.toNamed(RouteHelper.getSearchStoreItemRoute(store?.id)),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'search_medicine_or_product'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyStoreContent(
      BuildContext context, StoreController storeController) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick action cards

          _buildPharmacyActionCard(
            context,
            title: 'capture_prescription_photo'.tr,
            subtitle: 'we_will_prepare_it_for_you'.tr,
            icon: Icons.photo_camera,
            onTap: () {},
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),
          // Categories section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'shop_by_category'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'view_all'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_left,
                        color: Theme.of(context).primaryColor, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          // Categories grid
          storeController.categoryList != null &&
                  storeController.categoryList!.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: () {
                    final filtered = storeController.categoryList!
                        .where((c) => c.id != 0)
                        .toList();
                    return filtered.length;
                  }(),
                  itemBuilder: (context, index) {
                    final filtered = storeController.categoryList!
                        .where((c) => c.id != 0)
                        .toList();
                    final category = filtered[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                          category.id, category.name ?? '')),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CustomImage(
                                image: category.imageFullUrl ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }

  Widget _buildPharmacyActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

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

class CategoryProduct {
  CategoryModel category;
  List<Item> products;
  CategoryProduct(this.category, this.products);
}
