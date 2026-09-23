import 'dart:convert';

import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/monthly_order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_cancellation_body.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_details_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/domain/models/reorder_response_model.dart';
import 'package:Oxygen_Mart/features/order/domain/repositories/order_repository_interface.dart';
import 'package:Oxygen_Mart/features/order/domain/services/order_service_interface.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class OrderService implements OrderServiceInterface {
  final OrderRepositoryInterface orderRepositoryInterface;
  OrderService({required this.orderRepositoryInterface});

  @override
  Future<PaginatedOrderModel?> getRunningOrderList(
      int offset, bool fromDashboard) async {
    return await orderRepositoryInterface.getList(
        isRunningOrder: true, offset: offset, fromDashboard: fromDashboard);
  }

  @override
  Future<PaginatedOrderModel?> getHistoryOrderList(int offset) async {
    return await orderRepositoryInterface.getList(
        isHistoryOrder: true, offset: offset);
  }

  @override
  Future<List<String?>?> getSupportReasonsList() async {
    return await orderRepositoryInterface.getList(isSupportReasons: true);
  }

  @override
  Future<List<OrderDetailsModel>?> getOrderDetails(
      String orderID, String? guestId) async {
    return await orderRepositoryInterface.get(orderID, guestId: guestId);
  }

  @override
  Future<List<CancellationData>?> getCancelReasons() async {
    return await orderRepositoryInterface.getList(isCancelReasons: true);
  }

  @override
  Future<List<String?>?> getRefundReasons() async {
    return await orderRepositoryInterface.getList(isRefundReasons: true);
  }

  @override
  Future<void> submitRefundRequest(
      int selectedReasonIndex,
      List<String?>? refundReasons,
      String note,
      String? orderId,
      XFile? refundImage) async {
    if (selectedReasonIndex == 0) {
      showCustomSnackBar('please_select_reason'.tr);
    } else {
      Map<String, String> body = {};
      body.addAll(<String, String>{
        'customer_reason': refundReasons![selectedReasonIndex]!,
        'order_id': orderId!,
        'customer_note': note,
      });
      Response response =
          await orderRepositoryInterface.submitRefundRequest(body, refundImage);
      if (response.statusCode == 200) {
        showCustomSnackBar(response.body['message'], isError: false);
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    }
  }

  @override
  Future<Response> trackOrder(String? orderID, String? guestId,
      {String? contactNumber}) async {
    return await orderRepositoryInterface.trackOrder(orderID, guestId,
        contactNumber: contactNumber);
  }

  @override
  Future<Response> getDeliveryManLastLocation(String orderID) async {
    return await orderRepositoryInterface.getDeliveryManLastLocation(orderID);
  }

  @override
  Future<bool> cancelOrder(String orderID, String? reason,
      {String? guestId}) async {
    return await orderRepositoryInterface.cancelOrder(orderID, reason,
        guestId: guestId);
  }

  @override
  OrderModel? prepareOrderModel(
      PaginatedOrderModel? runningOrderModel, int? orderID) {
    OrderModel? orderModel;
    if (runningOrderModel != null) {
      for (OrderModel order in runningOrderModel.orders!) {
        if (order.id == orderID) {
          orderModel = order;
          break;
        }
      }
    }
    return orderModel;
  }

  @override
  Future<bool> switchToCOD(String? orderID, {String? guestId}) async {
    bool isSuccess = false;
    Response response =
        await orderRepositoryInterface.switchToCOD(orderID, guestId: guestId);
    if (response.statusCode == 200) {
      isSuccess = true;
      await Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar(response.body['message'], isError: false);
    }
    return isSuccess;
  }

  @override
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
    bool forOrder = (addFundUrl == '' &&
        addFundUrl!.isEmpty &&
        subscriptionUrl == '' &&
        subscriptionUrl!.isEmpty);
    bool forSubscription = (subscriptionUrl != null &&
        subscriptionUrl.isNotEmpty &&
        addFundUrl == '' &&
        addFundUrl!.isEmpty);

    if (canRedirect) {
      bool isSuccess;
      bool isFailed;
      bool isCancel;

      if (isProSubscription) {
        isSuccess = url.startsWith('${AppConstants.baseUrl}/payment-success') ||
            url.contains('payment-success') ||
            url.contains('success=true');
        isFailed = url.startsWith('${AppConstants.baseUrl}/payment-fail') ||
            url.contains('payment-fail') ||
            url.contains('fail=true');
        isCancel = url.startsWith('${AppConstants.baseUrl}/payment-cancel') ||
            url.contains('cancel');
      } else {
        isSuccess = forSubscription
            ? url.startsWith('${AppConstants.baseUrl}/subscription-success')
            : (url.contains('success=true') ||
                url.contains('status=success') ||
                url.contains('payment-success'));

        isFailed = forSubscription
            ? url.startsWith('${AppConstants.baseUrl}/subscription-fail')
            : (url.contains('fail=true') ||
                url.contains('status=fail') ||
                url.contains('payment-fail'));

        isCancel = forSubscription
            ? url.startsWith('${AppConstants.baseUrl}/subscription-cancel')
            : (url.startsWith('${AppConstants.baseUrl}/payment-cancel') ||
                url.contains('cancel'));
      }

      if (isSuccess || isFailed || isCancel) {
        canRedirect = false;
        onClose();
      }
      if (forOrder) {
        if (isSuccess) {
          Get.offNamed(RouteHelper.getOrderSuccessRoute(
            orderID,
            contactNumber,
            createAccount: createAccount,
            guestId: guestId,
          ));
        } else if (isFailed || isCancel) {
          Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, contactNumber,
              createAccount: createAccount, guestId: guestId));
        }
      } else {
        if (isSuccess || isFailed || isCancel) {
          if (Get.currentRoute.contains(RouteHelper.payment)) {
            Get.back();
          }
          if (isProSubscription) {
            _proSubscriptionRedirect(isSuccess, isRenew);
          } else if (forSubscription) {
            Get.find<HomeController>()
                .saveRegistrationSuccessfulSharedPref(true);
            Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
            Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
                status: isSuccess
                    ? 'success'
                    : isFailed
                        ? 'fail'
                        : 'cancel',
                fromSubscription: true,
                storeId: storeId));
          } else {
            Get.back();
            Get.toNamed(RouteHelper.getWalletRoute(
                fundStatus: isSuccess
                    ? 'success'
                    : isFailed
                        ? 'fail'
                        : 'cancel',
                token: UniqueKey().toString()));
          }
        }
      }
    }
  }

  void _proSubscriptionRedirect(bool isSuccess, bool isRenew) {
    if (isSuccess) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<ProController>().getProPlans();
      Get.find<ProController>().getProActiveOffer(
          moduleType: Get.find<SplashController>().module?.moduleType);
    }
    Get.find<ProController>().showPlanSubscribeState(isRenew,
        redirect: true, paymentStatus: isSuccess, isOffAll: false);
  }

  @override
  Future<MonthlyOrderModel?> getMonthlyOrderList({required int offset, String? moduleType}) async {
    return await orderRepositoryInterface.getMonthlyOrderList(offset: offset, moduleType: moduleType);
  }

  @override
  Future<bool> removeMonthlyOrder(int id) async {
    Response response = await orderRepositoryInterface.removeMonthlyOrder(id);
    if(response.statusCode == 200) {
      final dynamic body = response.body;
      if(body is Map<String, dynamic> && body['message'] != null) {
        showCustomSnackBar(body['message'].toString(), isError: false);
      }
      return true;
    }
    return false;
  }

  @override
  Future<ReorderResponseModel?> reorder(int orderId) async {
    return await orderRepositoryInterface.reorder(orderId);
  }
}
