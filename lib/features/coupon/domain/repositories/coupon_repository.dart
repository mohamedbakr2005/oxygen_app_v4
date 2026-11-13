import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/features/coupon/domain/models/coupon_model.dart';
import 'package:Oxygen_Mart/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class CouponRepository implements CouponRepositoryInterface {
  final ApiClient apiClient;
  CouponRepository({required this.apiClient});

  @override
  Future getList(
      {int? offset,
      bool couponList = false,
      bool taxiCouponList = false,
      int? customerId,
      int? storeId,
      int? zoneId}) async {
    if (couponList) {
      return await _getCouponList(customerId: customerId, storeId: storeId, zoneId: zoneId);
    } else if (taxiCouponList) {
      return await _getTaxiCouponList();
    }
  }

  Future<List<CouponModel>?> _getCouponList({int? customerId, int? storeId, int? zoneId}) async {
    List<CouponModel>? couponList;
    final List<String> queryParams = [];
    if (customerId != null) queryParams.add('customer_id=$customerId');
    if (storeId != null) queryParams.add('store_id=$storeId');
    if (zoneId != null) queryParams.add('zone_id=[$zoneId]');
    final String query = queryParams.isEmpty ? '' : '?${queryParams.join('&')}';
    Response response = await apiClient.getData('${AppConstants.couponUri}$query');
    if (ApiClient.isSuccessCode(response.statusCode)) {
      couponList = [];
      for (final dynamic category in ResponseParser.listOrEmpty(response.body)) {
        CouponModel coupon = CouponModel.fromJson(category);
        coupon.toolTip = JustTheController();
        couponList!.add(coupon);
      }
    }
    return couponList;
  }

  Future<List<CouponModel>?> _getTaxiCouponList() async {
    List<CouponModel>? taxiCouponList;
    Response response = await apiClient.getData(AppConstants.taxiCouponUri);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      taxiCouponList = [];
      for (final dynamic category in ResponseParser.listOrEmpty(response.body)) {
        taxiCouponList.add(CouponModel.fromJson(category));
      }
    }
    return taxiCouponList;
  }

  @override
  Future<CouponModel?> applyCoupon(String couponCode, int? storeID, {double? orderAmount}) async {
    CouponModel? couponModel;
    String url = '${AppConstants.couponApplyUri}$couponCode&store_id=$storeID';
    if (orderAmount != null) {
      url += '&order_amount=$orderAmount';
    }
    Response response = await apiClient.getData(url);
    if (response.statusCode == 200) {
      couponModel = CouponModel.fromJson(response.body);
    }
    return couponModel;
  }

  @override
  Future<CouponModel?> applyTaxiCoupon(
      String couponCode, int? providerId) async {
    CouponModel? taxiCouponModel;
    Response response = await apiClient.getData(
        '${AppConstants.taxiCouponApplyUri}$couponCode&provider_id=$providerId');
    if (response.statusCode == 200) {
      taxiCouponModel = CouponModel.fromJson(response.body);
    }
    return taxiCouponModel;
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
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
