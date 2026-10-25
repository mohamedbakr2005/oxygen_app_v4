import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/paginated_list_view.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/offer/domain/models/new_item_model.dart';
import 'package:Oxygen_Mart/common/widgets/featured_store_card.dart';
import 'package:Oxygen_Mart/common/widgets/card_design/item_card.dart';
import 'package:Oxygen_Mart/common/widgets/store_offer_group.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/offer/controllers/offer_controller.dart';
import 'package:Oxygen_Mart/features/service_module/common/models/service_provider_model.dart';
import 'package:Oxygen_Mart/features/service_module/service_home/domain/models/service_model.dart';
import 'package:Oxygen_Mart/features/service_module/provider_details/widgets/provider_service_item_widget.dart';
import 'package:Oxygen_Mart/features/service_module/common/widgets/service_item_card.dart';
import 'package:Oxygen_Mart/features/service_module/service_home/widgets/service_verified_provider_card_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/gaps.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

enum _OfferFilter { all, food, restaurants }

const Set<String> _excludedModuleTypes = <String>{
  AppConstants.parcel,
  AppConstants.taxi,
  AppConstants.ride,
};

List<ModuleModel> _visibleModulesFrom(SplashController splash) {
  final List<ModuleModel> modules = splash.moduleList ?? <ModuleModel>[];
  return modules.where((ModuleModel m) => !_excludedModuleTypes.contains(m.moduleType)).toList();
}

class OfferScreen extends StatefulWidget {
  final Function()? onBackPressed;
  const OfferScreen({super.key, this.onBackPressed});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  _OfferFilter _selectedFilter = _OfferFilter.all;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _searchDebounce;
  int _selectedVisibleIndex = 0;
  ModuleModel? _entryModule;

  @override
  void initState() {
    super.initState();

    final SplashController splash = Get.find<SplashController>();
    _entryModule = splash.module;
    final List<ModuleModel> visibleModules = _visibleModulesFrom(splash);

    int? initialModuleId;
    String? initialModuleType;
    if (visibleModules.isNotEmpty) {
      final ModuleModel? currentSplashModule = _moduleAtSplashIndex(splash, splash.selectedModuleIndex);
      int matchIndex = -1;
      if (currentSplashModule != null && !_excludedModuleTypes.contains(currentSplashModule.moduleType)) {
        matchIndex = visibleModules.indexWhere((ModuleModel m) => m.id == currentSplashModule.id);
      }
      _selectedVisibleIndex = matchIndex >= 0 ? matchIndex : 0;
      initialModuleId = visibleModules[_selectedVisibleIndex].id;
      initialModuleType = visibleModules[_selectedVisibleIndex].moduleType;
    }

    Get.find<OfferController>().loadOffers(
      type: _typeForFilter(_selectedFilter),
      search: '',
      moduleId: initialModuleId,
      moduleType: initialModuleType,
      clearModule: initialModuleId == null,
      reload: true,
      notify: false,
    );
  }

  ModuleModel? _moduleAtSplashIndex(SplashController splash, int splashIndex) {
    if (splashIndex <= 0) return null;
    final int moduleIndex = splashIndex - 1;
    if (splash.moduleList == null || moduleIndex >= splash.moduleList!.length) return null;
    return splash.moduleList![moduleIndex];
  }

  void _onModuleSelected(int visibleIndex, ModuleModel module) {
    setState(() => _selectedVisibleIndex = visibleIndex);
    Get.find<OfferController>().setModuleFilter(module.id, moduleType: module.moduleType);
  }

  bool _isFoodModuleSelected(SplashController splash) {
    final List<ModuleModel> visibleModules = _visibleModulesFrom(splash);
    if (visibleModules.isEmpty || _selectedVisibleIndex >= visibleModules.length) return false;
    return visibleModules[_selectedVisibleIndex].moduleType == AppConstants.food;
  }

