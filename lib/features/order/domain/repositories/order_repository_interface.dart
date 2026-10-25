import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/payment_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/last_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/monthly_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/reorder_response_model.dart';
import 'package:Oxygen_Mart/interfaces/repository_interface.dart';

abstract class OrderRepositoryInterface extends RepositoryInterface {
  @override
  Future get(String? id, {String? guestId});
  @override
  Future getList(
      {int? offset,
      bool isRunningOrder = false,
      bool isHistoryOrder = false,
      bool isCancelReasons = false,
      bool isRefundReasons = false,
      bool fromDashboard,
      bool isSupportReasons = false});
  Future<Response> submitRefundRequest(Map<String, String> body, XFile? data);
  Future<Response> trackOrder(String? orderID, String? guestId,
      {String? contactNumber});
  Future<Response> getDeliveryManLastLocation(String orderID);
  Future<bool> cancelOrder(String orderID, String? reason, {String? guestId});
  Future<bool> deleteOrder(int orderId);
  Future<Response> switchToCOD(String? orderID, {String? guestId});
  Future<Response> switchToWalletPayment(String? orderID);
  Future<MonthlyOrderModel?> getMonthlyOrderList({required int offset, String? moduleType});
  Future<Response> removeMonthlyOrder(int id);
  Future<ReorderResponseModel?> reorder(int orderId);
  Future<List<LastOrderModel>?> getLastOrders({required bool isHome, int? storeId});
  Future<bool> submitParcelReturn({required int orderId, required String orderStatus, required int returnOtp});
  Future<PaymentModel?> getPaymentFailedDetails(String? orderID);
}

