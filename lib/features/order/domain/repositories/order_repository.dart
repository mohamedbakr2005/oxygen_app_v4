import 'package:get/get_connect/connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/common/models/ongoing_order_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/payment_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/last_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/monthly_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_cancellation_body.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_details_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/refund_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/reorder_response_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/support_model.dart';
import 'package:Oxygen_Mart/features/order/domain/repositories/order_repository_interface.dart';
import 'package:Oxygen_Mart/features/order/domain/services/order_service_interface.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  OrderRepository({required this.apiClient});

  @override
  Future<Response> submitRefundRequest(
      Map<String, String> body, XFile? data) async {
    return apiClient.postMultipartData(
        AppConstants.refundRequestUri, body, [MultipartBody('image[]', data)]);
  }

  @override
  Future<Response> trackOrder(String? orderID, String? guestId,
      {String? contactNumber}) async {
    return await apiClient.getData(
      '${AppConstants.trackUri}$orderID${guestId != null ? '&guest_id=$guestId' : ''}'
      '${contactNumber != null ? '&contact_number=$contactNumber' : ''}',
    );
  }

  @override
  Future<Response?> getDirection({required LatLng origin, required LatLng destination}) async {
    return await apiClient.getData('${AppConstants.directionUri}?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
        '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}');
  }

  @override
  Future<Response> getDeliveryManLastLocation(String orderID) async {
    return await apiClient.getData('${AppConstants.lastLocationUri}$orderID');
  }

  @override
  Future<Response> switchToCOD(String? orderID, {String? guestId}) async {
    Map<String, String> data = {'_method': 'put', 'order_id': orderID!};
    if (AuthHelper.isGuestLoggedIn() || guestId != null) {
      data.addAll({'guest_id': guestId ?? AuthHelper.getGuestId()});
    }
    return await apiClient.postData(AppConstants.codSwitchUri, data);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> cancelOrder(String orderID, String? reason,
      {String? guestId, bool isParcel = false, List<String>? reasons, String? comment}) async {
    bool success = false;
    Map<String, dynamic> data;
    if (isParcel) {
      data = {'_method': 'put', 'order_id': orderID, 'reason': reasons ?? [], 'note': comment ?? ''};
    } else {
      data = {'_method': 'put', 'order_id': orderID, 'reason': reason ?? '', 'note': comment ?? ''};
    }
    if (AuthHelper.isGuestLoggedIn() || guestId != null) {
      data.addAll({'guest_id': guestId ?? AuthHelper.getGuestId()});
    }
    Response response =
        await apiClient.postData(AppConstants.orderCancelUri, data);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      success = true;
      final String? message = (response.body is Map ? response.body['message'] : null) ?? response.statusText;
      if (message != null) {
        showCustomSnackBar(message, isError: false);
      }
    }
    return success;
  }

  @override
  Future get(String? id, {String? guestId}) async {
    return await _getOrderDetails(id!, guestId);
  }

  Future<List<OrderDetailsModel>?> _getOrderDetails(
      String orderID, String? guestId) async {
    List<OrderDetailsModel>? orderDetails;
    Response response = await apiClient.getData(
        '${AppConstants.orderDetailsUri}$orderID${guestId != null ? '&guest_id=$guestId' : ''}');
    if (response.statusCode == 200) {
      orderDetails = [];
      for (final dynamic orderDetail in ResponseParser.listOrEmpty(response.body)) {
        orderDetails.add(OrderDetailsModel.fromJson(orderDetail));
      }
    }
    return orderDetails;
  }

  @override
  Future<PaginatedOrderModel?> getOrderList(OrderListType type, int offset, {bool fromDashboard = false, int? moduleId}) async {
    PaginatedOrderModel? orderModel;
    final String moduleParam = moduleId != null ? '&module_id=$moduleId' : '';
    Response response = await apiClient.getData(
      '${AppConstants.allOrderList}?type=${type.queryValue}&offset=$offset&limit=${fromDashboard ? 50 : 10}$moduleParam',
    );
    if (response.statusCode == 200) {
      orderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return orderModel;
  }

  @override
  Future getList(
      {int? offset,
      bool isRunningOrder = false,
      bool isHistoryOrder = false,
      bool isCancelReasons = false,
      bool isRefundReasons = false,
      bool fromDashboard = false,
      bool isSupportReasons = false}) async {
    if (isRunningOrder) {
      return await _getRunningOrderList(offset!, fromDashboard);
    } else if (isHistoryOrder) {
      return await _getHistoryOrderList(offset!);
    } else if (isCancelReasons) {
      return await _getCancelReasons();
    } else if (isRefundReasons) {
      return await _getRefundReasons();
    } else if (isSupportReasons) {
      return await _getSupportReasons();
    }
  }

  Future<PaginatedOrderModel?> _getRunningOrderList(
      int offset, bool fromDashboard) async {
    PaginatedOrderModel? paginatedOrderModel;
    Response response = await apiClient.getData(
        '${AppConstants.runningOrderListUri}?offset=$offset&limit=${fromDashboard ? 50 : 10}');
    if (response.statusCode == 200) {
      paginatedOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return paginatedOrderModel;
  }

  Future<PaginatedOrderModel?> _getHistoryOrderList(int offset) async {
    PaginatedOrderModel? paginatedOrderModel;
    Response response = await apiClient
        .getData('${AppConstants.historyOrderListUri}?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      paginatedOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return paginatedOrderModel;
  }

  Future<List<CancellationData>?> _getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData(
        '${AppConstants.orderCancellationUri}?offset=1&limit=30&type=customer');
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody =
          OrderCancellationBody.fromJson(response.body);
      orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons ?? <CancellationData>[]) {
        orderCancelReasons.add(element);
      }
    }
    return orderCancelReasons;
  }

  Future<List<String?>?> _getRefundReasons() async {
    List<String?>? refundReasons;
    Response response = await apiClient.getData(AppConstants.refundReasonUri);
    if (response.statusCode == 200) {
      RefundModel refundModel = RefundModel.fromJson(response.body);
      refundReasons = [];
      refundReasons.insert(0, 'select_an_option');
      for (var element in refundModel.refundReasons ?? <RefundReasons>[]) {
        refundReasons.add(element.reason);
      }
    }
    return refundReasons;
  }

  Future<List<String?>?> _getSupportReasons() async {
    List<String?>? supportReasons;
    Response response = await apiClient.getData(AppConstants.supportReasonUri);
    if (response.statusCode == 200) {
      SupportModel supportModel = SupportModel.fromJson(response.body);
      supportReasons = [];
      if (supportModel.data != null) {
        for (var element in supportModel.data!) {
          supportReasons.add(element.message);
        }
      }
    }
    return supportReasons;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<MonthlyOrderModel?> getMonthlyOrderList({required int offset, String? moduleType}) async {
    MonthlyOrderModel? monthlyOrderModel;
    final String moduleParam = (moduleType != null && moduleType.isNotEmpty) ? '&module_type=$moduleType' : '';
    final Response response = await apiClient.getData('${AppConstants.monthlyOrderListUri}?limit=10&offset=$offset$moduleParam');
    if(response.statusCode == 200) {
      monthlyOrderModel = MonthlyOrderModel.fromJson(response.body);
    }
    return monthlyOrderModel;
  }

  @override
  Future<Response> removeMonthlyOrder(int id) async {
    return await apiClient.deleteData('${AppConstants.monthlyOrderRemoveUri}?id=$id');
  }

  @override
  Future<ReorderResponseModel?> reorder(int orderId) async {
    Response response = await apiClient.postData(AppConstants.reorderUri, {'order_id': orderId}, handleError: false);
    final dynamic payload = ResponseParser.payloadOf(response.body);
    if (payload is! Map<String, dynamic>) {
      return ReorderResponseModel(message: response.statusText);
    }
    return ReorderResponseModel.fromJson(payload)..message = response.statusText;
  }

  @override
  Future<bool> deleteOrder(int orderId) async {
    final Response response = await apiClient.deleteData('${AppConstants.orderDeleteUri}?order_id=$orderId');
    return response.statusCode == 200;
  }

  @override
  Future<Response> switchToWalletPayment(String? orderID) async {
    Map<String, String> data = {'order_id': orderID!};
    return await apiClient.postData(AppConstants.walletSwitchUri, data);
  }

  @override
  Future<List<LastOrderModel>?> getLastOrders({required bool isHome, int? storeId}) async {
    Map<String, String>? header;
    if (isHome) {
      header = Map.from(apiClient.getHeader());
      header.remove(AppConstants.moduleId);
    }

    final String uri = storeId != null ? '${AppConstants.lastOrdersUri}?store_id=$storeId' : AppConstants.lastOrdersUri;
    final Response response = await apiClient.getData(uri, headers: header);
    if (response.statusCode == 200) {
      return ResponseParser.listOrEmpty(response.body)
          .whereType<Map<String, dynamic>>()
          .map(LastOrderModel.fromJson)
          .toList();
    }
    return null;
  }

  @override
  Future<bool> submitParcelReturn({required int orderId, required String orderStatus, required int returnOtp}) async {
    Map<String, dynamic> data = {
      'order_id': orderId,
      'order_status': orderStatus,
      'return_otp': returnOtp,
    };
    Response response = await apiClient.postData(AppConstants.customerParcelReturn, data);
    return response.statusCode == 200;
  }

  @override
  Future<PaymentModel?> getPaymentFailedDetails(String? orderID) async {
    PaymentModel? paymentModel;
    Response response = await apiClient.getData(
      '${AppConstants.paymentFailedDetailsUri}${orderID != null ? '?order_id=$orderID' : ''}${AuthHelper.isGuestLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : ''}',
    );
    if (response.statusCode == 200) {
      try {
        final PaymentModel parsed = PaymentModel.fromJson(response.body);
        if (parsed.orderID != null) {
          paymentModel = parsed;
        }
      } catch (_) {}
    }
    return paymentModel;
  }

  @override
  Future<OngoingOrderModel?> getDashboardOrders() async {
    OngoingOrderModel? ongoingOrderModel;
    Response response = await apiClient.getData(AppConstants.dashboardOrderUri);
    if (response.statusCode == 200) {
      ongoingOrderModel = OngoingOrderModel.fromJson(response.body);
    }
    return ongoingOrderModel;
  }
}
