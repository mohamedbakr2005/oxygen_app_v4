import 'dart:convert';

import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/all_carts_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/online_cart_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/module_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class CartRepository implements CartRepositoryInterface<OnlineCart> {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CartRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<void> addSharedPrefCartList(List<CartModel> cartProductList) async {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<String> cartStringList = [];
    for(String cartString in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cartString));
      if(cartModel.item!.moduleId != _getModuleId()) {
        cartStringList.add(cartString);
      }
    }
    for(CartModel cartModel in cartProductList) {
      cartStringList.add(jsonEncode(cartModel.toJson()));
    }
    await sharedPreferences.setStringList(AppConstants.cartList, cartStringList);
  }

  int _getModuleId() {
    return ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id ?? 0;
  }

  @override
  Future add(OnlineCart cart, {int? storeId}) async {
    return await _addToCartOnline(cart, storeId: storeId);
  }

  Future<List<OnlineCartModel>?> _addToCartOnline(OnlineCart cart, {int? storeId}) async {
    storeId ??= cart.storeId;
    List<OnlineCartModel>? onlineCartList;
    Map<String, dynamic> data = cart.toJson();
    if(storeId != null && !data.containsKey('store_id')) {
      data['store_id'] = storeId;
    }
    Response response = await apiClient.postData('${AppConstants.addCartUri}${_buildCartMutationQuery(storeId)}', data);
    if(ApiClient.isSuccessCode(response.statusCode)) {
      onlineCartList = [];
      for (final dynamic c in ResponseParser.listOrEmpty(response.body)) {
        onlineCartList.add(OnlineCartModel.fromJson(c));
      }
    }
    return onlineCartList;
  }

  String _buildCartMutationQuery(int? storeId) {
    final List<String> queryParams = <String>[];
    if(!AuthHelper.isLoggedIn()) {
      queryParams.add('guest_id=${AuthHelper.getGuestId()}');
    }
    if(storeId != null) {
      queryParams.add('store_id=$storeId');
    }
    return queryParams.isEmpty ? '' : '?${queryParams.join('&')}';
  }

  @override
  Future<bool> delete(int? id, {bool isRemoveAll = false, int? storeId}) async {
    if(isRemoveAll) {
      return await _clearCartOnline();
    } else {
      return await _removeCartItemOnline(id!, storeId: storeId);
    }
  }

  Future<bool> _removeCartItemOnline(int cartId, {int? storeId}) async {
    final List<String> queryParams = <String>['cart_id=$cartId'];
    if(!AuthHelper.isLoggedIn()) {
      queryParams.add('guest_id=${AuthHelper.getGuestId()}');
    }
    if(storeId != null) {
      queryParams.add('store_id=$storeId');
    }
    Response response = await apiClient.deleteData('${AppConstants.removeItemCartUri}?${queryParams.join('&')}');
    return (response.statusCode == 200);
  }

  Future<bool> _clearCartOnline() async {
    Response response = await apiClient.deleteData('${AppConstants.removeAllCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}');
    return (response.statusCode == 200);
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return await _getCartDataOnline();
  }

  @override
  Future<List<OnlineCartModel>?> getCartDataOnline({int? storeId}) async {
    return await _getCartDataOnline(storeId: storeId);
  }

  Future<List<OnlineCartModel>?> _getCartDataOnline({int? storeId}) async {
    // `cart/list` now rejects a request that carries no `store_id` with a 422
    // ("The store id field is required.").
    // `cart/get-all` is the unscoped equivalent: every store group at once.
    // Flattening its groups reproduces exactly what a store-less `cart/list` returned.
    if (storeId == null) {
      final List<AllCartsModel>? groups = await getAllCarts();
      if (groups == null) {
        return null;
      }
      return groups
          .expand((AllCartsModel group) => group.onlineCarts ?? const <OnlineCartModel>[])
          .toList();
    }

    List<OnlineCartModel>? onlineCartList;
    final String? token = sharedPreferences.getString(AppConstants.token);
    final int? cacheModuleId = ModuleHelper.getCacheModule()?.id;
    Map<String, String>? header = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: AppConstants.languages[0].languageCode!,
      if (cacheModuleId != null) AppConstants.moduleId: '$cacheModuleId',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final List<String> queryParams = <String>[];
    if(!AuthHelper.isLoggedIn()) {
      queryParams.add('guest_id=${AuthHelper.getGuestId()}');
    }
    queryParams.add('store_id=$storeId');
    final String querySuffix = '?${queryParams.join('&')}';

    Response response = await apiClient.getData(
      '${AppConstants.getCartListUri}$querySuffix',
      headers: ModuleHelper.getModule()?.id == null ? header : null,
      handleError: false,
    );
    if(ApiClient.isSuccessCode(response.statusCode)) {
      onlineCartList = [];
      for (final dynamic cart in ResponseParser.listOrEmpty(response.body)) {
        onlineCartList.add(OnlineCartModel.fromJson(cart));
      }
    }
    return onlineCartList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id, {double? price, int? quantity, bool isUpdateQty = false, int? storeId}) async {
    if(isUpdateQty) {
      if (body.isNotEmpty) {
        return await _updateCartQuantityOnlineBody(body, storeId: storeId);
      } else {
        return await _updateCartQuantityOnlineLegacy(id!, price!, quantity!, storeId: storeId);
      }
    } else {
      return await _updateCartOnline(body, storeId: storeId);
    }
  }

  Future<List<OnlineCartModel>?> _updateCartOnline(Map<String, dynamic> body, {int? storeId}) async {
    if(storeId != null && !body.containsKey('store_id')) {
      body['store_id'] = storeId;
    }
    List<OnlineCartModel>? onlineCartList;
    Response response = await apiClient.postData('${AppConstants.updateCartUri}${_buildCartMutationQuery(storeId)}', body);
    if(ApiClient.isSuccessCode(response.statusCode)) {
      onlineCartList = [];
      for (final dynamic cart in ResponseParser.listOrEmpty(response.body)) {
        onlineCartList.add(OnlineCartModel.fromJson(cart));
      }
    }
    return onlineCartList;
  }

  Future<bool> _updateCartQuantityOnlineBody(Map<String, dynamic> body, {int? storeId}) async {
    Response response = await apiClient.postData('${AppConstants.updateCartUri}${_buildCartMutationQuery(storeId)}', body);
    return ApiClient.isSuccessCode(response.statusCode);
  }

  Future<bool> _updateCartQuantityOnlineLegacy(int cartId, double price, int quantity, {int? storeId}) async {
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
    };
    if(storeId != null) {
      data['store_id'] = storeId;
    }
    Response response = await apiClient.postData('${AppConstants.updateCartUri}${_buildCartMutationQuery(storeId)}', data);
    return (response.statusCode == 200);
  }

  @override
  Future<List<AllCartsModel>?> getAllCarts() async {
    List<AllCartsModel>? allCarts;
    final String? token = sharedPreferences.getString(AppConstants.token);
    final int? cacheModuleId = ModuleHelper.getCacheModule()?.id;
    Map<String, String>? header = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: AppConstants.languages[0].languageCode!,
      if (cacheModuleId != null) AppConstants.moduleId: '$cacheModuleId',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    if(ModuleHelper.getCacheModule()?.id == null) {
      return [];
    }

    Response response = await apiClient.getData(
      '${AppConstants.getAllCartsUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      headers: ModuleHelper.getModule()?.id == null ? header : null,
    );
    if(ApiClient.isSuccessCode(response.statusCode)) {
      allCarts = [];
      for (final dynamic group in ResponseParser.listOrEmpty(response.body)) {
        allCarts.add(AllCartsModel.fromJson(group));
      }
    }
    return allCarts;
  }

  @override
  Future<bool> removeStoreCart(int storeId) async {
    final String guestSuffix = !AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : '';
    Response response = await apiClient.deleteData('${AppConstants.removeAllCartUri}?store_id=$storeId$guestSuffix');
    return (response.statusCode == 200);
  }

  Map<String, String>? _headersForModule(int? moduleId) {
    if (moduleId == null) {
      return null;
    }
    final Map<String, String> headers = Map<String, String>.from(apiClient.getHeader());
    headers[AppConstants.moduleId] = '$moduleId';
    headers['Content-Type'] = 'application/json; charset=UTF-8';
    return headers;
  }

  @override
  Future<Response> addBogoToCartOnline(int bogoId, int quantity, String? guestId, {String? contactPersonNumber, int? moduleId}) async {
    Map<String, dynamic> body = {
      'bundle_id': bogoId,
      'quantity': quantity,
      if (guestId != null && guestId.isNotEmpty) 'guest_id': guestId,
      if (contactPersonNumber != null && contactPersonNumber.isNotEmpty) 'contact_person_number': contactPersonNumber,
    };
    final String guestQuery = (guestId != null && guestId.isNotEmpty) ? '?guest_id=$guestId' : '';
    return await apiClient.postData('${AppConstants.addBogoCartUri}$guestQuery', body, handleError: false, headers: _headersForModule(moduleId));
  }

  @override
  Future<Response> updateBogoBundleQuantityOnline(String bogoGroupId, int quantity, String? guestId, {int? moduleId}) async {
    Map<String, dynamic> data = {
      'bogo_group_id': bogoGroupId,
      'quantity': quantity,
      if (guestId != null && guestId.isNotEmpty) 'guest_id': guestId,
    };
    final String guestQuery = (guestId != null && guestId.isNotEmpty) ? '?guest_id=$guestId' : '';
    return await apiClient.postData('${AppConstants.updateBogoCartUri}$guestQuery', data, handleError: false, headers: _headersForModule(moduleId));
  }

  @override
  Future<bool> removeBogoBundleItemOnline(String bogoGroupId, String? guestId, {required int storeId}) async {
    final String guestQuery = (guestId != null && guestId.isNotEmpty) ? '?guest_id=$guestId' : '';
    Response response = await apiClient.deleteData(
      '${AppConstants.removeBogoCartUri}$guestQuery',
      body: {
        'bogo_group_id': bogoGroupId,
        if (guestId != null && guestId.isNotEmpty) 'guest_id': guestId,
      },
      handleError: false,
    );
    return (response.statusCode == 200);
  }

  @override
  Future<Response> addBundleToCartOnline(int bundleId, int quantity, String? guestId) async {
    Map<String, dynamic> body = {
      'bundle_id': bundleId,
      'quantity': quantity,
      if (guestId != null && guestId.isNotEmpty) 'guest_id': guestId,
    };
    final String guestQuery = (guestId != null && guestId.isNotEmpty) ? '?guest_id=$guestId' : '';
    return await apiClient.postData('${AppConstants.addBundleCartUri}$guestQuery', body, handleError: false);
  }

  @override
  Future<Response> updateBundleQuantityOnline(String bundleGroupId, int quantity, String? guestId) async {
    Map<String, dynamic> body = {
      'bundle_group_id': bundleGroupId,
      'quantity': quantity,
      if (guestId != null && guestId.isNotEmpty) 'guest_id': guestId,
    };
    final String guestQuery = (guestId != null && guestId.isNotEmpty) ? '?guest_id=$guestId' : '';
    return await apiClient.postData('${AppConstants.updateBundleCartUri}$guestQuery', body, handleError: false);
  }

  @override
  Future<bool> removeBundleItemOnline(String bundleGroupId, String? guestId) async {
    final String guestQuery = (guestId != null && guestId.isNotEmpty) ? '?guest_id=$guestId' : '';
    Response response = await apiClient.deleteData(
      '${AppConstants.removeBundleCartUri}$guestQuery',
      body: {
        'bundle_group_id': bundleGroupId,
        if (guestId != null && guestId.isNotEmpty) 'guest_id': guestId,
      },
      handleError: false,
    );
    return (response.statusCode == 200);
  }
}
