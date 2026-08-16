import 'dart:async';
import 'dart:convert';

import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/item_widget.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/common/widgets/web_constrained_box.dart';
import 'package:Oxygen_Mart/common/widgets/web_page_title_widget.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/cart/widgets/cart_item_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/extra_packaging_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/not_available_bottom_sheet_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/web_cart_items_widget.dart';
import 'package:Oxygen_Mart/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/screens/order_details_screen.dart';
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
import 'package:Oxygen_Mart/socket_service.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_html/js.dart' as js;

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

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
    initCall();

    SocketService.connect(
      userId: userId ?? 0,
      onCartUpdate: (data) {
        print("🔄 Cart Update Event Received in UI");
        Get.find<CartController>().handleRealtimeCartEvent(data);
      },
    );
    // 🚨 تم إزالة الـ Polling Timer لأنه بيهلك السيرفر والبطارية والمفروض نعتمد على الـ Socket
  }

  @override
  void dispose() {
    SocketService.disconnect();
    super.dispose();
  }

  Future<void> initCall() async {
    _initialBottomSheetShowHide();
    if (AuthHelper.isLoggedIn()) {
      Get.find<OrderController>().getRunningOrders(1);
      _loadAllHistoryOrders();
    }
    if (Get.find<CartController>().cartList.isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
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
          Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(
          Store(
              id: Get.find<CartController>().cartList[0].item!.storeId,
              name: null),
          false,
          fromCart: true);
      Get.find<CartController>().calculationCart();
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
    final List<String> tabs = [
      _flowTabLabel('my_cart', 'سلة مشترياتي', 'My Cart'),
      _flowTabLabel('current_order', 'طلباتك الحالية', 'Current Order'),
      _flowTabLabel('previous_order', 'الطلبات اللي فاتت', 'Previous Order'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        0,
      ),
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusLarge),
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.35),
          ),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final bool isSelected = cartController.selectedFlowTab == index;
          return Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double tabFontSize =
                    constraints.maxWidth < 112 ? 12.5 : 15;
                final double indicatorWidth =
                    (constraints.maxWidth * 0.62).clamp(42.0, 90.0).toDouble();

                return InkWell(
                  onTap: () => cartController.setSelectedFlowTab(index),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeExtraSmall,
                      right: Dimensions.paddingSizeExtraSmall,
                      bottom: Dimensions.paddingSizeSmall,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tabs[index],
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: (isSelected ? robotoBold : robotoRegular)
                                  .copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).disabledColor,
                                fontSize: tabFontSize,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          height: 3,
                          width: isSelected ? indicatorWidth : 0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
      return const NoDataScreen(
        isCart: true,
        text: '',
        showFooter: true,
      );
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
                        constraints: const BoxConstraints.expand(height: 40),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.4),
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
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeSmall,
                                  ),
                                  child: CartItemWidget(
                                    cart: cartController.cartList[index],
                                    cartIndex: index,
                                    addOns: cartController.addOnsList[index],
                                    isAvailable:
                                        cartController.availableList[index],
                                  ),
                                );
                              },
                              childCount: cartController.cartList.length,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withOpacity(0.5),
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    cartController.forcefullySetModule(
                                      cartController
                                          .cartList[0].item!.moduleId!,
                                    );
                                    Get.toNamed(
                                      RouteHelper.getStoreRoute(
                                        id: cartController
                                            .cartList[0].item!.storeId,
                                        page: 'item',
                                      ),
                                      arguments: StoreScreen(
                                        store: Store(
                                          id: cartController
                                              .cartList[0].item!.storeId,
                                        ),
                                        fromModule: false,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                      Icons.add_circle_outline_sharp),
                                  label: Text(
                                    'add_more_items'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge,
                              ),
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
                                cartController.cartList[0].item!,
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
                        Container(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'item_price'.tr,
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  PriceConverter.convertAnimationPrice(
                                    cartController.itemPrice,
                                    textStyle: robotoMedium.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: cartController.variationPrice > 0 &&
                                        ModuleHelper.getModuleConfig(
                                          cartController
                                              .cartList.first.item!.moduleType,
                                        ).newVariation!
                                    ? Dimensions.paddingSizeSmall
                                    : 0,
                              ),
                              cartController.variationPrice > 0 &&
                                      ModuleHelper.getModuleConfig(
                                        cartController
                                            .cartList.first.item!.moduleType,
                                      ).newVariation!
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'variations'.tr,
                                          style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                          style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'discount'.tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  storeController.store != null
                                      ? Row(
                                          children: [
                                            Text(
                                              '(-)',
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                              ),
                                            ),
                                            PriceConverter
                                                .convertAnimationPrice(
                                              cartController.itemDiscountPrice,
                                              textStyle: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'calculating'.tr,
                                          style: robotoRegular,
                                        ),
                                ],
                              ),
                              SizedBox(
                                height: Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .addOn!
                                    ? Dimensions.paddingSizeSmall
                                    : 0,
                              ),
                              Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .addOn!
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'addons'.tr,
                                          style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '(+)',
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            PriceConverter
                                                .convertAnimationPrice(
                                              cartController.addOns,
                                              textStyle: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
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

  Widget _buildOrderTab(
    OrderController orderController, {
    required bool isRunning,
  }) {
    final PaginatedOrderModel? orderModel = isRunning
        ? orderController.runningOrderModel
        : orderController.historyOrderModel;

    if (!AuthHelper.isLoggedIn()) {
      return NoDataScreen(
        text: 'no_data_found'.tr,
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
    if (isRunning) {
      Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, null));
    } else {
      Get.toNamed(
        RouteHelper.getOrderDetailsRoute(order.id),
        arguments: OrderDetailsScreen(orderId: order.id, orderModel: order),
      );
    }
  }

  String _flowTabLabel(String key, String arFallback, String enFallback) {
    final String translated = key.tr;
    if (translated != key) {
      return translated;
    }
    return Get.locale?.languageCode == 'ar' ? arFallback : enFallback;
  }

  Widget pricingView(CartController cartController, Item item) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: EdgeInsets.all(isDesktop ? Dimensions.paddingSizeDefault : 0),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceVariant
            .withOpacity(0.3), // M3 Surface Variant
        borderRadius: BorderRadius.circular(24), // M3 rounded corners
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
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
                      .getModuleConfig(item.moduleType)
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
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            Images.cutlery,
                            height: 18,
                            width: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: Dimensions.fontSizeSmall)),
                              ]),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: cartController.addCutlery,
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (bool? value) {
                              cartController.updateCutlery();
                            },
                            trackColor: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withOpacity(0.5),
                          ),
                        )
                      ]),
                )
              : const SizedBox(),
          isDesktop
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('item_price'.tr, style: robotoRegular),
                          PriceConverter.convertAnimationPrice(
                              cartController.itemPrice,
                              textStyle: robotoRegular),
                        ]),
                    SizedBox(
                        height: cartController.variationPrice > 0
                            ? Dimensions.paddingSizeSmall
                            : 0),
                    Get.find<SplashController>()
                                .getModuleConfig(item.moduleType)
                                .newVariation! &&
                            cartController.variationPrice > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('variations'.tr, style: robotoRegular),
                              Text(
                                '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                style: robotoRegular,
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('discount'.tr, style: robotoRegular),
                          storeController.store != null
                              ? Row(children: [
                                  Text('(-)', style: robotoRegular),
                                  PriceConverter.convertAnimationPrice(
                                      cartController.itemDiscountPrice,
                                      textStyle: robotoRegular),
                                ])
                              : Text('calculating'.tr, style: robotoRegular),
                        ]),
                    SizedBox(
                        height: Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .addOn!
                            ? 10
                            : 0),
                    Get.find<SplashController>()
                            .configModel!
                            .moduleConfig!
                            .module!
                            .addOn!
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('addons'.tr, style: robotoRegular),
                              Text(
                                '(+) ${PriceConverter.convertPrice(cartController.addOns)}',
                                style: robotoRegular,
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ]),
                )
              : const SizedBox(),
          isDesktop
              ? CheckoutButton(
                  cartController: cartController,
                  availableList: cartController.availableList)
              : const SizedBox.shrink(),
        ]);
      }),
    );
  }

  Widget suggestedItemView(List<CartModel> cartList) {
    // ... نفس الكود بتاعك مفيش تغيير
    return Container();
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if (Get.find<ProfileController>().userInfoModel != null &&
        Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
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
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 86,
                      width: 86,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.45),
                      child: CustomImage(
                        image: isParcel
                            ? '${order.parcelCategory?.imageFullUrl ?? ''}'
                            : '${order.store?.logoFullUrl ?? ''}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isParcel
                              ? 'parcel'.tr
                              : (order.store?.name ?? 'Store'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                        Text(
                          '#${order.id ?? ''}',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                        Text(
                          DateConverter.dateTimeStringToDateTime(
                            order.createdAt ?? '',
                          ),
                          style: robotoRegular.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _OrderStatusPill(statusVisual: statusVisual),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Divider(color: Theme.of(context).dividerColor.withOpacity(0.25)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  Text(
                    PriceConverter.convertPrice(order.orderAmount),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor,
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
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    isRunning ? 'track_order'.tr : 'view_details'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(context).disabledColor,
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
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: statusVisual.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusVisual.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusVisual.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            statusVisual.label,
            style: robotoMedium.copyWith(
              color: statusVisual.textColor,
              fontSize: Dimensions.fontSizeDefault,
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
          vertical: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ResponsiveHelper.isDesktop(context)
                  ? Dimensions.radiusDefault
                  : 24),
              topRight: Radius.circular(ResponsiveHelper.isDesktop(context)
                  ? Dimensions.radiusDefault
                  : 24)),
          boxShadow: ResponsiveHelper.isDesktop(context)
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]),
      child: GetBuilder<StoreController>(builder: (storeController) {
        if (Get.find<StoreController>().store != null &&
            !Get.find<StoreController>().store!.freeDelivery! &&
            Get.find<SplashController>().configModel!.freeDeliveryOver !=
                null) {
          percentage = cartController.subTotal /
              Get.find<SplashController>().configModel!.freeDeliveryOver!;
        }
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (storeController.store != null &&
                      !storeController.store!.freeDelivery! &&
                      Get.find<SplashController>()
                              .configModel!
                              .freeDeliveryOver !=
                          null &&
                      percentage < 1)
                  ? Column(children: [
                      Row(children: [
                        Image.asset(Images.percentTag,
                            height: 20,
                            width: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          PriceConverter.convertPrice(
                              Get.find<SplashController>()
                                      .configModel!
                                      .freeDeliveryOver! -
                                  cartController.subTotal),
                          style: robotoMedium.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text('more_for_free_delivery'.tr,
                            style: robotoMedium.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          value: percentage,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ])
                  : const SizedBox(),
              ResponsiveHelper.isDesktop(context)
                  ? Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant)
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('subtotal'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).colorScheme.onSurface)),
                    PriceConverter.convertAnimationPrice(
                        cartController.subTotal,
                        textStyle: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
              CustomButton(
                  buttonText: 'confirm_delivery_details'.tr,
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeSmall
                      : Dimensions.fontSizeLarge,
                  isBold: true,
                  radius: 16, // Modern M3 completely rounded button feel
                  onPressed: () {
                    bool isScheduleOrder = cartController.cartList.isNotEmpty &&
                        cartController.cartList.first.item != null &&
                        (cartController.cartList.first.item!.scheduleOrder ?? false);

                    if (!isScheduleOrder && availableList.contains(false)) {
                      showCustomSnackBar('one_or_more_product_unavailable'.tr);
                    } else {
                      if (Get.find<SplashController>().module == null &&
                          cartController.cartList.isNotEmpty &&
                          cartController.cartList.first.item != null &&
                          Get.find<SplashController>().moduleList != null) {
                        int i = 0;
                        for (i = 0;
                            i < Get.find<SplashController>().moduleList!.length;
                            i++) {
                          if (cartController.cartList[0].item!.moduleId ==
                              Get.find<SplashController>().moduleList![i].id) {
                            break;
                          }
                        }
                        if (i < Get.find<SplashController>().moduleList!.length) {
                          Get.find<SplashController>().setModule(
                              Get.find<SplashController>().moduleList![i]);
                          HomeScreen.loadData(true);
                        }
                      }
                      Get.find<CouponController>().removeCouponData(false);

                      Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                    }
                  }),
            ],
          ),
        );
      }),
    );
  }
}
