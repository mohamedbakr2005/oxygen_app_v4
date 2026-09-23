import 'dart:convert';

import 'package:Oxygen_Mart/helper/facebook_pixel_helper.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/confirmation_dialog.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/all_carts_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/monthly_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_cancellation_body.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_details_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/reorder_response_model.dart';
import 'package:Oxygen_Mart/features/order/domain/services/order_service_interface.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/module_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:universal_html/js.dart' as js;

class OrderController extends GetxController implements GetxService {
  final OrderServiceInterface orderServiceInterface;

  OrderController({required this.orderServiceInterface});

  PaginatedOrderModel? _runningOrderModel;
  PaginatedOrderModel? get runningOrderModel => _runningOrderModel;

  PaginatedOrderModel? _historyOrderModel;
  PaginatedOrderModel? get historyOrderModel => _historyOrderModel;

  List<MonthlyOrder>? _monthlyOrders;
  List<MonthlyOrder>? get monthlyOrders => _monthlyOrders;

  int? _reorderingOrderId;
  int? get reorderingOrderId => _reorderingOrderId;

  List<OrderDetailsModel>? _orderDetails;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;

  OrderModel? _trackModel;
  OrderModel? get trackModel => _trackModel;

  ResponseModel? _responseModel;
  ResponseModel? get responseModel => _responseModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _showCancelled = false;
  bool get showCancelled => _showCancelled;

  bool _showBottomSheet = true;
  bool get showBottomSheet => _showBottomSheet;

  bool _showOneOrder = true;
  bool get showOneOrder => _showOneOrder;

  List<String?>? _refundReasons;
  List<String?>? get refundReasons => _refundReasons;

  int _selectedReasonIndex = 0;
  int get selectedReasonIndex => _selectedReasonIndex;

  XFile? _refundImage;
  XFile? get refundImage => _refundImage;

  String? _cancelReason;
  String? get cancelReason => _cancelReason;

  List<CancellationData>? _orderCancelReasons;
  List<CancellationData>? get orderCancelReasons => _orderCancelReasons;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  List<String?>? _supportReasons;
  List<String?>? get supportReasons => _supportReasons;

  bool _purchaseEventFired = false;

  void expandedUpdate(bool status) {
    _isExpanded = status;
    update();
  }

  void setOrderCancelReason(String? reason) {
    _cancelReason = reason;
    update();
  }

  void selectReason(int index, {bool isUpdate = true}) {
    _selectedReasonIndex = index;
    if (isUpdate) {
      update();
    }
  }

  void showOrders() {
    _showOneOrder = !_showOneOrder;
    update();
  }

  void showRunningOrders({bool canUpdate = true}) {
    _showBottomSheet = !_showBottomSheet;
    if (canUpdate) {
      update();
    }
  }

  void pickRefundImage(bool isRemove) async {
    if (isRemove) {
      _refundImage = null;
    } else {
      _refundImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      update();
    }
  }

  Future<void> getOrderCancelReasons() async {
    _orderCancelReasons = null;
    _orderCancelReasons = await orderServiceInterface.getCancelReasons();
    update();
  }

  Future<void> getRefundReasons() async {
    _selectedReasonIndex = 0;
    _refundReasons = null;
    _refundReasons = await orderServiceInterface.getRefundReasons();
    update();
  }

