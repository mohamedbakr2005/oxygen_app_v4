import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/cart_widget.dart';
import 'package:Oxygen_Mart/common/widgets/item_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/veg_filter_widget.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;

  const CategoryItemScreen({
    super.key,
    required this.categoryID,
    required this.categoryName,
  });

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  final ScrollController _subCategoryTabController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<GlobalKey> _sectionKeys = [];
  final ValueNotifier<int> _activeSubCategoryNotifier = ValueNotifier<int>(0);
  bool _isTabNavigating = false;

  TabController? _tabController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ModuleModel? _initialModule;

  @override
  void initState() {
    super.initState();
    _initialModule = Get.find<SplashController>().module;
    _setupModuleContext();

    _tabController = TabController(length: 1, initialIndex: 0, vsync: this);
    Get.find<CategoryController>()
        .loadCategoryData(widget.categoryID, notify: false);

    scrollController.addListener(_onMainScroll);
  }

  void _setupModuleContext() {
    final String? moduleParam = Get.parameters['module'];
    if (moduleParam != null && moduleParam.isNotEmpty && moduleParam != 'null') {
      final int? moduleId = int.tryParse(moduleParam);
      if (moduleId != null && Get.find<SplashController>().moduleList != null) {
        for (final ModuleModel m in Get.find<SplashController>().moduleList!) {
          if (m.id == moduleId) {
            Get.find<SplashController>().setModule(m, notify: false);
            final addressModel = AddressHelper.getUserAddressFromSharedPref();
            if (Get.isRegistered<ApiClient>() &&
                Get.isRegistered<SharedPreferences>()) {
              Get.find<ApiClient>().updateHeader(
                Get.find<SharedPreferences>().getString(AppConstants.token),
                addressModel?.zoneIds,
                addressModel?.areaIds,
                Get.find<LocalizationController>().locale.languageCode,
                m.id,
                addressModel?.latitude,
                addressModel?.longitude,
                null,
              );
            }
            break;
          }
        }
      }
    }
  }

  void _restoreModuleContext() {
    if (!Get.isRegistered<SplashController>()) return;
    final splash = Get.find<SplashController>();
    if (_initialModule == null) {
      splash.setModule(null, notify: true);
      splash.selectHomeModule();
      if (Get.isRegistered<ApiClient>() &&
          Get.isRegistered<SharedPreferences>()) {
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
      if (Get.isRegistered<ApiClient>() &&
          Get.isRegistered<SharedPreferences>()) {
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

  void _onMainScroll() {
    if (_isTabNavigating || _sectionKeys.isEmpty) return;

    if (scrollController.hasClients && scrollController.offset <= 10) {
      if (_activeSubCategoryNotifier.value != 0) {
        _activeSubCategoryNotifier.value = 0;
        _scrollToTab(0);
      }
      return;
    }

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      if (key.currentContext != null) {
        final renderObject = key.currentContext!.findRenderObject();
        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero).dy;
          final height = renderObject.size.height;
          const double threshold = 250.0;

          if (position <= threshold && (position + height) > threshold) {
            if (_activeSubCategoryNotifier.value != i) {
              _activeSubCategoryNotifier.value = i;
              _scrollToTab(i);
            }
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _restoreModuleContext();
    if (Get.isRegistered<CategoryController>()) {
      Get.find<CategoryController>().clearCategoryData();
    }
    scrollController.removeListener(_onMainScroll);
    _activeSubCategoryNotifier.dispose();
    _subCategoryTabController.dispose();
    scrollController.dispose();
    storeScrollController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _scrollToTab(int index) {
    if (_subCategoryTabController.hasClients) {
      double offset = index * 105.0;
      if (offset > _subCategoryTabController.position.maxScrollExtent) {
        offset = _subCategoryTabController.position.maxScrollExtent;
      }
      _subCategoryTabController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _onTabTapped(int index) async {
    if (_isTabNavigating) return;

    _isTabNavigating = true;
    _activeSubCategoryNotifier.value = index;
    _scrollToTab(index);

    if (index == 0) {
      if (scrollController.hasClients) {
        await scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else if (index < _sectionKeys.length) {
      final contextToScroll = _sectionKeys[index].currentContext;
      if (contextToScroll != null) {
        await Scrollable.ensureVisible(
          contextToScroll,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    }

    _isTabNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      List<Store>? stores;

      if (catController.currentCategoryId != widget.categoryID) {
        item = null;
        stores = null;
      } else if (catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }

      if (catController.currentCategoryId != widget.categoryID) {
        stores = null;
      } else if (catController.isSearching
          ? catController.searchStoreList != null
          : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }

      if (catController.subCategoryList != null &&
          _sectionKeys.length != catController.subCategoryList!.length) {
        _sectionKeys = List.generate(
          catController.subCategoryList!.length,
          (index) => GlobalKey(),
        );
      }

      return PopScope(
        canPop: !catController.isSearching,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop && catController.isSearching) {
            _searchTextController.clear();
            _searchFocusNode.unfocus();
            catController.toggleSearch();
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          appBar: (ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
                  backgroundColor: Theme.of(context).cardColor,
                  surfaceTintColor: Theme.of(context).cardColor,
                  shadowColor: Colors.black.withOpacity(0.04),
                  elevation: 2,
                  title: catController.isSearching
                      ? SizedBox(
                          height: 42,
                          child: TextField(
                            controller: _searchTextController,
                            focusNode: _searchFocusNode,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'search'.tr,
                              hintStyle: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: 8,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _searchTextController.clear();
                                  _searchFocusNode.unfocus();
                                  catController.toggleSearch();
                                },
                                icon: Icon(
                                  catController.isSearching
                                      ? Icons.close_rounded
                                      : Icons.search_rounded,
                                  color: Theme.of(context).disabledColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                            onSubmitted: (String query) {
                              catController.searchData(
                                query,
                                widget.categoryID,
                                catController.type,
                              );
                            },
                          ),
                        )
                      : Text(
                          widget.categoryName,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                  centerTitle: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: Theme.of(context).colorScheme.onSurface,
                    onPressed: () {
                      if (catController.isSearching) {
                        _searchTextController.clear();
                        _searchFocusNode.unfocus();
                        catController.toggleSearch();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  actions: [
                    if (!catController.isSearching)
                      IconButton(
                        onPressed: () {
                          catController.toggleSearch();
                          if (catController.isSearching) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _searchFocusNode.requestFocus(),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.search_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 22,
                        ),
                      ),
                    IconButton(
                      onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                      icon: CartWidget(
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                    VegFilterWidget(
                      type: catController.type,
                      fromAppBar: true,
                      onSelected: (String type) {
                        if (catController.isSearching) {
                          catController.searchData(
                            _searchTextController.text,
                            widget.categoryID,
                            type,
                          );
                        } else {
                          if (catController.isStore) {
                            catController.getCategoryStoreList(
                              widget.categoryID,
                              1,
                              type,
                              true,
                            );
                          } else {
                            catController.getCategoryItemList(
                              widget.categoryID,
                              1,
                              type,
                              true,
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  ],
                )),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: item == null
              ? _buildSkeletonLoading(context)
              : RefreshIndicator(
                  onRefresh: () async => await catController
                      .loadCategoryData(widget.categoryID, reload: true),
                  color: Theme.of(context).primaryColor,
                  child: _buildBody(catController, item, stores),
                ),
        ),
      );
    });
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 44,
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).disabledColor.withOpacity(0.08),
                  ),
                );
              },
            ),
          ),
          const Expanded(
            child: ItemsView(
              isStore: false,
              items: null,
              stores: null,
              shimmerLength: 12,
              isScrollable: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    CategoryController catController,
    List<Item>? item,
    List<Store>? stores,
  ) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: Column(
        children: [
          // Subcategory capsules horizontal bar
          if (catController.subCategoryList != null &&
              catController.subCategoryList!.isNotEmpty &&
              !catController.isSearching)
            Container(
              height: 48,
              width: Dimensions.webMaxWidth,
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(
                vertical: 6,
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _activeSubCategoryNotifier,
                builder: (context, activeIndex, child) {
                  return ListView.builder(
                    controller: _subCategoryTabController,
                    scrollDirection: Axis.horizontal,
                    itemCount: catController.subCategoryList!.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final bool isSelected = index == activeIndex;
                      return _SubCategoryPill(
                        title: catController.subCategoryList![index].name ?? '',
                        isSelected: isSelected,
                        onTap: () => _onTabTapped(index),
                      );
                    },
                  );
                },
              ),
            ),

          // Main product list
          Expanded(
            child: _buildProductScrollView(catController, item),
          ),
        ],
      ),
    );
  }

  Widget _buildProductScrollView(
      CategoryController catController, List<Item>? item) {
    final bool hasSubcategories = catController.subCategoryList != null &&
        catController.subCategoryList!.isNotEmpty &&
        item != null &&
        _sectionKeys.isNotEmpty &&
        !catController.isSearching;

    if (hasSubcategories) {
      return CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: _buildSubcategorySlivers(catController, item),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        ItemsView(
          isStore: false,
          items: item,
          stores: null,
          noDataText: 'no_category_item_found'.tr,
          returnSliverWidget: true,
        ),
      ],
    );
  }

  List<Widget> _buildSubcategorySlivers(
      CategoryController catController, List<Item> item) {
    final List<Widget> slivers = [];

    // Pre-group items by subcategory id for O(1) performance lookup
    final Map<String, List<Item>> subCategoryItemsMap = {};
    for (final i in item) {
      if (i.categoryIds != null) {
        for (final c in i.categoryIds!) {
          final key = c.id.toString();
          subCategoryItemsMap.putIfAbsent(key, () => <Item>[]).add(i);
        }
      }
    }

    int totalCategorizedItems = 0;

    for (int index = 0;
        index < catController.subCategoryList!.length;
        index++) {
      final subCategory = catController.subCategoryList![index];
      final String subCatId = subCategory.id.toString();

      // Previously skipped index 0 because it was the 'all' item.
      // Now only subcategories exist, so check by ID/name if 'all' is ever passed.
      if (subCatId == '0' || subCategory.name == 'all'.tr) {
        slivers.add(SliverToBoxAdapter(
          child: SizedBox.shrink(key: _sectionKeys[index]),
        ));
        continue;
      }

      final List<Item> sectionItems =
          subCategoryItemsMap[subCatId] ?? <Item>[];
      totalCategorizedItems += sectionItems.length;

      if (sectionItems.isEmpty) {
        slivers.add(SliverToBoxAdapter(
          child: SizedBox.shrink(key: _sectionKeys[index]),
        ));
        continue;
      }

      // Modern Section Header
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          key: _sectionKeys[index],
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeExtraSmall,
          ),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subCategory.name ?? '',
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${sectionItems.length}',
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ));

      slivers.add(ItemsView(
        isStore: false,
        items: sectionItems,
        stores: null,
        noDataText: 'no_category_item_found'.tr,
        returnSliverWidget: true,
      ));

      slivers.add(const SliverToBoxAdapter(
        child: SizedBox(height: Dimensions.paddingSizeSmall),
      ));
    }

    // Fallback: If no subcategory sections had any items but item list is not empty, display all items
    if (totalCategorizedItems == 0 && item.isNotEmpty) {
      slivers.add(ItemsView(
        isStore: false,
        items: item,
        stores: null,
        noDataText: 'no_category_item_found'.tr,
        returnSliverWidget: true,
      ));
    }

    return slivers;
  }
}

class _SubCategoryPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryPill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: (isSelected ? robotoBold : robotoMedium).copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
