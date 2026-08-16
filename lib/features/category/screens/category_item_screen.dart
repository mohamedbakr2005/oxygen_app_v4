import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/cart_widget.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/item_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/veg_filter_widget.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen(
      {super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();

  // --- إضافات المزامنة (Synced Scroll) مع تحسين الأداء ---
  final ScrollController _subCategoryTabController = ScrollController();
  List<GlobalKey> _sectionKeys = [];

  // استخدمنا ValueNotifier بدل المتغير العادي عشان نمنع الـ setState للشاشة كلها
  final ValueNotifier<int> _activeSubCategoryNotifier = ValueNotifier<int>(0);
  bool _isTabNavigating = false;
  // ---------------------------------------

  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 1, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (ResponsiveHelper.isDesktop(context)) {
    //     Get.find<CategoryController>().getCategoryStoreList(
    //       widget.categoryID,
    //       1,
    //       Get.find<CategoryController>().type,
    //       false,
    //     );
    //   }
    // });

    scrollController.addListener(() {
      if (_isTabNavigating || _sectionKeys.isEmpty) return;

      // مزامنة التابات
      for (int i = 0; i < _sectionKeys.length; i++) {
        final key = _sectionKeys[i];

        if (key.currentContext != null) {
          final renderObject = key.currentContext!.findRenderObject();
          
          if (renderObject is RenderBox) {
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

    });
  }

  @override
  void dispose() {
    _activeSubCategoryNotifier.dispose();
    _subCategoryTabController.dispose();
    scrollController.dispose();
    storeScrollController.dispose();
    super.dispose();
  }

  void _scrollToTab(int index) {
    if (_subCategoryTabController.hasClients) {
      double offset = index * 100.0;
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

    // مش محتاجين setState هنا، مجرد تغيير القيمة هيحدث التاب الأفقية فقط
    _isTabNavigating = true;
    _activeSubCategoryNotifier.value = index;

    _scrollToTab(index);

    final contextToScroll = _sectionKeys[index].currentContext;
    if (contextToScroll != null) {
      await Scrollable.ensureVisible(
        contextToScroll,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }

    _isTabNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      // bool isFetchingAllItems = false;

      List<Item>? item;
      List<Store>? stores;

      if (catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }

      if (catController.isSearching
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
            catController.subCategoryList!.length, (index) => GlobalKey());
      }
      print("BUILD => item=${item?.length}");
      print(
          "BUILD => controllerList=${catController.categoryItemList?.length}");
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (catController.isSearching) {
            catController.toggleSearch();
          } else {
            return;
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          appBar: (ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
                  backgroundColor: Theme.of(context).cardColor,
                  surfaceTintColor: Theme.of(context).cardColor,
                  shadowColor: Theme.of(context).disabledColor.withOpacity(0.5),
                  elevation: 2,
                  title: catController.isSearching
                      ? SizedBox(
                          height: 45,
                          child: TextField(
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => catController.toggleSearch(),
                                  icon: Icon(
                                    catController.isSearching
                                        ? Icons.close_sharp
                                        : Icons.search,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ),
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge),
                              onSubmitted: (String query) {
                                catController.searchData(
                                  query,
                                  widget.categoryID,
                                  catController.type,
                                );
                              }),
                        )
                      : Text(widget.categoryName,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                  centerTitle: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      if (catController.isSearching) {
                        catController.toggleSearch();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  actions: [
                    !catController.isSearching
                        ? IconButton(
                            onPressed: () => catController.toggleSearch(),
                            icon: Icon(
                              catController.isSearching
                                  ? Icons.close_sharp
                                  : Icons.search,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          )
                        : const SizedBox(),
                    IconButton(
                      onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                      icon: CartWidget(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          size: 25),
                    ),
                    VegFilterWidget(
                        type: catController.type,
                        fromAppBar: true,
                        onSelected: (String type) {
                          if (catController.isSearching) {
                            catController.searchData(
                              widget.categoryID,
                              '1',
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
                        }),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
                )),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: item == null
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : _buildBody(catController, item, stores),
        ),
      );
    });
  }

  Widget _buildBody(
      CategoryController catController, List<Item>? item, List<Store>? stores) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: Column(children: [
        const SizedBox(height: 10),

        // --- Subcategory capsules with ValueListenableBuilder ---
        (catController.subCategoryList != null && !catController.isSearching)
            ? Center(
                child: Container(
                height: 40,
                width: Dimensions.webMaxWidth,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall),
                child: ValueListenableBuilder<int>(
                  valueListenable: _activeSubCategoryNotifier,
                  builder: (context, activeIndex, child) {
                    return ListView.builder(
                      controller: _subCategoryTabController,
                      scrollDirection: Axis.horizontal,
                      itemCount: catController.subCategoryList!.length,
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeSmall),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        bool isSelected = index == activeIndex;

                        return InkWell(
                          onTap: () => _onTabTapped(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeExtraSmall),
                            margin: const EdgeInsets.only(
                                right: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2)
                                  : Theme.of(context).cardColor,
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 1)
                                  : Border.all(
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withOpacity(0.5),
                                      width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  catController.subCategoryList![index].name!,
                                  style: isSelected
                                      ? robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor)
                                      : robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ))
            : const SizedBox(),

        Center(
            child: Container(
          width: Dimensions.webMaxWidth,
          color: Theme.of(context).cardColor,
          child: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).disabledColor,
            unselectedLabelStyle: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor,
                fontSize: Dimensions.fontSizeSmall),
            labelStyle: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor),
            tabs: [
              Tab(text: 'item'.tr),
            ],
          ),
        )),

        // ── Main content area: CustomScrollView with Slivers for lazy rendering ──
        Expanded(
            child: NotificationListener(
          onNotification: (dynamic scrollNotification) {
            if (scrollNotification is ScrollEndNotification) {
              if ((_tabController!.index == 1 && !catController.isStore) ||
                  _tabController!.index == 0 && catController.isStore) {
                catController.setRestaurant(_tabController!.index == 1);
                if (catController.isSearching) {
                  catController.searchData(
                    catController.searchText,
                    widget.categoryID,
                    catController.type,
                  );
                } else {
                  if (_tabController!.index == 1) {
                    catController.getCategoryStoreList(
                      widget.categoryID,
                      1,
                      catController.type,
                      false,
                    );
                  } else {
                    catController.getCategoryItemList(
                      widget.categoryID,
                      1,
                      catController.type,
                      false,
                    );
                  }
                }
              }
            }
            return false;
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              // ── PERFORMANCE FIX: CustomScrollView + Slivers ──
              // Previously: SingleChildScrollView + Column + ItemsView(shrinkWrap:true)
              // This forced ALL 150 product widgets to build immediately.
              // Now: CustomScrollView lazily builds only the ~9-12 visible cards.
              _buildProductScrollView(catController, item),
            ],
          ),
        )),
      ]),
    );
  }

  /// Builds the main product list using CustomScrollView with Slivers
  /// for true lazy rendering. Only visible product cards are built.
  Widget _buildProductScrollView(CategoryController catController, List<Item>? item) {
    final bool hasSubcategories = catController.subCategoryList != null &&
        item != null &&
        _sectionKeys.isNotEmpty;

    if (hasSubcategories) {
      return CustomScrollView(
        controller: scrollController,
        slivers: _buildSubcategorySlivers(catController, item!),
      );
    }

    // Fallback: no subcategories, show all items in a single sliver grid
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        ItemsView(
          isStore: false,
          items: item,
          stores: null,
          noDataText: 'no_category_item_found'.tr,
          returnSliverWidget: true, // Use sliver mode for lazy rendering
        ),
      ],
    );
  }

  /// Generates a list of slivers: for each subcategory, a header sliver
  /// (with GlobalKey for scroll sync) + a SliverGrid of filtered items.
  List<Widget> _buildSubcategorySlivers(CategoryController catController, List<Item> item) {
    final List<Widget> slivers = [];

    for (int index = 0; index < catController.subCategoryList!.length; index++) {
      final subCategory = catController.subCategoryList![index];

      final sectionItems = item.where((i) {
        if (subCategory.id.toString() == '0') return false;
        return i.categoryIds?.any((c) =>
                c.id.toString() ==
                subCategory.id.toString()) ??
            false;
      }).toList();

      if (subCategory.id.toString() == '0' || sectionItems.isEmpty) {
        // Empty section — still need the GlobalKey for scroll sync
        // Key must be on the child (RenderBox), not on SliverToBoxAdapter (RenderSliver)
        slivers.add(SliverToBoxAdapter(
          child: SizedBox.shrink(key: _sectionKeys[index]),
        ));
        continue;
      }

      // Section header — key on the Padding child (RenderBox) for scroll sync
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          key: _sectionKeys[index],
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall),
          child: Text(
            subCategory.name ?? '',
            style: robotoBold.copyWith(fontSize: 16),
          ),
        ),
      ));

      // Section items as a SliverGrid — only visible cards are built
      slivers.add(ItemsView(
        isStore: false,
        items: sectionItems,
        stores: null,
        noDataText: 'no_category_item_found'.tr,
        returnSliverWidget: true, // Use sliver mode for lazy rendering
      ));

      // Bottom spacing between sections
      slivers.add(const SliverToBoxAdapter(
        child: SizedBox(height: Dimensions.paddingSizeLarge),
      ));
    }

    return slivers;
  }
}

