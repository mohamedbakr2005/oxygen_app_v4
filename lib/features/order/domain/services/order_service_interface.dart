import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/payment_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/last_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/monthly_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_cancellation_body.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_details_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/reorder_response_model.dart';

abstract class OrderServiceInterface {
  Future<PaginatedOrderModel?> getRunningOrderList(
      int offset, bool fromDashboard);
  Future<PaginatedOrderModel?> getHistoryOrderList(int offset);
  Future<List<String?>?> getSupportReasonsList();
  Future<List<OrderDetailsModel>?> getOrderDetails(
      String orderID, String? guestId);
  Future<List<CancellationData>?> getCancelReasons();
  Future<List<String?>?> getRefundReasons();
  Future<void> submitRefundRequest(
      int selectedReasonIndex,
      List<String?>? refundReasons,
      String note,
      String? orderId,
      XFile? refundImage);
  Future<Response> trackOrder(String? orderID, String? guestId,
      {String? contactNumber});
  Future<Response> getDeliveryManLastLocation(String orderID);
  Future<bool> cancelOrder(String orderID, String? reason, {String? guestId});
  Future<bool> deleteOrder(int orderId);
  OrderModel? prepareOrderModel(
      PaginatedOrderModel? runningOrderModel, int? orderID);
  Future<bool> switchToCOD(String? orderID, {String? guestId});
  Future<bool> switchToWalletPayment(String? orderID);
  Future<MonthlyOrderModel?> getMonthlyOrderList({required int offset, String? moduleType});
  Future<bool> removeMonthlyOrder(int id);
  Future<ReorderResponseModel?> reorder(int orderId);
  Future<List<LastOrderModel>?> getLastOrders({required bool isHome, int? storeId});
  Future<bool> submitParcelReturn({required int orderId, required String orderStatus, required int returnOtp});
  Future<PaymentModel?> getPaymentFailedDetails(String? orderID);
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
      bool isRenew = false});
}

