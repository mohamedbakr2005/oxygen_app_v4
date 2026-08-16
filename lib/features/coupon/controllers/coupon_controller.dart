import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/coupon/domain/models/coupon_model.dart';
import 'package:Oxygen_Mart/features/coupon/domain/services/coupon_service_interface.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';

class CouponController extends GetxController implements GetxService {
  final CouponServiceInterface couponServiceInterface;
  CouponController({required this.couponServiceInterface});

  List<CouponModel>? _couponList;
  List<CouponModel>? get couponList => _couponList;

  List<CouponModel>? _taxiCouponList;
  List<CouponModel>? get taxiCouponList => _taxiCouponList;

  CouponModel? _coupon;
  CouponModel? get coupon => _coupon;

  double? _discount = 0.0;
  double? get discount => _discount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _freeDelivery = false;
  bool get freeDelivery => _freeDelivery;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  //------------------------
  // Guards
  //------------------------
  bool _couponListLoaded = false;
  bool _taxiCouponListLoaded = false;
  bool _isFetchingCoupons = false;
  bool _isFetchingTaxiCoupons = false;

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  //------------------------
  // Coupon List (Protected Against Spam)
  //------------------------
  Future<void> getCouponList({bool reload = false}) async {
    final splash = Get.find<SplashController>();

    if (splash.isRefreshing) return; //⛔ أثناء Refresh
    if (_isFetchingCoupons) return; //⛔ Prevent parallel
    if (_couponListLoaded && !reload) return; //⛔ Already loaded

    _isFetchingCoupons = true;

    try {
      final list = await couponServiceInterface.getCouponList();
      if (list != null) {
        _couponList = [...list];
        _couponListLoaded = true;
      }
      update();
    } finally {
      _isFetchingCoupons = false;
    }
  }

  //------------------------
  // Taxi Coupon List (Protected)
  //------------------------
  Future<void> getTaxiCouponList({bool reload = false}) async {
    final splash = Get.find<SplashController>();

    if (splash.isRefreshing) return;
    if (_isFetchingTaxiCoupons) return;
    if (_taxiCouponListLoaded && !reload) return;

    _isFetchingTaxiCoupons = true;

    try {
      final list = await couponServiceInterface.getTaxiCouponList();
      if (list != null) {
        _taxiCouponList = [...list];
        _taxiCouponListLoaded = true;
      }
      update();
    } finally {
      _isFetchingTaxiCoupons = false;
    }
  }

  //------------------------
  // Apply Coupon (Safe)
  //------------------------
  Future<double?> applyCoupon(
      String coupon, double order, double? deliveryCharge, int? storeID) async {
    _isLoading = true;
    _discount = 0;
    update();

    CouponModel? couponModel =
        await couponServiceInterface.applyCoupon(coupon, storeID);

    if (couponModel != null) {
      _coupon = couponModel;
      if (_coupon!.couponType == 'free_delivery') {
        _processFreeDeliveryCoupon(deliveryCharge!, order);
      } else {
        _processCoupon(order);
      }
      // Log apply_coupon (success)
      try {
        Get.find<MetaAnalyticsService>().applyCoupon(coupon: _coupon!.code ?? coupon);
      } catch(e) {}
      await FirebaseAnalytics.instance.logEvent(
        name: 'apply_coupon',
        parameters: {
          'coupon_code': _coupon!.code ?? coupon,
          'coupon_type': _coupon!.couponType.toString(),
          'order_amount': order,
          'discount_amount': _discount ?? 0.0,
          'store_id': storeID ?? -1,
          'free_delivery': _freeDelivery,
        },
      );
    } else {
      _discount = 0.0;
      await FirebaseAnalytics.instance.logEvent(
        name: 'apply_coupon',
        parameters: {
          'coupon_code': coupon,
          'result': 'invalid_or_not_applicable',
          'order_amount': order,
          'store_id': storeID ?? -1,
        },
      );
    }

    _isLoading = false;
    update();
    return _discount;
  }

