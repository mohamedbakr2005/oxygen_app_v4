import 'dart:async';

import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/common/widgets/web_page_title_widget.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/cart/widgets/add_to_monthly_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/cart_item_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/extra_packaging_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/web_cart_items_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/happy_hour/widgets/happy_hour_milestone_banner_widget.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/screens/order_details_screen.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/pro/widgets/pro_cart_banner_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/module_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  final int? storeId;
  final String? storeName;
  const CartScreen({super.key, required this.fromNav, this.storeId, this.storeName});

  static void openAsBottomSheet(BuildContext context, {required int storeId}) {
    final MediaQueryData mq = MediaQuery.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => MediaQuery(
        data: mq.copyWith(padding: mq.viewPadding),
        child: SizedBox(
          height: mq.size.height,
          child: CartScreen(fromNav: false, storeId: storeId),
        ),
      ),
    );
  }

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();
  final GlobalKey _widgetKey = GlobalKey();
  double _height = 0;
  final userId = Get.find<ProfileController>().userInfoModel?.id;

  double get _dashboardBottomInset {
    if (!widget.fromNav) {
      return 0;
    }
    return GetPlatform.isIOS ? 94 : 78;
  }

  @override
  void initState() {
    super.initState();
    final CartController cc = Get.find<CartController>();
    final int? viewStoreId = widget.storeId ?? cc.allCartsGroups?.firstOrNull?.store?.id;
    cc.setActiveCartScreen(viewStoreId);
    initCall();
  }

  @override
  void dispose() {
    Get.find<CartController>().clearActiveCartScreen();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> initCall() async {
    _initialBottomSheetShowHide();
    if (AuthHelper.isLoggedIn()) {
      Get.find<OrderController>().getRunningOrders(1);
      _loadAllHistoryOrders();
    }
    final CartController cartController = Get.find<CartController>();
    final int? effectiveStoreId = widget.storeId
        ?? cartController.allCartsGroups?.firstOrNull?.store?.id;
    await cartController.getCartDataOnline(storeId: effectiveStoreId);

    final int? lockedStoreId = effectiveStoreId
        ?? (cartController.cartList.isNotEmpty ? cartController.cartList.first.item?.storeId : null);
    if (lockedStoreId != null && lockedStoreId != cartController.activeCartScreenStoreId) {
      cartController.setActiveCartScreen(lockedStoreId);
      await cartController.getCartDataOnline(storeId: lockedStoreId);
    }
    if (Get.find<SplashController>().module == null && Get.find<CartController>().cartList.isNotEmpty) {
      final bool activated = await Get.find<SplashController>()
          .activateModuleById(Get.find<CartController>().cartModuleId);
      if (activated && !GetPlatform.isWeb) {
        HomeScreen.loadData(true);
      }
    }
    if (Get.find<CartController>().cartList.isNotEmpty) {
      if (Get.find<CartController>().addCutlery) {
        Get.find<CartController>().updateCutlery(willUpdate: false);
      }
      if (Get.find<CartController>().needExtraPackage) {
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(
          Get.find<CartController>().cartStoreId);
      Get.find<StoreController>().getStoreDetails(
          Store(
              id: Get.find<CartController>().cartStoreId,
              name: null),
          false,
          fromCart: true);
      Get.find<CartController>().calculationCart();
      if (Get.find<ProfileController>().proStatus) {
        Get.find<ProController>().getProActiveOffer(moduleType: Get.find<SplashController>().module?.moduleType);
      }
      showReferAndEarnSnackBar();
    }
  }

  Future<void> _loadAllHistoryOrders({bool isRefresh = false}) async {
    final OrderController orderController = Get.find<OrderController>();

    await orderController.getHistoryOrders(1, isUpdate: isRefresh);

    int loadedOrders = orderController.historyOrderModel?.orders?.length ?? 0;
    final int totalOrders = orderController.historyOrderModel?.totalSize ?? 0;
    int nextPage = 2;
    int previousLoadedOrders = -1;

    while (loadedOrders < totalOrders && loadedOrders != previousLoadedOrders) {
      previousLoadedOrders = loadedOrders;
      await orderController.getHistoryOrders(nextPage);
      loadedOrders = orderController.historyOrderModel?.orders?.length ?? 0;
      nextPage++;
    }
  }

  void _initialBottomSheetShowHide() {
    Future.delayed(const Duration(milliseconds: 600), () {
      key.currentState?.expand();
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          key.currentState?.contract();
        });
      });
    });
  }

  void _getExpandedBottomSheetHeight() {
    final RenderBox? renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    setState(() {
      _height = renderBox.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<CartController>(builder: (cartController) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomAppBar(
          title: 'cart'.tr,
          backButton: true,
          onBackPressed: _handleBackPress,
          clearCart: cartController.selectedFlowTab == 0 &&
              cartController.cartList.isNotEmpty,
        ),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: Column(
          children: [
            _buildFlowTabs(cartController),
            Expanded(
              child: IndexedStack(
                index: cartController.selectedFlowTab,
                children: [
                  GetBuilder<StoreController>(
                    builder: (storeController) => _buildCartTab(
                        cartController, storeController, isDesktop),
                  ),
                  GetBuilder<OrderController>(
                    builder: (orderController) =>
                        _buildOrderTab(orderController, isRunning: true),
                  ),
                  GetBuilder<OrderController>(
                    builder: (orderController) =>
                        _buildOrderTab(orderController, isRunning: false),
                  ),
                ],
              ),
            ),
            if (!isDesktop &&
                cartController.selectedFlowTab == 0 &&
                cartController.cartList.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: _dashboardBottomInset),
                child: CheckoutButton(
                  cartController: cartController,
                  availableList: cartController.availableList,
                ),
              ),
          ],
        ),
      );
    });
  }

  void _handleBackPress() {
    if (widget.fromNav) {
      Get.find<CartController>().setSelectedFlowTab(0, notify: false);
      Get.offNamed(RouteHelper.getMainRoute('home'));
    } else {
      Get.back();
    }
  }

  Widget _buildFlowTabs(CartController cartController) {
    final List<Map<String, dynamic>> tabs = [
      {
        'label': _flowTabLabel('my_cart', 'سلة مشترياتي', 'My Cart'),
        'icon': Icons.shopping_bag_outlined,
        'badge': cartController.cartList.isNotEmpty ? cartController.cartList.length : null,
      },
      {
        'label': _flowTabLabel('current_order', 'طلباتك الحالية', 'Current Order'),
        'icon': Icons.local_shipping_outlined,
        'badge': Get.isRegistered<OrderController>() &&
                (Get.find<OrderController>().runningOrderModel?.orders?.isNotEmpty ?? false)
            ? Get.find<OrderController>().runningOrderModel!.orders!.length
            : null,
      },
      {
        'label': _flowTabLabel('previous_order', 'الطلبات اللي فاتت', 'Previous Order'),
        'icon': Icons.receipt_long_outlined,
        'badge': null,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeExtraSmall,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final bool isSelected = cartController.selectedFlowTab == index;
          final tabData = tabs[index];
          final String label = tabData['label'];
          final IconData icon = tabData['icon'];
          final int? badge = tabData['badge'];

          return Expanded(
            child: InkWell(
              onTap: () => cartController.setSelectedFlowTab(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: (isSelected ? robotoBold : robotoMedium).copyWith(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).disabledColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                    if (badge != null && badge > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.25)
                              : Theme.of(context).primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$badge',
                          style: robotoBold.copyWith(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCartTab(
    CartController cartController,
    StoreController storeController,
    bool isDesktop,
  ) {
    if (cartController.cartList.isEmpty) {
      return _buildEmptyCartView();
    }

    return Column(
      children: [
        Expanded(
          child: ExpandableBottomSheet(
            key: key,
            persistentHeader: isDesktop
                ? const SizedBox()
                : InkWell(
                    onTap: () {
                      if (cartController.isExpanded) {
                        cartController.setExpanded(false);
                        setState(() {
                          key.currentState!.contract();
                        });
                      } else {
                        cartController.setExpanded(true);
                        setState(() {
                          key.currentState!.expand();
                        });
                      }
                    },
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      child: Container(
                        constraints: const BoxConstraints.expand(height: 38),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            background: Column(
              children: [
                WebScreenTitleWidget(title: 'cart_list'.tr),
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: isDesktop
                            ? const EdgeInsets.only(
                                top: Dimensions.paddingSizeSmall,
                              )
                            : EdgeInsets.zero,
                        sliver: SliverToBoxAdapter(
                          child: isDesktop
                              ? WebCardItemsWidget(
                                  cartList: cartController.cartList,
                                )
                              : const SizedBox(),
                        ),
                      ),
                      if (!isDesktop) ...[
                        // Store Header Context Banner
                        if (storeController.store != null ||
                            cartController.cartList.first.item?.storeName != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeSmall,
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeExtraSmall,
                              ),
                              child: _buildStoreContextCard(cartController, storeController),
                            ),
                          ),

                        // Cart Items List
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return CartItemWidget(
                                  cart: cartController.cartList[index],
                                  cartIndex: index,
                                  addOns: cartController.addOnsList[index],
                                  isAvailable:
                                      cartController.availableList[index],
                                );
                              },
                              childCount: cartController.cartList.length,
                            ),
                          ),
                        ),

                        // Add More Items and Extras Section
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (cartController.cartModuleId != null) {
                                      cartController.forcefullySetModule(
                                        cartController.cartModuleId!,
                                      );
                                    }
                                    Get.toNamed(
                                      RouteHelper.getStoreRoute(
                                        id: cartController.cartStoreId,
                                        page: 'item',
                                      ),
                                      arguments: StoreScreen(
                                        store: Store(
                                          id: cartController.cartStoreId,
                                        ),
                                        fromModule: false,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                        Text(
                                          'add_more_items'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              if (_isGroceryOrPharmacy(cartController) &&
                                  !_hasCampaignOrFlashSaleItem(cartController) &&
                                  (AuthHelper.isLoggedIn() &&
                                      Get.find<SplashController>()
                                              .configModel
                                              ?.monthlyOrderRemainder ==
                                          1)) ...[
                                const MonthlyReorderSection(),
                              ],
                              ExtraPackagingWidget(
                                cartController: cartController,
                              ),
                              Get.find<SplashController>().module?.moduleType ==
                                      'grocery'
                                  ? const BestReviewItemView()
                                  : const SizedBox(),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              pricingView(
                                cartController,
                                cartController.cartList[0].item,
                              ),
                              SizedBox(height: 110 + _dashboardBottomInset),
                            ],
                          ),
                        ),
                      ],
                      SliverToBoxAdapter(
                        child: isDesktop
                            ? WebSuggestedItemViewWidget(
                                cartList: cartController.cartList,
                              )
                            : const SizedBox(),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: isDesktop
                              ? Dimensions.paddingSizeExtraOverLarge
                              : _dashboardBottomInset,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _height),
              ],
            ),
            onIsExtendedCallback: _getExpandedBottomSheetHeight,
            onIsContractedCallback: () {
              setState(() {
                _height = 0;
              });
            },
            expandableContent: isDesktop
                ? const SizedBox()
                : Container(
                    width: context.width,
                    key: _widgetKey,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeSmall,
                            Dimensions.paddingSizeDefault,
                            0,
                          ),
                          child: ProCartBannerWidget(
                            subtotal: cartController.subTotal,
                            redirectRoute: RouteHelper.getCartRoute(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            children: [
                              _buildReceiptRow(
                                title: 'item_price'.tr,
                                priceWidget: PriceConverter.convertAnimationPrice(
                                  cartController.itemPrice,
                                  textStyle: robotoMedium.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                              if (cartController.variationPrice > 0 &&
                                  ModuleHelper.getModuleConfig(
                                    cartController.cartModuleType,
                                  ).newVariation!) ...[
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                _buildReceiptRow(
                                  title: 'variations'.tr,
                                  valueText: '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                ),
                              ],
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              _buildReceiptRow(
                                title: 'discount'.tr,
                                isDiscount: true,
                                valueText: storeController.store != null
                                    ? '(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}'
                                    : 'calculating'.tr,
                              ),
                              if (Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .addOn! &&
                                  cartController.addOns > 0) ...[
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                _buildReceiptRow(
                                  title: 'addons'.tr,
                                  valueText: '(+) ${PriceConverter.convertPrice(cartController.addOns)}',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreContextCard(CartController cartController, StoreController storeController) {
    final storeName = storeController.store?.name ?? cartController.cartList.first.item?.storeName ?? 'Store';
    final storeLogo = storeController.store?.logoFullUrl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (storeLogo != null && storeLogo.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomImage(
                image: storeLogo,
                height: 38,
                width: 38,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${cartController.cartList.length} ${cartController.cartList.length > 1 ? 'items'.tr : 'item'.tr}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (cartController.cartModuleId != null) {
                cartController.forcefullySetModule(
                  cartController.cartModuleId!,
                );
              }
              Get.toNamed(
                RouteHelper.getStoreRoute(
                  id: cartController.cartStoreId,
                  page: 'item',
                ),
                arguments: StoreScreen(
                  store: Store(
                    id: cartController.cartStoreId,
                  ),
                  fromModule: false,
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'view_store'.tr.isNotEmpty ? 'view_store'.tr : 'المتجر',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
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

  Widget _buildEmptyCartView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 58,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              'your_cart_is_empty'.tr.isNotEmpty
                  ? 'your_cart_is_empty'.tr
                  : 'سلة التسوق فارغة',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'explore_items_and_start_shopping'.tr.isNotEmpty
                  ? 'explore_items_and_start_shopping'.tr
                  : 'أضف منتجاتك المفضلة من المتاجر لبدء الطلب الآن!',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).disabledColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            SizedBox(
              width: 220,
              child: CustomButton(
                buttonText: 'explore_now'.tr.isNotEmpty
                    ? 'explore_now'.tr
                    : 'ابدأ التسوق الآن',
                radius: 16,
                isBold: true,
                onPressed: () {
                  Get.offNamed(RouteHelper.getMainRoute('home'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTab(
    OrderController orderController, {
    required bool isRunning,
  }) {
    final PaginatedOrderModel? orderModel = isRunning
        ? orderController.runningOrderModel
        : orderController.historyOrderModel;

    if (!AuthHelper.isLoggedIn()) {
      return NoDataScreen(
        text: 'please_login_to_view_orders'.tr.isNotEmpty
            ? 'please_login_to_view_orders'.tr
            : 'no_data_found'.tr,
        showFooter: false,
      );
    }

    if (orderModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderModel.orders == null || orderModel.orders!.isEmpty) {
      return NoDataScreen(
        text: 'no_data_found'.tr,
        showFooter: false,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (isRunning) {
          await orderController.getRunningOrders(1, isUpdate: true);
        } else {
          await _loadAllHistoryOrders(isRefresh: true);
        }
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
          40 + _dashboardBottomInset,
        ),
        itemCount: orderModel.orders!.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) => _OrderHistoryCard(
          order: orderModel.orders![index],
          isRunning: isRunning,
          onTap: () => _openOrder(orderModel.orders![index], isRunning),
        ),
      ),
    );
  }

  void _openOrder(OrderModel order, bool isRunning) {
    Get.toNamed(
      RouteHelper.getOrderDetailsRoute(order.id),
      arguments: OrderDetailsScreen(orderId: order.id, orderModel: order),
    );
  }

  String _flowTabLabel(String key, String arFallback, String enFallback) {
    final String translated = key.tr;
    if (translated != key) {
      return translated;
    }
    return Get.locale?.languageCode == 'ar' ? arFallback : enFallback;
  }

  Widget pricingView(CartController cartController, Item? item) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final String? moduleType = item?.moduleType ?? cartController.cartModuleType;
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: EdgeInsets.all(isDesktop ? Dimensions.paddingSizeDefault : 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GetBuilder<StoreController>(builder: (storeController) {
        return Column(children: [
          isDesktop
              ? ExtraPackagingWidget(cartController: cartController)
              : const SizedBox(),
          isDesktop
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall),
                    child: Text('order_summary'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                  ),
                )
              : const SizedBox(),
          !isDesktop &&
                  Get.find<SplashController>()
                      .getModuleConfig(moduleType)
                      .newVariation! &&
                  (storeController.store != null &&
                      storeController.store!.cutlery!)
              ? Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            Images.cutlery,
                            height: 18,
                            width: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('add_cutlery'.tr,
                                    style: robotoMedium.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                Text('do_not_have_cutlery'.tr,
                                    style: robotoRegular.copyWith(
                                        color: Theme.of(context).disabledColor,
                                        fontSize: Dimensions.fontSizeSmall)),
                              ]),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: cartController.addCutlery,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (bool? value) {
                              cartController.updateCutlery();
                            },
                          ),
                        )
                      ]),
                )
              : const SizedBox(),

          // Price Breakdown Section
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'order_summary'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.15),
                  height: 1,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _buildReceiptRow(
                  title: 'item_price'.tr,
                  priceWidget: PriceConverter.convertAnimationPrice(
                    cartController.itemPrice,
                    textStyle: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (cartController.variationPrice > 0 &&
                    Get.find<SplashController>()
                        .getModuleConfig(moduleType)
                        .newVariation!) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _buildReceiptRow(
                    title: 'variations'.tr,
                    valueText: '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                  ),
                ],
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _buildReceiptRow(
                  title: 'discount'.tr,
                  isDiscount: true,
                  valueText: storeController.store != null
                      ? '(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}'
                      : 'calculating'.tr,
                ),
                if (Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .addOn! &&
                    cartController.addOns > 0) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _buildReceiptRow(
                    title: 'addons'.tr,
                    valueText: '(+) ${PriceConverter.convertPrice(cartController.addOns)}',
                  ),
                ],
                if (cartController.itemDiscountPrice > 0) ...[
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2EAD37).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.celebration_outlined,
                          size: 16,
                          color: Color(0xFF2EAD37),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${'you_saved'.tr} ${PriceConverter.convertPrice(cartController.itemDiscountPrice)} ${'on_this_order'.tr}',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: const Color(0xFF2EAD37),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          isDesktop
              ? Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeSmall),
                  child: ProCartBannerWidget(
                    subtotal: cartController.subTotal,
                    redirectRoute: RouteHelper.getCartRoute(),
                  ),
                )
              : const SizedBox.shrink(),
          isDesktop
              ? CheckoutButton(
                  cartController: cartController,
                  availableList: cartController.availableList)
              : const SizedBox.shrink(),
        ]);
      }),
    );
  }

  Widget _buildReceiptRow({
    required String title,
    String? valueText,
    Widget? priceWidget,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (priceWidget != null)
          priceWidget
        else
          Text(
            valueText ?? '',
            style: (isDiscount ? robotoBold : robotoMedium).copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: isDiscount
                  ? const Color(0xFF2EAD37)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
      ],
    );
  }

  Widget suggestedItemView(List<CartModel> cartList) {
    return Container();
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if (Get.find<ProfileController>().userInfoModel != null &&
        Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
  }

  bool _isGroceryOrPharmacy(CartController cartController) {
    String? moduleType = cartController.cartList.isNotEmpty ? cartController.cartList[0].item?.moduleType : null;
    moduleType ??= Get.find<SplashController>().module?.moduleType ?? ModuleHelper.getCacheModule()?.moduleType;
    if (moduleType == null && cartController.cartList.isNotEmpty && (cartController.cartList[0].item?.moduleId ?? cartController.cartModuleId) != null) {
      final int? mId = cartController.cartList[0].item?.moduleId ?? cartController.cartModuleId;
      for (final m in (Get.find<SplashController>().moduleList ?? [])) {
        if (m.id == mId) {
          moduleType = m.moduleType;
          break;
        }
      }
    }
    return moduleType == AppConstants.grocery || moduleType == AppConstants.pharmacy;
  }

  bool _hasCampaignOrFlashSaleItem(CartController cartController) {
    return cartController.cartList.any((cart) => (cart.isCampaign ?? false) || (cart.item?.flashSale ?? 0) > 0);
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final bool isRunning;
  final VoidCallback onTap;

  const _OrderHistoryCard({
    required this.order,
    required this.isRunning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final _OrderStatusVisual statusVisual = _resolveStatusVisual(context);
    final bool isParcel = order.orderType == 'parcel';
    final int itemCount = order.detailsCount ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 76,
                      width: 76,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.4),
                      child: CustomImage(
                        image: isParcel
                            ? '${order.parcelCategory?.imageFullUrl ?? ''}'
                            : '${order.store?.logoFullUrl ?? ''}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isParcel
                                    ? 'parcel'.tr
                                    : (order.store?.name ?? 'Store'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            _OrderStatusPill(statusVisual: statusVisual),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${order.id ?? ''}',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                DateConverter.dateTimeStringToDateTime(
                                  order.createdAt ?? '',
                                ),
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Divider(color: Theme.of(context).dividerColor.withOpacity(0.12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    PriceConverter.convertPrice(order.orderAmount),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      '$itemCount ${itemCount > 1 ? 'items'.tr : 'item'.tr}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isRunning ? 'track_order'.tr : 'view_details'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _OrderStatusVisual _resolveStatusVisual(BuildContext context) {
    final String status = order.orderStatus ?? '';
    if (status == 'delivered') {
      return _OrderStatusVisual(
        label: 'delivered'.tr,
        textColor: const Color(0xFF2EAD37),
        backgroundColor: const Color(0xFFEAF9EC),
        borderColor: const Color(0xFF39C442),
      );
    }
    if (status == 'canceled' || status == 'failed') {
      return _OrderStatusVisual(
        label: 'canceled'.tr,
        textColor: const Color(0xFFF04B43),
        backgroundColor: const Color(0xFFFFF0EF),
        borderColor: const Color(0xFFFF675F),
      );
    }

    return _OrderStatusVisual(
      label: 'running'.tr,
      textColor: const Color(0xFFC88A00),
      backgroundColor: const Color(0xFFFFF7E1),
      borderColor: const Color(0xFFF2B600),
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  final _OrderStatusVisual statusVisual;

  const _OrderStatusPill({required this.statusVisual});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: statusVisual.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusVisual.borderColor.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: statusVisual.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            statusVisual.label,
            style: robotoMedium.copyWith(
              color: statusVisual.textColor,
              fontSize: Dimensions.fontSizeExtraSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusVisual {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const _OrderStatusVisual({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  const CheckoutButton(
      {super.key, required this.cartController, required this.availableList});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveHelper.isDesktop(context)
              ? Dimensions.radiusDefault
              : 24),
          topRight: Radius.circular(ResponsiveHelper.isDesktop(context)
              ? Dimensions.radiusDefault
              : 24),
        ),
        boxShadow: ResponsiveHelper.isDesktop(context)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: GetBuilder<StoreController>(builder: (storeController) {
        final double? freeDeliveryTarget =
            Get.find<SplashController>().configModel!.freeDeliveryOver;
        final bool showFreeDeliveryProgress = storeController.store != null &&
            !storeController.store!.freeDelivery! &&
            freeDeliveryTarget != null;

        if (showFreeDeliveryProgress) {
          percentage = (cartController.subTotal / freeDeliveryTarget).clamp(0.0, 1.0);
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HappyHourMilestoneBannerWidget(
                subtotal: cartController.subTotal,
                isHappyHourRunning: storeController.store?.isHappyHourRunning,
                storeId: storeController.store?.id,
                roundedBottom: true,
                bottomSpacing: Dimensions.paddingSizeSmall,
                showCountdown: false,
              ),
              if (showFreeDeliveryProgress && percentage < 1.0)
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'أضف '.tr.isNotEmpty ? 'أضف ' : 'Add ',
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              TextSpan(
                                text: PriceConverter.convertPrice(
                                  freeDeliveryTarget - cartController.subTotal,
                                ),
                                style: robotoBold.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              TextSpan(
                                text: ' ${'more_for_free_delivery'.tr}',
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.12),
                        value: percentage,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              ResponsiveHelper.isDesktop(context)
                  ? Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.1))
                  : const SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'subtotal'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      PriceConverter.convertAnimationPrice(
                        cartController.subTotal,
                        textStyle: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: CustomButton(
                      buttonText: 'confirm_delivery_details'.tr,
                      fontSize: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.fontSizeSmall
                          : Dimensions.fontSizeDefault,
                      isBold: true,
                      radius: 16,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () async {
                        bool isScheduleOrder = cartController.cartList.isNotEmpty &&
                            cartController.cartList.first.item != null &&
                            (cartController.cartList.first.item!.scheduleOrder ?? false);

                        if (!isScheduleOrder && availableList.contains(false)) {
                          showCustomSnackBar('one_or_more_product_unavailable'.tr);
                        } else {
                          if (Get.find<SplashController>().module == null) {
                            final bool activated = await Get.find<SplashController>()
                                .activateModuleById(cartController.cartModuleId);
                            if (!activated) {
                              showCustomSnackBar('no_module_found'.tr);
                              return;
                            }
                            HomeScreen.loadData(true);
                          }
                          Get.find<CouponController>().removeCouponData(false);

                          Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
