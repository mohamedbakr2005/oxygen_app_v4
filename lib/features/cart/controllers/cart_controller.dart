import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:Oxygen_Mart/api/api_checker.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';

import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/all_carts_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/online_cart_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/services/cart_service_interface.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/module_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/bundle_amount_helper.dart';

class CartController extends GetxController implements GetxService {
  int _selectedFlowTab = 0;
  int get selectedFlowTab => _selectedFlowTab;

  void setSelectedFlowTab(int index, {bool notify = true}) {
    if (_selectedFlowTab == index) return;
    _selectedFlowTab = index;
    if (notify) update();
  }
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});

  final Set<int> _addingItemIds = <int>{};
  Set<int> get addingItemIds => _addingItemIds;
  bool isItemAdding(int? itemId) => itemId != null && _addingItemIds.contains(itemId);

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  double _addOns = 0;
  double get addOns => _addOns;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];
  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  CartModel? get firstItemCart {
    for (final CartModel cart in _cartList) {
      if (cart.item != null) {
        return cart;
      }
    }
    return _cartList.isNotEmpty ? _cartList.first : null;
  }

  Item? get firstCartItem => firstItemCart?.item;

  int? get cartStoreId {
    final int? id = firstCartItem?.storeId;
    if (id != null) {
      return id;
    }
    for (final CartModel cart in _cartList) {
      if (cart.storeId != null) {
        return cart.storeId;
      }
    }
    return null;
  }

  int? get cartModuleId => firstCartItem?.moduleId ?? ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id;

  String? get cartModuleType => firstCartItem?.moduleType ?? ModuleHelper.getModule()?.moduleType ?? ModuleHelper.getCacheModule()?.moduleType;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _needExtraPackage = false;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  int? _directAddCartItemIndex = -1;
  int? get directAddCartItemIndex => _directAddCartItemIndex;

  List<AllCartsModel>? _allCartsGroups;
  List<AllCartsModel>? get allCartsGroups => _allCartsGroups;

  // Total number of cart line-items across every module/store (the global cart count).
  int get allCartsItemCount {
    if (_allCartsGroups == null) return 0;
    int count = 0;
    for (final AllCartsModel group in _allCartsGroups!) {
      count += group.carts?.length ?? 0;
    }
    return count;
  }

  bool _isAllCartsLoading = false;
  bool get isAllCartsLoading => _isAllCartsLoading;

  // Incremented on every getAllCarts() call. After the await, any call whose
  // captured token no longer matches is stale (a newer call overtook it) and
  // must be discarded to prevent a slower older response from overwriting the
  // result of a faster newer one.
  int _allCartsGeneration = 0;

  // Set while CartScreen is visible so getAllCarts() never floods _cartList with mixed-store items.
  int? _activeCartScreenStoreId;
  int? get activeCartScreenStoreId => _activeCartScreenStoreId;

  void setActiveCartScreen(int? storeId) => _activeCartScreenStoreId = storeId;

  void clearActiveCartScreen() {
    _activeCartScreenStoreId = null;
    getAllCarts(notify: false);
  }

  void setDirectlyAddToCartIndex(int? index) {
    _directAddCartItemIndex = index;
  }

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if(willUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}) {
    _notAvailableIndex = cartServiceInterface.availableSelectedIndex(_notAvailableIndex, index);
    if(willUpdate) {
      update();
    }
  }

  void updateCutlery({bool willUpdate = true}){
    _addCutlery = !_addCutlery;
    if(willUpdate) {
      update();
    }
  }

  Future<void> forcefullySetModule(int moduleId) async {
    ModuleModel? module = cartServiceInterface.forcefullySetModule(Get.find<SplashController>().module, Get.find<SplashController>().moduleList, moduleId);
    if(module != null) {
      await Get.find<SplashController>().setModule(module);
      HomeScreen.loadData(true);
    }
  }

  double _bundleDiscount = 0;
  double get bundleDiscount => _bundleDiscount;

  double calculationCart() {
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _bundleDiscount = 0;
    _addOns = 0;
    _variationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;
    for (var cartModel in cartList) {

      if(cartModel.isBogoBundle) {
        _addOnsList.add(<AddOns>[]);
        _availableList.add(cartModel.bogoDetails?.isAvailable ?? true);
        _itemPrice = _itemPrice + (cartModel.bogoDetails?.totalPrice ?? (cartModel.price ?? 0) * (cartModel.quantity ?? 1));
        if(cartModel.bogoDetails?.isHappyHour ?? false) {
          _itemDiscountPrice = _itemDiscountPrice + (cartModel.bogoDetails?.totalDiscountAmount ?? 0);
        }
        continue;
      }

      if(cartModel.isBundle) {
        _addOnsList.add(<AddOns>[]);
        final BundleCartDetails? bundleDetails = cartModel.bundleDetails;
        _availableList.add(bundleDetails?.isAvailable ?? true);
        if(bundleDetails != null) {
          final double saving = BundleAmountHelper.savingOf(bundleDetails);
          if(saving > 0) {
            _itemPrice = _itemPrice + bundleDetails.totalBasePrice;
            _itemDiscountPrice = _itemDiscountPrice + saving;
            _bundleDiscount = _bundleDiscount + saving;
          } else {
            _itemPrice = _itemPrice + bundleDetails.totalFinalPrice;
          }
        }
        continue;
      }

      if(cartModel.item == null) {
        continue;
      }

      isFoodVariation = ModuleHelper.getModuleConfig(cartModel.item!.moduleType).newVariation!;
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(DateConverter.isAvailable(cartModel.item!.availableTimeStarts, cartModel.item!.availableTimeEnds));

      _addOns = cartServiceInterface.calculateAddonPrice(_addOns, addOnList, cartModel);

      _variationPrice = cartServiceInterface.calculateVariationPrice(isFoodVariation, cartModel, discount, discountType, _variationPrice);

      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(isFoodVariation, cartModel, variationWithoutDiscountPrice);
      haveVariation = cartServiceInterface.checkVariation(isFoodVariation, cartModel);

      double price = haveVariation ? variationWithoutDiscountPrice : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation ? (variationWithoutDiscountPrice - _variationPrice)
          : (price - (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!));

      _itemPrice = _itemPrice + price;
      _itemDiscountPrice = _itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    if(isFoodVariation){
      _itemDiscountPrice = _itemDiscountPrice + (variationWithoutDiscountPrice - _variationPrice);
      _variationPrice =  variationWithoutDiscountPrice;
      _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns + _variationPrice;
    } else {
      _subTotal = (_itemPrice - _itemDiscountPrice);
    }

    return _subTotal;
  }

  double calculateGCartSubTotal(List<CartModel> cartList) {
    double itemPrice = 0;
    double itemDiscountPrice = 0;
    double addOns = 0;
    double subTotal = 0;
    double thisVariationPrice = 0;
    bool isFoodVariation = false;
    double variationWithoutDiscountPrice = 0;
    bool haveVariation = false;
    for (var cartModel in cartList) {

      if(cartModel.isBundle) {
        itemPrice = itemPrice + (cartModel.bundleDetails?.totalFinalPrice ?? (cartModel.price ?? 0) * (cartModel.quantity ?? 1));
        continue;
      }
      if(cartModel.isBogoBundle) {
        itemPrice = itemPrice + (cartModel.bogoDetails?.totalPrice ?? (cartModel.price ?? 0) * (cartModel.quantity ?? 1));
        if(cartModel.bogoDetails?.isHappyHour ?? false) {
          itemDiscountPrice = itemDiscountPrice + (cartModel.bogoDetails?.totalDiscountAmount ?? 0);
        }
        continue;
      }

      if(cartModel.item == null) {
        continue;
      }

      isFoodVariation = ModuleHelper.getModuleConfig(cartModel.item!.moduleType).newVariation!;
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      addOns = cartServiceInterface.calculateAddonPrice(addOns, addOnList, cartModel);

      thisVariationPrice = cartServiceInterface.calculateVariationPrice(isFoodVariation, cartModel, discount, discountType, thisVariationPrice);

      variationWithoutDiscountPrice = cartServiceInterface.calculateVariationWithoutDiscountPrice(isFoodVariation, cartModel, variationWithoutDiscountPrice);
      haveVariation = cartServiceInterface.checkVariation(isFoodVariation, cartModel);

      double price = haveVariation ? variationWithoutDiscountPrice : (cartModel.item!.price! * cartModel.quantity!);
      double discountPrice = haveVariation ? (variationWithoutDiscountPrice - thisVariationPrice)
          : (price - (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!));

      itemPrice = itemPrice + price;
      itemDiscountPrice = itemDiscountPrice + discountPrice;

      haveVariation = false;
    }
    if(isFoodVariation){
      itemDiscountPrice = itemDiscountPrice + (variationWithoutDiscountPrice - thisVariationPrice);
      thisVariationPrice =  variationWithoutDiscountPrice;
      subTotal = (itemPrice - itemDiscountPrice) + addOns + thisVariationPrice;
    } else {
      subTotal = (itemPrice - itemDiscountPrice);
    }

    return subTotal;
  }

  final Map<int, List<CartModel>> _foldedCartsByStore = <int, List<CartModel>>{};

  List<CartModel> localCartsOfGroup(AllCartsModel group) {
    final int? storeId = group.store?.id;
    final List<CartModel>? folded = storeId != null ? _foldedCartsByStore[storeId] : null;
    if(folded != null) {
      return folded;
    }
    return cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: group.onlineCarts ?? <OnlineCartModel>[]);
  }

  Future<void> addToCart(CartModel cartModel, int? index) async {
    if(index != null && index != -1) {
      _cartList.replaceRange(index, index+1, [cartModel]);
    }else {
      _cartList.add(cartModel);
    }
    Get.find<ItemController>().setExistInCart(cartModel.item, null, notify: true);
    await cartServiceInterface.addSharedPrefCartList(_cartList);

    if (cartModel.item != null && (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn())) {
      List<int?> addOnIdList = [];
      List<int?> addOnQtyList = [];
      if (cartModel.addOnIds != null) {
        for (var addOn in cartModel.addOnIds!) {
          addOnIdList.add(addOn.id);
          addOnQtyList.add(addOn.quantity);
        }
      }
      OnlineCart onlineCart = OnlineCart(
        cartModel.id,
        cartModel.item!.id,
        cartModel.isCampaign == true ? cartModel.item!.id : null,
        (cartModel.discountedPrice ?? cartModel.price ?? 0).toString(),
        '',
        cartModel.variation,
        null,
        cartModel.quantity,
        addOnIdList,
        cartModel.addOns,
        addOnQtyList,
        'Item',
        storeId: cartModel.item?.storeId,
      );
      await addToCartOnline(onlineCart, storeId: cartModel.item?.storeId, trackEvent: false);
    }

    try {
      FirebaseAnalytics.instance.logAddToCart(
        items: [
          AnalyticsEventItem(
            itemId: cartModel.item?.id?.toString() ?? '',
            itemName: cartModel.item?.name ?? '',
            price: (cartModel.discountedPrice ?? cartModel.price ?? cartModel.item?.price ?? 0).toDouble(),
            quantity: cartModel.quantity ?? 1,
          )
        ],
      );
    } catch (_) {}
    try {
      final double price = (cartModel.discountedPrice ?? cartModel.price ?? cartModel.item?.price ?? 0).toDouble();
      final int qty = cartModel.quantity ?? 1;
      final String itemId = cartModel.item?.id?.toString() ?? 'unknown';
      final String itemName = cartModel.item?.name ?? 'unknown';

      Get.find<MetaAnalyticsService>().addToCart(
        contentId: itemId,
        contentName: itemName,
        quantity: qty,
        price: price,
        currency: 'EGP',
        value: price * qty,
        contentIds: [itemId],
        contents: [
          {
            'id': itemId,
            'quantity': qty,
            'item_price': price,
          }
        ],
      );
    } catch (_) {}
    calculationCart();
    update();
  }

  int? getCartId(int cartIndex) {
    return cartServiceInterface.getCartId(cartIndex, _cartList);
  }

  Future<void> setQuantity(bool isIncrement, int cartIndex, int? stock, int ? quantityLimit) async {
    if (_isLoading) return;

    _isLoading = true;
    update();

    int oldQuantity = _cartList[cartIndex].quantity!;
    _cartList[cartIndex].quantity = cartServiceInterface.decideItemQuantity(isIncrement, _cartList, cartIndex, stock, quantityLimit, Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!);

    if (oldQuantity == _cartList[cartIndex].quantity) {
      _isLoading = false;
      update();
      return;
    }

    double discountedPrice = await cartServiceInterface.calculateDiscountedPrice(_cartList[cartIndex], _cartList[cartIndex].quantity!, ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!);
    if(ModuleHelper.getModuleConfig(_cartList[cartIndex].item!.moduleType).newVariation!) {
     await Get.find<ItemController>().setExistInCart(_cartList[cartIndex].item, null, notify: true);
    }

    await updateCartQuantityOnline(_cartList[cartIndex], discountedPrice, _cartList[cartIndex].quantity!,
      storeId: _cartList[cartIndex].item?.storeId);

  }

  // ── Debounced cart-quantity sync ───────────────────────────────────────────
  // Tapping +/- updates the quantity (and totals) in-memory immediately so the
  // UI stays responsive, then schedules a single backend sync that fires only
  // after the user has stopped tapping for [_quantitySyncDelay]. Rapid taps
  // collapse into one API call instead of one-per-tap, and the buttons are never
  // blocked while a previous request is in flight. Keyed by cart id so several
  // items can be adjusted independently.
  static const Duration _quantitySyncDelay = Duration(seconds: 2);
  final Map<int, Timer> _quantitySyncTimers = {};

  void changeQuantity(bool isIncrement, int cartIndex, int? stock, int? quantityLimit) {
    final int oldQuantity = _cartList[cartIndex].quantity!;
    final int newQuantity = cartServiceInterface.decideItemQuantity(
      isIncrement, _cartList, cartIndex, stock, quantityLimit,
      Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!,
    );
    // Hit a stock / limit boundary — nothing changed (a snackbar was shown).
    if (oldQuantity == newQuantity) return;

    _cartList[cartIndex].quantity = newQuantity;
    calculationCart();
    update();

    final int cartId = _cartList[cartIndex].id!;
    _quantitySyncTimers[cartId]?.cancel();
    _quantitySyncTimers[cartId] = Timer(_quantitySyncDelay, () => _syncQuantityToServer(cartId));
  }

  Future<void> _syncQuantityToServer(int cartId) async {
    _quantitySyncTimers.remove(cartId);
    final int index = _cartList.indexWhere((CartModel c) => c.id == cartId);
    if (index == -1) return;

    final CartModel cart = _cartList[index];
    final bool newVariation = ModuleHelper.getModuleConfig(cart.item!.moduleType).newVariation!;
    final double discountedPrice = await cartServiceInterface.calculateDiscountedPrice(cart, cart.quantity!, newVariation);
    if (newVariation) {
      await Get.find<ItemController>().setExistInCart(cart.item, null, notify: true);
    }
    await updateCartQuantityOnline(cart, discountedPrice, cart.quantity!, storeId: cart.item?.storeId);
  }

  Future<void> removeFromCart(int index, {Item? item}) async {
    int cartId = _cartList[index].id!;
    int? storeId = _cartList[index].item?.storeId;
    _cartList.removeAt(index);
    update();
    Get.find<ItemController>().cartIndexSet();
        try {
      FirebaseAnalytics.instance.logRemoveFromCart(
        items: [
          AnalyticsEventItem(
            itemId: item?.id?.toString() ?? '',
            itemName: item?.name ?? '',
          )
        ],
      );
    } catch (_) {}
    try {
      Get.find<MetaAnalyticsService>().removeFromCart(
        contentId: item?.id?.toString() ?? '',
        contentName: item?.name ?? '',
      );
    } catch (_) {}
    await removeCartItemOnline(cartId, item: item, storeId: storeId);
    if(Get.find<ItemController>().item != null) {
      Get.find<ItemController>().cartIndexSet();
    }

  }

  Future<void> clearCartList() async {
    final int? storeId = _cartList.isNotEmpty ? _cartList[0].item?.storeId : null;
    _cartList = [];
    if(storeId != null) {
      _allCartsGroups?.removeWhere((AllCartsModel g) => g.store?.id == storeId);
    }
    update();
    if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && (ModuleHelper.getModule() != null || ModuleHelper.getCacheModule() != null)) {
      if(storeId != null){
        removeStoreCart(storeId);
      }
    }
  }

  int isExistInCart(int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    return cartServiceInterface.isExistInCart(_cartList, itemID, variationType, isUpdate, cartIndex);
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    if (cartServiceInterface.existAnotherStoreItem(storeID, moduleId, _cartList)) {
      return true;
    }
    // Also check the global carts list — _cartList may be empty or stale
    if (_allCartsGroups != null) {
      for (final AllCartsModel group in _allCartsGroups!) {
        if (group.store?.id != storeID && (group.carts?.isNotEmpty ?? false)) {
          return true;
        }
      }
    }
    return false;
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  Future<bool> addToCartOnline(OnlineCart cart, {int? storeId, bool trackEvent = true}) async {
    final int? addingId = cart.itemId ?? cart.itemCampaignId;
    if (addingId != null && _addingItemIds.contains(addingId)) {
      return false;
    }
    if (addingId != null) {
      _addingItemIds.add(addingId);
    }
    final int beforeCount = _cartList.length;
    _isLoading = true;
    bool success = false;
    update();
    try {
    storeId ??= cart.storeId;
    if(storeId == null && Get.isRegistered<ItemController>()) {
      storeId = Get.find<ItemController>().item?.storeId;
    }
    if(storeId == null && _cartList.isNotEmpty) {
      storeId = _cartList.first.item?.storeId;
    }
    List<OnlineCartModel>? onlineCartList = await cartServiceInterface.addToCartOnline(cart, storeId: storeId);
    if(onlineCartList != null) {
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      calculationCart();
      success = true;
      await getAllCarts(notify: false);

      if (trackEvent) {
        try {
          final addedCartModel = _cartList.firstWhereOrNull((c) => c.item?.id == (cart.itemId ?? cart.itemCampaignId));
          final item = addedCartModel?.item;
          final double price = (addedCartModel?.discountedPrice ?? addedCartModel?.price ?? item?.price ?? 0.0).toDouble();
          final int qty = cart.quantity ?? 1;
          final String itemIdStr = (cart.itemId ?? cart.itemCampaignId)?.toString() ?? item?.id?.toString() ?? 'unknown';
          final String itemName = item?.name ?? 'unknown';

          Get.find<MetaAnalyticsService>().addToCart(
            contentId: itemIdStr,
            contentName: itemName,
            quantity: qty,
            price: price,
            currency: 'EGP',
            value: price * qty,
            contentIds: [itemIdStr],
            contents: [
              {
                'id': itemIdStr,
                'quantity': qty,
                'item_price': price,
              }
            ],
          );
        } catch (_) {}
      }
    }
    _isLoading = false;
    update();

    _logCartDiagnostic(
      action: 'ADD_TO_CART',
      storeId: storeId,
      productId: cart.itemId,
      quantity: cart.quantity,
      apiResult: success ? 'SUCCESS' : 'FAILED',
      stateBeforeCount: beforeCount,
      stateAfterCount: _cartList.length,
    );

    return success;
    } finally {
      if (addingId != null) {
        _addingItemIds.remove(addingId);
      }
      _isLoading = false;
      update();
    }
  }

  Future<bool> updateCartOnline(OnlineCart cart, {int? storeId}) async {
    final int beforeCount = _cartList.length;
    _isLoading = true;
    bool success = false;
    update();
    storeId ??= cart.storeId;
    if(storeId == null && Get.isRegistered<ItemController>()) {
      storeId = Get.find<ItemController>().item?.storeId;
    }
    if(storeId == null && _cartList.isNotEmpty) {
      storeId = _cartList.first.item?.storeId;
    }
    List<OnlineCartModel>? onlineCartList = await cartServiceInterface.updateCartOnline(cart, storeId: storeId);
    if(onlineCartList != null) {
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList));
      calculationCart();
      success = true;
      await getAllCarts(notify: false);
    }
    _isLoading = false;
    update();

    _logCartDiagnostic(
      action: 'UPDATE_CART',
      storeId: storeId,
      productId: cart.itemId,
      quantity: cart.quantity,
      apiResult: success ? 'SUCCESS' : 'FAILED',
      stateBeforeCount: beforeCount,
      stateAfterCount: _cartList.length,
    );

    return success;
  }

  Future<void> updateCartQuantityOnline(dynamic cartOrId, double price, int quantity, {int? storeId}) async {
    CartModel? cart;
    int? resolvedCartId;
    if (cartOrId is CartModel) {
      cart = cartOrId;
      resolvedCartId = cart.id;
      storeId ??= cart.storeId;
    } else if (cartOrId is int) {
      resolvedCartId = cartOrId;
      for (final c in _cartList) {
        if (c.id == resolvedCartId) {
          cart = c;
          storeId ??= c.storeId;
          break;
        }
      }
    }

    if (cart == null) {
      return;
    }

    final int beforeCount = _cartList.length;
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.updateCartQuantityOnline(cart, price, quantity, storeId: storeId);
    // Resync with the server whether the update succeeded or not: on success to
    // reflect the saved state, on failure (e.g. out of stock, or any other
    // rejection) to roll the optimistic local quantity back to the real cart
    // value. The error message itself is surfaced by the API layer.
    await getAllCarts();
    calculationCart();
    if(success) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _isLoading = false;
    update();

    _logCartDiagnostic(
      action: 'UPDATE_QUANTITY',
      storeId: storeId,
      productId: resolvedCartId,
      quantity: quantity,
      apiResult: success ? 'SUCCESS' : 'FAILED',
      stateBeforeCount: beforeCount,
      stateAfterCount: _cartList.length,
    );
  }

  Future<void> getCartDataOnline({int? storeId}) async {
    if(ModuleHelper.getModule() != null || ModuleHelper.getCacheModule() != null) {
      final int beforeCount = _cartList.length;
      _isLoading = true;
      // Schedule update after build phase completes to avoid "setState during build" error
      Future.microtask(() => update());
      List<OnlineCartModel>? onlineCartList = await cartServiceInterface.getCartDataOnline(storeId: storeId);
      // Assign atomically after the await so no concurrent getAllCarts() call can
      // write into _cartList between the clear and the fill (race that caused duplicates).
      if(onlineCartList != null) {
        _cartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: onlineCartList);
        calculationCart();
      } else {
        _cartList = [];
      }
      _isLoading = false;
      update();

      _logCartDiagnostic(
        action: 'GET_CART_ONLINE',
        storeId: storeId,
        apiResult: onlineCartList != null ? 'SUCCESS (${onlineCartList.length} items)' : 'EMPTY/FAILED',
        stateBeforeCount: beforeCount,
        stateAfterCount: _cartList.length,
      );
    }
  }

  Future<bool> removeCartItemOnline(int cartId, {Item? item, int? storeId}) async {
    final int beforeCount = _cartList.length;
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.removeCartItemOnline(cartId, storeId: storeId);
    if(success) {
      await getCartDataOnline(storeId: storeId);
      // If removing the last item emptied this store's cart, drop it from the global list too
      if(_cartList.isEmpty && storeId != null) {
        _allCartsGroups?.removeWhere((AllCartsModel g) => g.store?.id == storeId);
      }
      if(item != null) {
        Get.find<ItemController>().setExistInCart(item, null, notify: true);
      }
    }
    _isLoading = false;
    update();

    _logCartDiagnostic(
      action: 'REMOVE_ITEM',
      storeId: storeId,
      productId: cartId,
      apiResult: success ? 'SUCCESS' : 'FAILED',
      stateBeforeCount: beforeCount,
      stateAfterCount: _cartList.length,
    );

    return success;
  }

  Future<bool> clearCartOnline() async {
    final int beforeCount = _cartList.length;
    _isLoading = true;
    update();
    bool success = await cartServiceInterface.clearCartOnline();
    if(success) {
      await getAllCarts();
    }
    _isLoading = false;
    update();

    _logCartDiagnostic(
      action: 'CLEAR_CART',
      apiResult: success ? 'SUCCESS' : 'FAILED',
      stateBeforeCount: beforeCount,
      stateAfterCount: _cartList.length,
    );

    return success;
  }

  int cartQuantity(int itemId) {
    return cartServiceInterface.cartQuantity(itemId, _cartList);
  }

  String cartVariant(int itemId) {
    return cartServiceInterface.cartVariant(itemId, _cartList);
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }

  void setAllCartsLoading({bool notify = true}) {
    _isAllCartsLoading = true;
    _isLoading = true;
    if(notify) {
      update();
    }
  }

  Future<void> getAllCarts({bool notify = true}) async {
    final int generation = ++_allCartsGeneration;
    _isAllCartsLoading = true;
    _isLoading = true;
    if(notify) {
      update();
    }
    final List<AllCartsModel>? result = await cartServiceInterface.getAllCarts();
    // A newer getAllCarts() call was made while this one was in flight — discard
    // this response so it cannot overwrite fresher data with stale results.
    if(generation != _allCartsGeneration) return;
    _allCartsGroups = result;
    if(_allCartsGroups != null) {
      final int? currentModuleId = ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id;
      if(currentModuleId != null) {
        final List<OnlineCartModel> flat = <OnlineCartModel>[];
        for(AllCartsModel group in _allCartsGroups!) {
          for(OnlineCartModel om in (group.onlineCarts ?? <OnlineCartModel>[])) {
            if(om.moduleId == currentModuleId) {
              // Scope to the active cart screen store when one is open; otherwise include all.
              if(_activeCartScreenStoreId == null || group.store?.id == _activeCartScreenStoreId) {
                flat.add(om);
              }
            }
          }
        }
        // Snapshot optimistic quantities of carts still awaiting a debounced
        // sync so this refresh doesn't snap their numbers back to the (older)
        // server value while the user is still tapping.
        final Map<int, int> pendingQuantities = {};
        for (final CartModel c in _cartList) {
          if (c.id != null && c.quantity != null && _quantitySyncTimers.containsKey(c.id)) {
            pendingQuantities[c.id!] = c.quantity!;
          }
        }
        _cartList = [];
        _cartList = cartServiceInterface.formatOnlineCartToLocalCart(onlineCartModel: flat);
        if (pendingQuantities.isNotEmpty) {
          for (final CartModel c in _cartList) {
            final int? pendingQty = c.id != null ? pendingQuantities[c.id] : null;
            if (pendingQty != null) c.quantity = pendingQty;
          }
        }
        calculationCart();
      }
    }
    _isAllCartsLoading = false;
    _isLoading = false;
    update();

    _logCartDiagnostic(
      action: 'GET_ALL_CARTS',
      apiResult: result != null ? 'SUCCESS (${result.length} store groups)' : 'EMPTY/FAILED',
      stateAfterCount: _cartList.length,
    );
  }

  AllCartsModel? getCartsForStore(int storeId) {
    if (_allCartsGroups == null) return null;
    try {
      return _allCartsGroups!.firstWhere(
        (AllCartsModel g) => g.store?.id == storeId && (g.carts?.isNotEmpty ?? false),
      );
    } catch (_) {
      return null;
    }
  }

  List<AllCartsModel> getCartsForModule(int? moduleId) {
    if(moduleId == null || _allCartsGroups == null) {
      return <AllCartsModel>[];
    }
    return _allCartsGroups!.where((AllCartsModel group) {
      final List<CartModel> carts = group.carts ?? <CartModel>[];
      return carts.any((CartModel c) => c.item?.moduleId == moduleId);
    }).toList();
  }

  Future<bool> removeStoreCart(int storeId) async {
    bool success = await cartServiceInterface.removeStoreCart(storeId);
    if(success) {
      _allCartsGroups?.removeWhere((AllCartsModel g) => g.store?.id == storeId);
      _cartList.removeWhere((CartModel c) => c.item?.storeId == storeId);
      update();
    }
    return success;
  }

  void handleRealtimeCartEvent(dynamic data) {
    getCartDataOnline();
  }

  void _logCartDiagnostic({
    required String action,
    int? storeId,
    int? productId,
    int? quantity,
    String? apiResult,
    int? stateBeforeCount,
    int? stateAfterCount,
  }) {
    if (kDebugMode) {
      final bool isGuest = AuthHelper.isGuestLoggedIn();
      final bool isLogged = AuthHelper.isLoggedIn();
      final String userType = isLogged ? 'AUTHENTICATED' : (isGuest ? 'GUEST' : 'ANONYMOUS');
      final int? moduleId = ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id;
      final String? moduleSource = ModuleHelper.getModule()?.moduleType ?? ModuleHelper.getCacheModule()?.moduleType;
      final int? zoneId = AddressHelper.getUserAddressFromSharedPref()?.zoneId;

      debugPrint('══════════════ [CART DIAGNOSTIC] ══════════════');
      debugPrint('CART ACTION: $action');
      debugPrint('CURRENT USER TYPE: $userType (Logged: $isLogged, Guest: $isGuest, GuestId: ${AuthHelper.getGuestId()})');
      debugPrint('CURRENT MODULE ID: $moduleId (Source: $moduleSource)');
      debugPrint('CURRENT ZONE ID: $zoneId');
      debugPrint('CURRENT STORE ID: $storeId');
      if (productId != null) debugPrint('PRODUCT ID: $productId');
      if (quantity != null) debugPrint('QUANTITY: $quantity');
      if (apiResult != null) debugPrint('API RESULT: $apiResult');
      if (stateBeforeCount != null) debugPrint('CART STATE BEFORE: $stateBeforeCount items');
      if (stateAfterCount != null) debugPrint('CART STATE AFTER: $stateAfterCount items');
      debugPrint('CART ITEM COUNT (Total: $allCartsItemCount, CurrentModule: ${_cartList.length})');
      debugPrint('CART CONTROLLER INSTANCE: ${identityHashCode(this)}');
      debugPrint('════════════════════════════════════════════════');
    }
  }

  Future<String?> _resolveGuestId() async {
    if (AuthHelper.isLoggedIn()) {
      return null;
    }
    String guestId = AuthHelper.getGuestId();
    if (guestId.isEmpty) {
      await AuthHelper.guestLogin();
      guestId = AuthHelper.getGuestId();
    }
    return guestId.isNotEmpty ? guestId : null;
  }

  /// `POST /customer/cart/bogo/add`
  Future<bool> addBogoToCartOnline(int bogoId, int quantity, {String? contactPersonNumber, int? moduleId}) async {
    _isLoading = true;
    update();
    try {
      final String? guestId = await _resolveGuestId();
      Response response = await cartServiceInterface.addBogoToCartOnline(
        bogoId, quantity, guestId,
        contactPersonNumber: contactPersonNumber,
        moduleId: moduleId,
      );

      final bool isSuccess = ApiClient.isSuccessCode(response.statusCode);
      if(isSuccess) {
        await getAllCarts(notify: false);
      } else {
        ApiChecker.checkApi(response);
      }
      return isSuccess;
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// `POST /customer/cart/bogo/update`
  Future<void> updateBogoBundleQuantity(bool isIncrement, CartModel cart, {required int storeId}) async {
    if(!cart.isBogoBundle) return;
    await setBogoBundleQuantity(cart, (cart.quantity ?? 1) + (isIncrement ? 1 : -1), storeId: storeId);
  }

  /// Find Bogo Bundle in cart
  CartModel? findBogoBundleInCart(int? bundleId, {int? storeId}) {
    if(bundleId == null) {
      return null;
    }
    for(final AllCartsModel group in _allCartsGroups ?? const <AllCartsModel>[]) {
      final int? groupStoreId = group.store?.id;
      if(storeId != null && groupStoreId != storeId) {
        continue;
      }
      final List<CartModel> rows = (groupStoreId != null ? _foldedCartsByStore[groupStoreId] : null)
          ?? group.carts ?? const <CartModel>[];
      for(final CartModel cart in rows) {
        if(cart.isBogoBundle && cart.bogoDetails?.bundleId == bundleId) {
          return cart;
        }
      }
    }
    return null;
  }

  /// Update BOGO quantity directly
  Future<bool> setBogoBundleQuantity(CartModel cart, int quantity, {required int storeId, int? moduleId}) async {
    if(_isLoading || !cart.isBogoBundle || quantity < 1) return false;

    _isLoading = true;
    update();
    try {
      final String? guestId = await _resolveGuestId();
      Response response = await cartServiceInterface.updateBogoBundleQuantityOnline(
        cart.bogoDetails!.bogoGroupId, quantity, guestId,
        moduleId: moduleId,
      );
      final bool isSuccess = ApiClient.isSuccessCode(response.statusCode);
      if(isSuccess) {
        await getAllCarts(notify: false);
      } else {
        ApiChecker.checkApi(response);
      }
      return isSuccess;
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// `POST /customer/cart/bundle/add`
  Future<bool> addBundleToCart(int bundleId, int quantity) async {
    _isLoading = true;
    update();
    try {
      final String? guestId = await _resolveGuestId();
      Response response = await cartServiceInterface.addBundleToCartOnline(
        bundleId, quantity, guestId,
      );

      final bool isSuccess = ApiClient.isSuccessCode(response.statusCode);
      if(isSuccess) {
        await getAllCarts(notify: false);
      } else {
        ApiChecker.checkApi(response);
      }
      return isSuccess;
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Find Bundle in cart
  CartModel? findBundleInCart(int? bundleId, {int? storeId}) {
    if(bundleId == null) {
      return null;
    }
    for(final AllCartsModel group in _allCartsGroups ?? const <AllCartsModel>[]) {
      final int? groupStoreId = group.store?.id;
      if(storeId != null && groupStoreId != storeId) {
        continue;
      }
      final List<CartModel> rows = (groupStoreId != null ? _foldedCartsByStore[groupStoreId] : null)
          ?? group.carts ?? const <CartModel>[];
      for(final CartModel cart in rows) {
        if(cart.isBundle && cart.bundleDetails?.bundleId == bundleId) {
          return cart;
        }
      }
    }
    return null;
  }

  /// `POST /customer/cart/bundle/update`
  Future<void> updateBundleQuantity(bool isIncrement, CartModel cart) async {
    if(!cart.isBundle) return;
    await setBundleQuantity(cart, (cart.quantity ?? 1) + (isIncrement ? 1 : -1));
  }

  /// Set bundle quantity
  Future<bool> setBundleQuantity(CartModel cart, int quantity) async {
    if(_isLoading || !cart.isBundle || quantity < 1) return false;

    _isLoading = true;
    update();
    try {
      final String? guestId = await _resolveGuestId();
      Response response = await cartServiceInterface.updateBundleQuantityOnline(
        cart.bundleDetails!.bundleGroupId, quantity, guestId,
      );
      final bool isSuccess = ApiClient.isSuccessCode(response.statusCode);
      if(isSuccess) {
        await getAllCarts(notify: false);
      } else {
        ApiChecker.checkApi(response);
      }
      return isSuccess;
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// `DELETE /customer/cart/bundle/remove`
  Future<void> removeBundle(CartModel cart) async {
    if(_isLoading || !cart.isBundle) return;

    _isLoading = true;
    update();
    try {
      final String? guestId = await _resolveGuestId();
      await cartServiceInterface.removeBundleItemOnline(
        cart.bundleDetails!.bundleGroupId, guestId,
      );
      await getAllCarts(notify: false);
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Bundle mode of `/customer/cart/remove-item`
  Future<void> removeBogoBundle(CartModel cart, {required int storeId}) async {
    if(_isLoading || !cart.isBogoBundle) return;

    _isLoading = true;
    update();
    try {
      final String? guestId = await _resolveGuestId();
      await cartServiceInterface.removeBogoBundleItemOnline(
        cart.bogoDetails!.bogoGroupId, guestId, storeId: storeId,
      );
      await getAllCarts(notify: false);
    } finally {
      _isLoading = false;
      update();
    }
  }
}