  void _processFreeDeliveryCoupon(double deliveryCharge, double order) {
    if (deliveryCharge > 0) {
      if (_coupon!.minPurchase! <= order) {
        _discount = 0;
        _freeDelivery = true;
      } else {
        showCustomSnackBar(
            '${'the_minimum_item_purchase_amount_for_this_coupon_is'.tr} '
            '${PriceConverter.convertPrice(_coupon!.minPurchase)} '
            '${'but_you_have'.tr} ${PriceConverter.convertPrice(order)}');
        _coupon = null;
        _discount = 0;
      }
    } else {
      showCustomSnackBar('invalid_code_or'.tr);
    }
  }

  void _processCoupon(double order) {
    if (_coupon!.minPurchase != null && _coupon!.minPurchase! <= order) {
      if (_coupon!.discountType == 'percent') {
        if (_coupon!.maxDiscount != null && _coupon!.maxDiscount! > 0) {
          _discount = (_coupon!.discount! * order / 100) < _coupon!.maxDiscount!
              ? (_coupon!.discount! * order / 100)
              : _coupon!.maxDiscount;
        } else {
          _discount = _coupon!.discount! * order / 100;
        }
      } else {
        _discount = _coupon!.discount;
      }
    } else {
      _discount = 0.0;
      showCustomSnackBar(
          '${'the_minimum_item_purchase_amount_for_this_coupon_is'.tr} '
          '${PriceConverter.convertPrice(_coupon!.minPurchase)} '
          '${'but_you_have'.tr} ${PriceConverter.convertPrice(order)}');
    }
  }

  //------------------------
  // Taxi Coupon Apply
  //------------------------
  Future<double?> applyTaxiCoupon(
      String coupon, double orderAmount, int? providerId) async {
    _isLoading = true;
    _discount = 0;
    update();

    CouponModel? taxiCouponModel =
        await couponServiceInterface.applyTaxiCoupon(coupon, providerId);

    if (taxiCouponModel != null) {
      _coupon = taxiCouponModel;
      if (_coupon!.minPurchase != null && _coupon!.minPurchase! < orderAmount) {
        if (_coupon!.discountType == 'percent') {
          if (_coupon!.maxDiscount != null && _coupon!.maxDiscount! > 0) {
            _discount =
                (_coupon!.discount! * orderAmount / 100) < _coupon!.maxDiscount!
                    ? (_coupon!.discount! * orderAmount / 100)
                    : _coupon!.maxDiscount;
          } else {
            _discount = _coupon!.discount! * orderAmount / 100;
          }
        } else {
          _discount = _coupon!.discount;
        }
      } else {
        _discount = 0.0;
      }
      try {
        Get.find<MetaAnalyticsService>().applyCoupon(coupon: _coupon!.code ?? coupon);
      } catch(e) {}
      await FirebaseAnalytics.instance.logEvent(
        name: 'apply_coupon',
        parameters: {
          'coupon_code': _coupon!.code ?? coupon,
          'coupon_type': _coupon!.couponType.toString(),
          'order_amount': orderAmount,
          'discount_amount': _discount ?? 0.0,
          'provider_id': providerId ?? -1,
          'is_taxi_coupon': true,
        },
      );
    } else {
      await FirebaseAnalytics.instance.logEvent(
        name: 'apply_coupon',
        parameters: {
          'coupon_code': coupon,
          'result': 'invalid_or_not_applicable',
          'order_amount': orderAmount,
          'provider_id': providerId ?? -1,
          'is_taxi_coupon': true,
        },
      );
    }

    _isLoading = false;
    update();
    return _discount;
  }

  //------------------------
  // Reset
  //------------------------
  void removeCouponData(bool notify) {
    // Log remove_coupon if there was a coupon applied
    if (_coupon != null) {
      FirebaseAnalytics.instance.logEvent(
        name: 'remove_coupon',
        parameters: {
          'coupon_code': _coupon!.code.toString(),
          'discount_amount': _discount ?? 0.0,
        },
      );
    } else {
      // optional: log generic remove_coupon
      FirebaseAnalytics.instance.logEvent(
        name: 'remove_coupon',
        parameters: {'coupon_code': 0, 'discount_amount': 0.0},
      );
    }

    _coupon = null;
    _isLoading = false;
    _discount = 0.0;
    _freeDelivery = false;

    if (notify) update();
  }
}