  @override
  void dispose() {
    restoreEntryModule();
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void restoreEntryModule() {
    final SplashController splash = Get.find<SplashController>();
    if (splash.module?.id != _entryModule?.id) {
      splash.setModule(_entryModule, notify: false);
    }
  }

  String _typeForFilter(_OfferFilter filter) {
    switch (filter) {
      case _OfferFilter.food:
        return OfferController.typeItem;
      case _OfferFilter.restaurants:
        return OfferController.typeStore;
      case _OfferFilter.all:
        return OfferController.typeAll;
    }
  }

  void _selectFilter(_OfferFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    Get.find<OfferController>().setSelectedType(_typeForFilter(filter));
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      Get.find<OfferController>().setSearchQuery(value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    Get.find<OfferController>().setSearchQuery('');
  }

  List<StoreOfferGroupData> _mapStoresToRestaurantData(List<Store>? stores) {
    if (stores == null || stores.isEmpty) return <StoreOfferGroupData>[];
    return stores.map(StoreOfferGroupData.fromStore).toList();
  }

  void _applySelectedModule() {
    final List<ModuleModel> visibleModules = _visibleModulesFrom(Get.find<SplashController>());
    if (visibleModules.isEmpty || _selectedVisibleIndex >= visibleModules.length) return;
    final ModuleModel module = visibleModules[_selectedVisibleIndex];
    final SplashController splash = Get.find<SplashController>();
    if (module.id != null && splash.module?.id != module.id) {
      splash.setModule(module, notify: false);
    }
  }

  void _openStore(StoreOfferGroupData data) {
    _applySelectedModule();
    Get.toNamed(RouteHelper.getStoreRoute(
      id: data.store.id, page: 'store_new', slug: data.store.slug ?? '',
    ));
  }

  void _openExclusiveStore(Store store) {
    _applySelectedModule();
    Get.toNamed(RouteHelper.getStoreRoute(
      id: store.id, page: 'store_new', slug: store.slug ?? '',
    ));
  }

  void _openItem(StoreOfferGroupData data, TopItem item) {
    _applySelectedModule();
    Get.find<ItemController>().navigateToItemPage(
      Item(id: item.id, name: item.name, slug: item.name?.replaceAll(' ', '_')),
      context,
      inStore: false,
      isCampaign: false,
    );
  }

  void _openServiceItem(Service service) {
    _applySelectedModule();
    Get.toNamed(RouteHelper.getServiceDetailsRoute(id: service.id ?? 0, slug: service.slug ?? ''));
  }

  void _openProvider(Store store) {
    _applySelectedModule();
    final ServiceProvider provider = ServiceProvider.fromStore(store);
    Get.toNamed(
      RouteHelper.getProviderDetailsRoute(store.id ?? 0, slug: store.slug),
      arguments: provider,
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool isTab = ResponsiveHelper.isTab(context);
    final int crossAxisCount = isDesktop ? 4 : (isTab ? 3 : 2);
    final double mainAxisExtent = isDesktop ? 295 : (isTab ? 285 : 280);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisExtent: mainAxisExtent,
      crossAxisSpacing: Dimensions.paddingSizeSmall,
      mainAxisSpacing: Dimensions.paddingSizeSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'offers'.tr,
        backButton: true,
        onBackPressed: widget.onBackPressed,
      ),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<OfferController>(builder: (controller) {
          final List<NewItem> items = controller.itemList?.items ?? <NewItem>[];
          final List<StoreOfferGroupData> restaurants = _mapStoresToRestaurantData(controller.storeList?.stores);
          final List<Store> exclusiveDeals = controller.exclusiveDeals ?? <Store>[];
          final int totalCount = controller.totalResultCount;
          final bool hasSearchText = controller.searchQuery.isNotEmpty;
          final bool isFood = _isFoodModuleSelected(Get.find<SplashController>());
          final bool isService = controller.isServiceModule;
          final bool showModuleTabs = _visibleModulesFrom(Get.find<SplashController>()).length > 1;

          final bool showShimmer = controller.isLoading &&
              (isService ? controller.serviceItemList == null : controller.itemList == null) &&
              controller.storeList == null;

          return Column(
            children: [
              // 1. Module Pills Header
              if (showModuleTabs)
                Container(
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  child: _OfferModuleTabs(
                    selectedVisibleIndex: _selectedVisibleIndex,
                    onModuleSelected: _onModuleSelected,
                    height: 50,
                  ),
                ),

              // 2. Search Bar
              _OfferSearchBar(
                controller: _searchController,
                hasText: hasSearchText,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),

              // 3. Segmented Filter & Results Bar
              _OfferTypeFilterBar(
                selected: _selectedFilter,
                count: totalCount,
                onSelected: _selectFilter,
                isFood: isFood,
                isService: isService,
                isLoading: controller.isLoading,
              ),

              // 4. Main Scrollable Products / Stores Content
              Expanded(
                child: showShimmer
                    ? const SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: _OfferShimmer(),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await controller.loadOffers(reload: true);
                        },
                        color: Theme.of(context).primaryColor,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          child: PaginatedListView(
                            scrollController: _scrollController,
                            totalSize: _selectedFilter == _OfferFilter.food
                                ? (isService ? controller.serviceItemList?.totalSize : controller.itemList?.totalSize)
                                : controller.storeList?.totalSize,
                            offset: _selectedFilter == _OfferFilter.food
                                ? (isService ? controller.serviceItemOffset : controller.itemOffset)
                                : controller.storeOffset,
                            onPaginate: _selectedFilter == _OfferFilter.food
                                ? (isService ? controller.paginateServiceItems : controller.paginateItems)
                                : controller.paginateStores,
                            itemView: isService
                                ? _buildServiceBody(context: context, controller: controller)
                                : _buildBody(
                                    context: context,
                                    items: items,
                                    restaurants: restaurants,
                                    exclusiveDeals: exclusiveDeals,
                                    isFood: isFood,
                                  ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required List<NewItem> items,
    required List<StoreOfferGroupData> restaurants,
    required List<Store> exclusiveDeals,
    required bool isFood,
  }) {
    if (_selectedFilter == _OfferFilter.food) {
      return _buildFoodOnlyBody(context: context, deals: items, isFood: isFood);
    }
    if (_selectedFilter == _OfferFilter.restaurants) {
      return _buildRestaurantOnlyBody(context: context, restaurants: restaurants, isFood: isFood);
    }

    if (items.isEmpty && restaurants.isEmpty && exclusiveDeals.isEmpty) {
      return _buildNoResultsView(context: context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section 1: Offer Items Grid (Our clean, modern product cards!)
        if (items.isNotEmpty) ...<Widget>[
          _SectionHeader(
            title: isFood ? 'foods'.tr : 'items'.tr,
            count: items.length,
            icon: Icons.local_fire_department_rounded,
            actionText: 'view_all'.tr,
            onAction: () => _selectFilter(_OfferFilter.food),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: _buildGridDelegate(context),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final Item item = items[index].toItem();
                return ItemCard(
                  item: item,
                  isFood: isFood,
                  isShop: !isFood,
                  index: index,
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],

        // Section 2: Exclusive Store Deals
        if (exclusiveDeals.isNotEmpty)
          _OfferExclusiveDealsSection(stores: exclusiveDeals, onStoreTap: _openExclusiveStore),

        // Section 3: Stores with Offers
        if (restaurants.isNotEmpty) ...<Widget>[
          _SectionHeader(
            title: isFood ? 'restaurants'.tr : 'stores'.tr,
            count: restaurants.length,
            icon: Icons.storefront_rounded,
            actionText: 'view_all'.tr,
            onAction: () => _selectFilter(_OfferFilter.restaurants),
          ),
          ...restaurants.map((StoreOfferGroupData restaurant) {
            return StoreOfferGroup(
              data: restaurant,
              showBottomDivider: restaurant != restaurants.last,
              onStoreTap: () => _openStore(restaurant),
              onItemTap: (TopItem item) => _openItem(restaurant, item),
            );
          }),
        ],
        Gaps.verticalGapOf(Dimensions.paddingSizeLarge),
      ],
    );
  }

  Widget _buildFoodOnlyBody({
    required BuildContext context,
    required List<NewItem> deals,
    required bool isFood,
  }) {
    if (deals.isEmpty) {
      return _buildNoResultsView(context: context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeader(
          title: isFood ? 'all_food_result'.tr : 'all_item_result'.tr,
          count: deals.length,
          icon: Icons.local_offer_rounded,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _buildGridDelegate(context),
            itemCount: deals.length,
            itemBuilder: (BuildContext context, int index) {
              final Item item = deals[index].toItem();
              return ItemCard(
                item: item,
                isFood: isFood,
                isShop: !isFood,
                index: index,
              );
            },
          ),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeLarge),
      ],
    );
  }

  Widget _buildRestaurantOnlyBody({
    required BuildContext context,
    required List<StoreOfferGroupData> restaurants,
    required bool isFood,
  }) {
    if (restaurants.isEmpty) {
      return _buildNoResultsView(context: context);
    }
    final double storeImageHeight = (MediaQuery.of(context).size.width * 0.38).clamp(130.0, 220.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeader(
          title: isFood ? 'all_restaurant_result'.tr : 'all_store_result'.tr,
          count: restaurants.length,
          icon: Icons.storefront_rounded,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Column(
            children: restaurants.map((StoreOfferGroupData restaurant) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                child: FeaturedStoreCard(
                  data: restaurant.store,
                  width: double.infinity,
                  imageHeight: storeImageHeight,
                  isQuick: false,
                  onTap: () => _openStore(restaurant),
                ),
              );
            }).toList(),
          ),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeLarge),
      ],
    );
  }

  Widget _buildServiceBody({required BuildContext context, required OfferController controller}) {
    final List<Service> services = controller.serviceItemList?.services ?? <Service>[];
    final List<Store> providers = controller.storeList?.stores ?? <Store>[];

    if (_selectedFilter == _OfferFilter.food) {
      return _buildServiceOnlyBody(context: context, services: services);
    }
    if (_selectedFilter == _OfferFilter.restaurants) {
      return _buildProviderOnlyBody(context: context, providers: providers);
    }

    if (services.isEmpty && providers.isEmpty) {
      return _buildNoResultsView(context: context);
    }

    final double cardWidth = (MediaQuery.of(context).size.width * 0.38).clamp(110.0, 150.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (services.isNotEmpty) ...<Widget>[
          _SectionHeader(
            title: 'services'.tr,
            count: services.length,
            icon: Icons.design_services_rounded,
            actionText: 'view_all'.tr,
            onAction: () => _selectFilter(_OfferFilter.food),
          ),
          SizedBox(
            height: cardWidth + 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              physics: const BouncingScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                final Service service = services[index];
                return ServiceItemCard(
                  service: service,
                  width: cardWidth,
                  onTap: () => _openServiceItem(service),
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
        if (providers.isNotEmpty) ...<Widget>[
          _SectionHeader(
            title: 'providers'.tr,
            count: providers.length,
            icon: Icons.verified_user_rounded,
            actionText: 'view_all'.tr,
            onAction: () => _selectFilter(_OfferFilter.restaurants),
          ),
          ...providers.map((Store store) {
            return StoreOfferGroup(
              data: StoreOfferGroupData.fromStore(store),
              showBottomDivider: store != providers.last,
              onStoreTap: () => _openProvider(store),
              onItemTap: (TopItem item) => _openServiceTopItem(item),
            );
          }),
        ],
        Gaps.verticalGapOf(Dimensions.paddingSizeLarge),
      ],
    );
  }

  void _openServiceTopItem(TopItem item) {
    _applySelectedModule();
    Get.toNamed(RouteHelper.getServiceDetailsRoute(id: item.id ?? 0, slug: item.slug ?? ''));
  }

  Widget _buildServiceOnlyBody({required BuildContext context, required List<Service> services}) {
    if (services.isEmpty) {
      return _buildNoResultsView(context: context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeader(
          title: 'all_service_result'.tr,
          count: services.length,
          icon: Icons.design_services_rounded,
        ),
        ...services.map((Service service) {
          final bool isLast = identical(service, services.last);
          return Column(children: [
            ProviderServiceItemWidget(service: service, onBeforeTap: _applySelectedModule),
            if (!isLast)
              Divider(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.12),
                height: 1,
                indent: Dimensions.paddingSizeDefault,
                endIndent: Dimensions.paddingSizeDefault,
              ),
          ]);
        }),
        Gaps.verticalGapOf(Dimensions.paddingSizeLarge),
      ],
    );
  }

  Widget _buildProviderOnlyBody({required BuildContext context, required List<Store> providers}) {
    if (providers.isEmpty) {
      return _buildNoResultsView(context: context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeader(
          title: 'all_provider_result'.tr,
          count: providers.length,
          icon: Icons.verified_user_rounded,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Column(
            children: providers.map((Store store) {
              final ServiceProvider provider = ServiceProvider.fromStore(store);
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                child: GestureDetector(
                  onTap: () => _openProvider(store),
                  child: AbsorbPointer(
                    child: ServiceVerifiedProviderCard(provider: provider, width: double.infinity),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeLarge),
      ],
    );
  }

  Widget _buildNoResultsView({required BuildContext context}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 44,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'no_offers_available'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'dont_miss_out_order_favorites'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;

  const _SectionHeader({
    required this.title,
    this.count,
    this.actionText,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: robotoBold.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _OfferSearchBar({
    required this.controller,
    required this.hasText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'search_for_offers'.tr,
            hintStyle: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall + 1,
              color: Theme.of(context).disabledColor,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 22,
              color: Theme.of(context).primaryColor,
            ),
            suffixIcon: hasText
                ? IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Theme.of(context).disabledColor,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferModuleTabs extends StatelessWidget {
  final int selectedVisibleIndex;
  final void Function(int visibleIndex, ModuleModel module) onModuleSelected;
  final double height;

  const _OfferModuleTabs({
    required this.selectedVisibleIndex,
    required this.onModuleSelected,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      final List<ModuleModel> visibleModules = _visibleModulesFrom(splashController);
      if (visibleModules.isEmpty) return const SizedBox.shrink();

      final int safeSelected = selectedVisibleIndex >= visibleModules.length ? 0 : selectedVisibleIndex;

      return SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: visibleModules.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final ModuleModel module = visibleModules[index];
            final bool isSelected = index == safeSelected;
            final String label = _moduleLabel(module.moduleName, module.moduleType ?? '');

            return InkWell(
              onTap: () => onModuleSelected(index, module),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: (isSelected ? robotoBold : robotoMedium).copyWith(
                    fontSize: Dimensions.fontSizeSmall + 1,
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  String _moduleLabel(String? moduleName, String moduleType) {
    if (moduleName != null && moduleName.trim().isNotEmpty) return moduleName;
    if (moduleType == AppConstants.food) return 'Food';
    if (moduleType == AppConstants.grocery) return 'Grocery';
    if (moduleType == AppConstants.ecommerce) return 'Shop';
    if (moduleType == AppConstants.pharmacy) return 'Pharmacy';
    if (moduleType == AppConstants.service) return 'Service';
    return moduleType.isNotEmpty ? moduleType : 'Module';
  }
}

class _OfferTypeFilterBar extends StatelessWidget {
  final _OfferFilter selected;
  final int count;
  final ValueChanged<_OfferFilter> onSelected;
  final bool isFood;
  final bool isService;
  final bool isLoading;

  const _OfferTypeFilterBar({
    required this.selected,
    required this.count,
    required this.onSelected,
    required this.isFood,
    required this.isService,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final String itemLabel = isService ? 'services'.tr : (isFood ? 'food'.tr : 'items'.tr);
    final String storeLabel = isService ? 'providers'.tr : (isFood ? 'restaurants'.tr : 'stores'.tr);

    final List<(_OfferFilter, String, IconData)> tabs = <(_OfferFilter, String, IconData)>[
      (_OfferFilter.all, 'all'.tr, Icons.grid_view_rounded),
      (_OfferFilter.food, itemLabel, Icons.shopping_bag_outlined),
      (_OfferFilter.restaurants, storeLabel, Icons.storefront_outlined),
    ];

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Filter Chips
          Expanded(
            child: Row(
              children: tabs.map((item) {
                final (_OfferFilter filter, String label, IconData icon) = item;
                final bool isSelected = filter == selected;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => onSelected(filter),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 14,
                            color: isSelected ? Colors.white : Theme.of(context).disabledColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: (isSelected ? robotoBold : robotoMedium).copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Result count badge
          _ResultCountBar(count: count, isLoading: isLoading),
        ],
      ),
    );
  }
}

class _ResultCountBar extends StatelessWidget {
  final int count;
  final bool isLoading;
  const _ResultCountBar({required this.count, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer(
        duration: const Duration(seconds: 2),
        child: Container(
          width: 50,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count ${'results'.tr}',
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall + 1,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _OfferExclusiveDealsSection extends StatelessWidget {
  final List<Store> stores;
  final void Function(Store store) onStoreTap;

  const _OfferExclusiveDealsSection({required this.stores, required this.onStoreTap});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = (MediaQuery.of(context).size.width * 0.80).clamp(240.0, 340.0);
    final double imageHeight = cardWidth * 0.45;
    final double sectionHeight = imageHeight + 107;

    return Container(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Container(
                  width: 3.5,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFB800)),
                const SizedBox(width: 6),
                Text(
                  'exclusive_deals'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SizedBox(
            height: sectionHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              itemCount: stores.length,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (BuildContext context, int index) {
                final Store store = stores[index];
                return FeaturedStoreCard(
                  data: store,
                  width: cardWidth,
                  imageHeight: imageHeight,
                  isQuick: false,
                  onTap: () => onStoreTap(store),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferShimmer extends StatelessWidget {
  const _OfferShimmer();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool isTab = ResponsiveHelper.isTab(context);
    final int crossAxisCount = isDesktop ? 4 : (isTab ? 3 : 2);
    final double mainAxisExtent = isDesktop ? 285 : (isTab ? 275 : 265);

    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ShimmerBar(width: 140, height: 18),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: mainAxisExtent,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisSpacing: Dimensions.paddingSizeSmall,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const _ShimmerProductCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                color: _shimmerColor(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusLarge),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBar(width: 60, height: 10),
                      const SizedBox(height: 6),
                      _ShimmerBar(width: 110, height: 12),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerBar(width: 40, height: 9),
                          const SizedBox(height: 4),
                          _ShimmerBar(width: 55, height: 13),
                        ],
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _shimmerColor(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBar({required this.width, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: _shimmerColor(context),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

Color _shimmerColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFE9E9E9);
}
