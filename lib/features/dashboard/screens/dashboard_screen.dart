import 'dart:async';
import 'dart:io';

import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_dialog.dart';
import 'package:Oxygen_Mart/common/widgets/login_suggestion_bottomsheet.dart';
import 'package:Oxygen_Mart/features/ai_chat_bot/widgets/ai_chat_bot_floating_button_widget.dart';
import 'package:Oxygen_Mart/features/address/screens/address_screen.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/screens/cart_screen.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/parcel_bottom_sheet_widget.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/menu/screens/menu_screen.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/deep_link_service.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/features/category/screens/category_screen.dart';
import 'package:Oxygen_Mart/features/favourite/screens/favourite_screen.dart';
import 'package:Oxygen_Mart/features/parcel/screens/parcel_category_screen.dart';
import '../widgets/running_order_view_widget.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  final int initialCartTab;
  const DashboardScreen(
      {super.key,
      required this.pageIndex,
      this.fromSplash = false,
      this.initialCartTab = 0});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();

    _showRegistrationSuccessBottomSheet();

    if (_isLogin) {
      if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 &&
          Get.find<AuthController>().getEarningPint().isNotEmpty &&
          !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(
            const Duration(seconds: 1),
            () => showAnimatedDialog(
                Get.context!, const CongratulationDialogue()));
      }
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    } else {
      _suggestLoginBottomSheet();
    }

    final splashController = Get.find<SplashController>();
    final bool hasModule = splashController.module != null;
    final bool isParcel = hasModule &&
        (splashController.configModel?.moduleConfig?.module?.isParcel ?? false);

    _screens = hasModule
        ? [
            const HomeScreen(),
            isParcel
                ? const ParcelCategoryScreen()
                : const CategoryScreen(fromNav: true),
            isParcel
                ? const AddressScreen(fromDashboard: true)
                : const CartScreen(fromNav: true),
            isParcel
                ? const SizedBox()
                : const FavouriteScreen(),
            const MenuScreen(),
          ]
        : [
            const HomeScreen(),
            const CartScreen(fromNav: true),
            const FavouriteScreen(),
            const MenuScreen(),
          ];

    _pageIndex = widget.pageIndex >= _screens.length ? 0 : widget.pageIndex;
    Get.find<CartController>()
        .setSelectedFlowTab(widget.initialCartTab, notify: false);

    _pageController = PageController(initialPage: _pageIndex);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet =
        Get.find<HomeController>().getRegistrationSuccessfulSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context)
            ? Get.dialog(
                    const Dialog(child: StoreRegistrationSuccessBottomSheet()))
                .then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              })
            : showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const StoreRegistrationSuccessBottomSheet(),
              ).then((value) {
                Get.find<HomeController>()
                    .saveRegistrationSuccessfulSharedPref(false);
                Get.find<HomeController>()
                    .saveIsStoreRegistrationSharedPref(false);
                setState(() {});
              });
      });
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheetWidget(),
        ).then((value) {
          Get.find<LocationController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  Future<void> _suggestLoginBottomSheet() async {
    final bool hasPendingDeepLink = Get.isRegistered<DeepLinkService>() &&
        Get.find<DeepLinkService>().pendingProductId != null;
    if (hasPendingDeepLink) {
      return;
    }
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final bool isItemDetails = Get.currentRoute.contains(RouteHelper.itemDetails);
      final bool stillPending = Get.isRegistered<DeepLinkService>() &&
          Get.find<DeepLinkService>().pendingProductId != null;
      if (isItemDetails || stillPending) {
        return;
      }
      ResponsiveHelper.isDesktop(Get.context)
          ? Get.dialog(const Dialog(child: LoginSuggestionBottomSheet()))
          : showModalBottomSheet(
              context: Get.context!,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (con) => const LoginSuggestionBottomSheet(),
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;
    final double bottomInset = mediaQuery.padding.bottom;
    final double dashboardNavBarHeight = GetPlatform.isIOS ? 96 : 82;
    final double expandedRunningOrderBottomSpacing =
      GetPlatform.isIOS ? 10 : 8;
    final double compactRunningOrderBottomOffset =
      dashboardNavBarHeight + bottomInset + 8;
    bool keyboardVisible = mediaQuery.viewInsets.bottom != 0;
    return GetBuilder<SplashController>(builder: (splashController) {
      final bool hasModule = splashController.module != null;
      final bool isParcel = hasModule &&
          (splashController.configModel?.moduleConfig?.module?.isParcel ??
              false);

      _screens = hasModule
          ? [
              const HomeScreen(),
              isParcel
                  ? const ParcelCategoryScreen()
                  : const CategoryScreen(fromNav: true),
              isParcel
                  ? const AddressScreen(fromDashboard: true)
                  : const CartScreen(fromNav: true),
              isParcel
                  ? const SizedBox()
                  : const FavouriteScreen(),
              const MenuScreen(),
            ]
          : [
              const HomeScreen(),
              const CartScreen(fromNav: true),
              const FavouriteScreen(),
              const MenuScreen(),
            ];

      if (_pageIndex >= _screens.length) {
        _pageIndex = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController?.hasClients == true) {
            _pageController?.jumpToPage(0);
          }
        });
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          final bool hasModuleLanding = !ResponsiveHelper.isDesktop(context)
              && splashController.module != null && splashController.configModel!.module == null
              && splashController.moduleList != null && splashController.moduleList!.length != 1;

          if (_pageIndex != 0) {
            _setPage(0);
          } else if (splashController.selectedModuleIndex != 0 && hasModuleLanding) {
            splashController.selectHomeModule();
          } else {
            if (hasModuleLanding) {
              splashController.removeModule();
              Get.find<StoreController>().resetStoreData();
            } else {
              if (_canExit) {
                if (GetPlatform.isAndroid) {
                  SystemNavigator.pop();
                } else if (GetPlatform.isIOS) {
                  exit(0);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('back_press_again_to_exit'.tr,
                      style: const TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                ));
                _canExit = true;
                Timer(const Duration(seconds: 2), () {
                  _canExit = false;
                });
              }
            }
          }
        },
        child: GetBuilder<OrderController>(builder: (orderController) {
          List<OrderModel> runningOrder =
              orderController.runningOrderModel != null
                  ? orderController.runningOrderModel!.orders!
                  : [];

          List<OrderModel> reversOrder = List.from(runningOrder.reversed);
          bool showRunningOrderWidget = !ResponsiveHelper.isDesktop(context) &&
            _isLogin &&
            orderController.runningOrderModel != null &&
            orderController.runningOrderModel!.orders!.isNotEmpty &&
            orderController.showBottomSheet &&
            !(widget.fromSplash &&
              Get.find<LocationController>().showLocationSuggestion &&
              active);
          bool showCompactRunningOrderBanner =
            showRunningOrderWidget && orderController.showOneOrder;
          bool showExpandedRunningOrderSheet =
            showRunningOrderWidget && !orderController.showOneOrder;

          return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: _pageIndex == 0 ? GetBuilder<SplashController>(builder: (splashController) {
              return _HomeFloatingActionButton(splashController: splashController);
            }) : null,
            body: ExpandableBottomSheet(
              background: Stack(children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _screens.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _screens[index];
                  },
                ),
                ResponsiveHelper.isDesktop(context) || keyboardVisible
                    ? const SizedBox()
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Container(
                              width: size.width,
                              height: dashboardNavBarHeight - 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.10),
                                      blurRadius: 24,
                                      spreadRadius: 0,
                                      offset: const Offset(0, -4)),
                                  BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: size.width,
                                  height: dashboardNavBarHeight,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: hasModule
                                        ? [
                                            BottomNavItemWidget(
                                              title: 'home'.tr,
                                              selectedIcon: Images.homeSelect,
                                              unSelectedIcon: Images.homeUnselect,
                                              isSelected: _pageIndex == 0,
                                              onTap: () => _setPage(0),
                                            ),
                                            BottomNavItemWidget(
                                              title: 'categories'.tr,
                                              iconData: Icons.grid_view_rounded,
                                              isSelected: _pageIndex == 1,
                                              onTap: () => _setPage(1),
                                            ),
                                            BottomNavItemWidget(
                                              title: isParcel
                                                  ? 'address'.tr
                                                  : 'cart'.tr,
                                              selectedIcon: isParcel
                                                  ? Images.addressSelect
                                                  : Images.shoppingCart,
                                              unSelectedIcon: isParcel
                                                  ? Images.addressUnselect
                                                  : Images.shoppingCart,
                                              isSelected: _pageIndex == 2,
                                              onTap: () {
                                                if (isParcel) {
                                                  _setPage(2);
                                                } else {
                                                  Get.find<CartController>()
                                                      .setSelectedFlowTab(0);
                                                  _setPage(2);
                                                }
                                              },
                                            ),
                                            BottomNavItemWidget(
                                              title: isParcel
                                                  ? 'cart'.tr
                                                  : 'favourite'.tr,
                                              selectedIcon: isParcel
                                                  ? Images.shoppingCart
                                                  : Images.favouriteSelect,
                                              unSelectedIcon: isParcel
                                                  ? Images.shoppingCart
                                                  : Images.favouriteUnselect,
                                              isSelected: _pageIndex == 3,
                                              onTap: () {
                                                if (isParcel) {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder: (con) =>
                                                        ParcelBottomSheetWidget(
                                                            parcelCategoryList: Get
                                                                .find<
                                                                    ParcelController>()
                                                                .parcelCategoryList),
                                                  );
                                                } else {
                                                  _setPage(3);
                                                }
                                              },
                                            ),
                                            BottomNavItemWidget(
                                              title: isParcel
                                                  ? 'orders'.tr
                                                  : 'profile'.tr,
                                              selectedIcon: isParcel
                                                  ? Images.orderSelect
                                                  : Images.profile,
                                              unSelectedIcon: isParcel
                                                  ? Images.orderUnselect
                                                  : Images.profile,
                                              isSelected: _pageIndex == 4,
                                              onTap: () {
                                                if (isParcel) {
                                                  _setPage(4);
                                                } else {
                                                  _setPage(4);
                                                }
                                              },
                                            ),
                                          ]
                                        : [
                                            BottomNavItemWidget(
                                              title: 'home'.tr,
                                              selectedIcon: Images.homeSelect,
                                              unSelectedIcon: Images.homeUnselect,
                                              isSelected: _pageIndex == 0,
                                              onTap: () => _setPage(0),
                                            ),
                                            BottomNavItemWidget(
                                              title: 'cart'.tr,
                                              selectedIcon: Images.shoppingCart,
                                              unSelectedIcon: Images.shoppingCart,
                                              isSelected: _pageIndex == 1,
                                              onTap: () {
                                                Get.find<CartController>()
                                                    .setSelectedFlowTab(0);
                                                _setPage(1);
                                              },
                                            ),
                                            BottomNavItemWidget(
                                              title: 'favourite'.tr,
                                              selectedIcon: Images.favouriteSelect,
                                              unSelectedIcon: Images.favouriteUnselect,
                                              isSelected: _pageIndex == 2,
                                              onTap: () => _setPage(2),
                                            ),
                                            BottomNavItemWidget(
                                              title: 'profile'.tr,
                                              selectedIcon: Images.profile,
                                              unSelectedIcon: Images.profile,
                                              isSelected: _pageIndex == 3,
                                              onTap: () => _setPage(3),
                                            ),
                                          ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                if (showCompactRunningOrderBanner && !keyboardVisible)
                  Positioned(
                    left: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeSmall,
                    bottom: compactRunningOrderBottomOffset,
                    child: Dismissible(
                      key: const ValueKey('compact-running-order-banner'),
                      onDismissed: (direction) {
                        if (orderController.showBottomSheet) {
                          orderController.showRunningOrders();
                        }
                      },
                      child: RunningOrderViewWidget(
                        reversOrder: reversOrder,
                        onOrderTap: () {
                          if (Get.find<SplashController>().module != null &&
                              (Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig
                                      ?.module
                                      ?.isParcel ??
                                  false)) {
                            _setPage(4);
                          } else {
                            Get.find<CartController>().setSelectedFlowTab(1);
                            final bool currentHasModule = Get.find<SplashController>().module != null;
                            _setPage(currentHasModule ? 2 : 1);
                          }
                          if (orderController.showBottomSheet) {
                            orderController.showRunningOrders();
                          }
                        },
                      ),
                    ),
                  ),
              ]),
              persistentContentHeight: (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active) || !showExpandedRunningOrderSheet // 👈 ضفنا الشرط ده هنا
    ? 0
    : GetPlatform.isIOS
        ? 100
        : 100,
              onIsContractedCallback: () {
                if (!orderController.showOneOrder) {
                  orderController.showOrders();
                }
              },
              onIsExtendedCallback: () {
                if (orderController.showOneOrder) {
                  orderController.showOrders();
                }
              },
              enableToggle: true,
              expandableContent: (widget.fromSplash &&
                      Get.find<LocationController>().showLocationSuggestion &&
                      active &&
                      !ResponsiveHelper.isDesktop(context))
                  ? const SizedBox()
                  : !showExpandedRunningOrderSheet
                      ? const SizedBox()
                      : Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            if (orderController.showBottomSheet) {
                              orderController.showRunningOrders();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: expandedRunningOrderBottomSpacing,
                            ),
                            child: RunningOrderViewWidget(
                                reversOrder: reversOrder,
                                onOrderTap: () {
                                  if (Get.find<SplashController>().module !=
                                          null &&
                                      (Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig
                                              ?.module
                                              ?.isParcel ??
                                          false)) {
                                    _setPage(4);
                                  } else {
                                    Get.find<CartController>()
                                        .setSelectedFlowTab(1);
                                    final bool currentHasModule = Get.find<SplashController>().module != null;
                                    _setPage(currentHasModule ? 2 : 1);
                                  }
                                  if (orderController.showBottomSheet) {
                                    orderController.showRunningOrders();
                                  }
                                }),
                          ),
                        ),
            ),
          );
        }),
      );
    });
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 3,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}

class _HomeFloatingActionButton extends StatelessWidget {
  final SplashController splashController;

  const _HomeFloatingActionButton({required this.splashController});

  @override
  Widget build(BuildContext context) {
    final String? moduleType = splashController.module?.moduleType?.toString();
    const Set<String> aiChatModules = {
      AppConstants.food, AppConstants.grocery, AppConstants.ecommerce, AppConstants.pharmacy, AppConstants.service,
    };
    final bool showAiChat = (splashController.configModel?.aiChatStatus ?? false) &&
        splashController.module != null &&
        moduleType != null &&
        aiChatModules.contains(moduleType);

    if (!showAiChat) return const SizedBox.shrink();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: 70.0, right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AiChatBotFloatingButtonWidget(),
        ],
      ),
    );
  }
}