  Future<void> submitRefundRequest(String note, String? orderId) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'refund_requested',
      parameters: {
        'order_id': orderId.toString(),
        'reason': note,
      },
    );
    _isLoading = true;
    update();
    await orderServiceInterface.submitRefundRequest(
        _selectedReasonIndex, _refundReasons, note, orderId, _refundImage);
    _isLoading = false;
    update();
  }

  Future<void> getRunningOrders(int offset,
      {bool isUpdate = false, bool fromDashboard = false}) async {
    if (offset == 1) {
      _runningOrderModel = null;
      if (isUpdate) {
        update();
      }
    }
    PaginatedOrderModel? orderModel =
        await orderServiceInterface.getRunningOrderList(offset, fromDashboard);
    if (orderModel != null) {
      if (offset == 1) {
        _runningOrderModel = orderModel;
      } else {
        _runningOrderModel!.orders!.addAll(orderModel.orders!);
        _runningOrderModel!.offset = orderModel.offset;
        _runningOrderModel!.totalSize = orderModel.totalSize;
      }
      update();
    }
  }

  Future<void> getHistoryOrders(int offset, {bool isUpdate = false}) async {
    if (offset == 1) {
      _historyOrderModel = null;
      if (isUpdate) {
        update();
      }
    }
    PaginatedOrderModel? orderModel =
        await orderServiceInterface.getHistoryOrderList(offset);
    if (orderModel != null) {
      if (offset == 1) {
        _historyOrderModel = orderModel;
      } else {
        _historyOrderModel!.orders!.addAll(orderModel.orders!);
        _historyOrderModel!.offset = orderModel.offset;
        _historyOrderModel!.totalSize = orderModel.totalSize;
      }
      update();
    }
  }

  Future<void> getSupportReasons() async {
    _supportReasons = await orderServiceInterface.getSupportReasonsList();
    update();
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;

    if (_trackModel == null ||
        (_trackModel!.orderType != 'parcel' &&
            !_trackModel!.prescriptionOrder!)) {
      List<OrderDetailsModel>? detailsList =
          await orderServiceInterface.getOrderDetails(orderID,
              AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
      _isLoading = false;
      if (detailsList != null) {
        _orderDetails = [];
        _orderDetails!.addAll(detailsList);
      }
    } else {
      _isLoading = false;
      _orderDetails = [];
    }
    update();
    return _orderDetails;
  }

  Future<ResponseModel?> trackOrder(
      String? orderID, OrderModel? orderModel, bool fromTracking,
      {String? contactNumber, bool? fromGuestInput = false}) async {
    FirebaseAnalytics.instance.logEvent(
      name: 'track_order',
      parameters: {
        'order_id': orderID.toString(),
      },
    );
    _trackModel = null;
    _responseModel = null;
    if (!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if (orderModel == null) {
      _isLoading = true;
      Response response = await orderServiceInterface.trackOrder(
        orderID,
        AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
        contactNumber: contactNumber,
      );
      if (response.statusCode == 200) {
        _trackModel = OrderModel.fromJson(response.body);
        bool isSuccessOrCOD = (_trackModel!.paymentStatus == 'paid') ||
            (_trackModel!.paymentMethod == 'cash_on_delivery') ||
            (_trackModel!.paymentMethod == 'partial_payment') ||
            (_trackModel!.paymentMethod == 'wallet') ||
            (_trackModel!.paymentMethod == 'online_payment') ||
            (_trackModel!.paymentMethod == 'digital_payment');

        if (isSuccessOrCOD && !_purchaseEventFired) {
          _purchaseEventFired = true;

          /// 1) هات تفاصيل الأوردر (items)
          List<OrderDetailsModel>? details =
              await orderServiceInterface.getOrderDetails(orderID.toString(),
                  AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
          if (_trackModel!.refund == 'approved') {
            FirebaseAnalytics.instance.logEvent(
              name: 'refund_approved',
              parameters: {'order_id': orderID.toString()},
            );
          }
          if (_trackModel!.refund == 'rejected') {
            FirebaseAnalytics.instance.logEvent(
              name: 'refund_rejected',
              parameters: {'order_id': orderID.toString()},
            );
          }
          if (details != null && details.isNotEmpty) {
            /// 2) مستخرج ids
            final contentIds = details.map((e) => e.itemId.toString()).toList();

            // final firebaseItems = details.map((e) {
            //   return AnalyticsEventItem(
            //     itemId: e.itemId.toString(),
            //     itemName: e.itemDetails?.name ?? "unknown",
            //     itemCategory: e.itemDetails?.name ?? "unknown",
            //     quantity: e.quantity ?? 1,
            //     price: e.price ?? 0,
            //   );
            // }).toList();

            /// 3) Fire Purchase Event

            // FacebookEvents.purchase(
            //     orderId: orderID.toString(),
            //     total: _trackModel!.orderAmount ?? 0.0);

            FirebaseAnalytics analytics = FirebaseAnalytics.instance;

            analytics.logEvent(
              name: 'Purchase',
              parameters: {
                'value': _trackModel!.orderAmount ?? 0.0,
                'currency': 'EGP',
                'tax': _trackModel!.taxPercentage ?? 0.0,
                'shipping': _trackModel!.deliveryCharge ?? 0.0,
                'coupon': _trackModel!.couponCode ?? '',
                'item_id': jsonEncode(contentIds),
                'price': _trackModel!.orderAmount ?? 0.0,
                'quantity': _trackModel!.orderAmount ?? 0.0,
              },
            );

            print(
                "============================== Purchase ${jsonEncode(contentIds)} ========================== ");

            print(
                "🔥 Purchase Event Fired From OrderController with OrderDetails()");
            // print(
            // "🔥 Firebase Purchase Event sent with ${firebaseItems.length} items");
          }
        }

        _responseModel = ResponseModel(true, response.body.toString());
      } else {
        _responseModel = ResponseModel(false, response.statusText);
      }
      _isLoading = false;
      update();
    } else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
    }
    return _responseModel;
  }

  Future<ResponseModel?> timerTrackOrder(String orderID,
      {String? contactNumber, bool canUpdate = true}) async {
    _showCancelled = false;

    Response response = await orderServiceInterface.trackOrder(
      orderID,
      AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId(),
      contactNumber: contactNumber,
    );
    if (response.statusCode == 200) {
      _trackModel = OrderModel.fromJson(response.body);
      _responseModel = ResponseModel(true, response.body.toString());
    } else {
      _responseModel = ResponseModel(false, response.statusText);
    }
    
    if (canUpdate) {
      update();
    }

    return _responseModel;
  }

  Future<DeliveryMan?> refreshDeliveryManLocation(String orderID, {bool canUpdate = true}) async {
    final Response response =
        await orderServiceInterface.getDeliveryManLastLocation(orderID);
    if (response.statusCode != 200) {
      return null;
    }

    final Map<String, String?>? locationData =
        _extractDeliveryManLocation(response.body);
    if (locationData == null) {
      return null;
    }

    _trackModel ??= OrderModel();
    _trackModel!.deliveryMan ??= DeliveryMan();
    _trackModel!.deliveryMan!.lat = locationData['lat'];
    _trackModel!.deliveryMan!.lng = locationData['lng'];
    if (locationData['location'] != null) {
      _trackModel!.deliveryMan!.location = locationData['location'];
    }
    
    if (canUpdate) {
      update();
    }
    return _trackModel!.deliveryMan;
  }

  Map<String, String?>? _extractDeliveryManLocation(dynamic body) {
    final List<dynamic> candidates = <dynamic>[body];

    if (body is Map<String, dynamic>) {
      candidates.add(body['data']);
      candidates.add(body['delivery_man']);
      candidates.add(body['deliveryMan']);
      if (body['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> data = body['data'];
        candidates.add(data['delivery_man']);
        candidates.add(data['deliveryMan']);
      }
    }

    for (final dynamic candidate in candidates) {
      if (candidate is! Map) {
        continue;
      }

      final String? lat = _readCoordinate(candidate, <String>[
        'lat',
        'latitude',
      ]);
      final String? lng = _readCoordinate(candidate, <String>[
        'lng',
        'longitude',
        'long',
      ]);

      if (lat == null || lng == null) {
        continue;
      }

      return <String, String?>{
        'lat': lat,
        'lng': lng,
        'location': candidate['location']?.toString(),
      };
    }

    return null;
  }

  String? _readCoordinate(Map candidate, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = candidate[key];
      if (value == null) {
        continue;
      }
      final String parsed = value.toString();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return null;
  }

  Future<bool> cancelOrder(int? orderID, String? cancelReason,
      {String? guestId}) async {
    _isLoading = true;
    update();
    bool success = await orderServiceInterface
        .cancelOrder(orderID.toString(), cancelReason, guestId: guestId);
    _isLoading = false;
    Get.back();
    if (success) {
      OrderModel? orderModel =
          orderServiceInterface.prepareOrderModel(_runningOrderModel, orderID);
      if (_runningOrderModel != null) {
        _runningOrderModel!.orders!.remove(orderModel);
      }
      List<OrderDetailsModel>? details =
          await getOrderDetails(orderID.toString());

      FirebaseAnalytics.instance.logEvent(
        name: 'order_cancelled',
        parameters: {
          'order_id': orderID.toString(),
          'reason': cancelReason ?? '',
        },
      );


      try {
        Get.find<MetaAnalyticsService>().cancelOrder(
          orderId: orderID.toString(),
        );
      } catch(e) {}

      print("🚨 Order Cancelled Event Fired!");
      _showCancelled = true;
    }
    update();
    return success;
  }

  Future<bool> switchToCOD(String? orderID, {String? guestId}) async {
    _isLoading = true;
    update();
    bool isSuccess =
        await orderServiceInterface.switchToCOD(orderID, guestId: guestId);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void paymentRedirect(
      {required String url,
      required bool canRedirect,
      required String? contactNumber,
      required Function onClose,
      required final String? addFundUrl,
      required final String? subscriptionUrl,
      required final String orderID,
      int? storeId,
      required bool createAccount,
      required String guestId,
      bool isProSubscription = false,
      bool isRenew = false}) {
    orderServiceInterface.paymentRedirect(
      url: url,
      canRedirect: canRedirect,
      contactNumber: contactNumber,
      onClose: onClose,
      addFundUrl: addFundUrl,
      subscriptionUrl: subscriptionUrl,
      orderID: orderID,
      storeId: storeId,
      createAccount: createAccount,
      guestId: guestId,
      isProSubscription: isProSubscription,
      isRenew: isRenew,
    );
  }

  Future<void> reorder(OrderModel order) async {
    final int? orderId = order.id;
    final int? storeId = order.store?.id;

    if(orderId == null) {
      showCustomSnackBar('reorder_failed'.tr);
      return;
    }

    if(_reorderingOrderId != null) return;

    _reorderingOrderId = orderId;
    update();

    final CartController cartController = Get.find<CartController>();
    if(Get.find<SplashController>().moduleList != null) {
      for(ModuleModel module in Get.find<SplashController>().moduleList!) {
        if(module.id == order.moduleId) {
          Get.find<SplashController>().setModule(module);
          break;
        }
      }
    }
    await cartController.getAllCarts(notify: false);

    final AllCartsModel? existing = storeId != null ? cartController.getCartsForStore(storeId) : null;

    if(existing != null) {
      _reorderingOrderId = null;
      update();
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: 'are_you_sure_to_reset'.tr,
        description: _resetCartDescription(order.moduleType),
        onYesPressed: () async {
          if(Get.isDialogOpen ?? false) Get.back();
          final bool removed = await cartController.removeStoreCart(storeId!);
          if(removed) {
            await _performReorder(orderId);
          }
        },
      ), barrierDismissible: false);
      return;
    }

    await _performReorder(orderId);
  }

  String _resetCartDescription(String? moduleType) {
    bool showRestaurantText = true;
    if(moduleType != null) {
      try {
        showRestaurantText = Get.find<SplashController>().getModuleConfig(moduleType).showRestaurantText ?? true;
      } catch (_) {}
    }
    return showRestaurantText ? 'if_you_continue'.tr : 'if_you_continue_store'.tr;
  }

  Future<void> _performReorder(int orderId) async {
    _reorderingOrderId = orderId;
    update();
    final ReorderResponseModel? response = await orderServiceInterface.reorder(orderId);
    _reorderingOrderId = null;
    update();

    if(response != null) {
      String statusMessage = _buildReorderStatusMessage(response);
      showCustomSnackBar(statusMessage, isError: response.unavailableItems?.isNotEmpty ?? false ? true : false);

      final bool hasAdded = response.addedCount != null && response.addedCount! > 0;
      if(hasAdded) {
        await Get.find<CartController>().getAllCarts();
        Get.toNamed(RouteHelper.getGlobalCartRoute(initialModuleId: ModuleHelper.getCacheModule()?.id));
      }
    }
  }

  String _buildReorderStatusMessage(ReorderResponseModel response) {
    final hasAdded = response.addedCount != null && response.addedCount! > 0;
    final hasUnavailable = response.unavailableItems != null && response.unavailableItems!.isNotEmpty;

    String unavailableLabel = '';
    if (hasUnavailable) {
      final List<String> details = response.unavailableItems!
          .map((item) {
            final String name = item.name ?? '';
            final String message = item.message ?? 'items_unavailable'.tr;
            return name.isNotEmpty ? '$name $message' : message;
          }).where((detail) => detail.isNotEmpty).toList();
      unavailableLabel = details.isNotEmpty ? details.join(', ') : '${response.unavailableItems!.length} ${'items_unavailable'.tr}';
    }

    if (hasAdded && hasUnavailable) {
      return '${response.addedCount} ${'items_added_to_cart'.tr}, $unavailableLabel';
    } else if (hasAdded) {
      return '${response.addedCount} ${'items_added_to_cart'.tr}';
    } else if (hasUnavailable) {
      return unavailableLabel;
    }

    return 'reorder_completed'.tr;
  }

  Future<void> getMonthlyOrderList({bool reload = true, String? moduleType, bool notify = true}) async {
    if(reload) {
      _monthlyOrders = null;
      if(notify) update();
    }
    final MonthlyOrderModel? result = await orderServiceInterface.getMonthlyOrderList(offset: 1, moduleType: moduleType);
    if(result != null) {
      _monthlyOrders = result.items;
      update();
    }
  }

  Future<bool> removeMonthlyOrder(int id) async {
    update();
    final bool isSuccess = await orderServiceInterface.removeMonthlyOrder(id);
    if(isSuccess) {
      _monthlyOrders?.removeWhere((MonthlyOrder order) => order.id == id);
    }
    update();
    return isSuccess;
  }
}


// 5078086701425295
// 0628
// 994
// 86383