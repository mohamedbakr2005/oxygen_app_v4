import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/business/domain/models/business_plan_body.dart';
import 'package:Oxygen_Mart/features/business/domain/services/business_service_interface.dart';

class BusinessController extends GetxController implements GetxService {
  final BusinessServiceInterface businessServiceInterface;
  BusinessController({required this.businessServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _businessPlanStatus = 'business';
  String get businessPlanStatus => _businessPlanStatus;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  void changeDigitalPaymentName(String? name, {bool canUpdate = true}) {
    _digitalPaymentName = name;
    if (canUpdate) {
      update();
    }
  }

  void setPaymentIndex(int index) {
    _paymentIndex = index;
    update();
  }

  Future<void> submitBusinessPlan({
    required int storeId,
    required int? packageId,
  }) async {
    _isLoading = true;
    update();

    if (packageId != null) {
      // 🔥 (1) subscription_started
      FirebaseAnalytics.instance.logEvent(
        name: 'subscription_started',
        parameters: {
          'store_id': storeId,
          'package_id': packageId,
          'payment_method':
              _paymentIndex == 0 ? 'free_trial' : _digitalPaymentName ?? '',
        },
      );

      // 🔥 (2) offline_payment_started (index 2 = Offline)
      if (_paymentIndex == 2) {
        FirebaseAnalytics.instance.logEvent(
          name: 'offline_payment_started',
          parameters: {
            'store_id': storeId,
            'package_id': packageId,
          },
        );
      }

      _businessPlanStatus = 'payment';

      // Call API
      _businessPlanStatus =
          await businessServiceInterface.processesBusinessPlan(
        _businessPlanStatus,
        _paymentIndex,
        storeId,
        _digitalPaymentName,
        packageId,
      );

      // 🔥 (3) subscription_failed
      if (_businessPlanStatus != 'success') {
        FirebaseAnalytics.instance.logEvent(
          name: 'subscription_failed',
          parameters: {
            'store_id': storeId,
            'package_id': packageId,
            'payment_method': _digitalPaymentName.toString(),
            'status': _businessPlanStatus,
          },
        );
      }
    } else {
      // Free commission setup
      String businessPlan = 'commission';
      await businessServiceInterface.setUpBusinessPlan(
        BusinessPlanBody(
          businessPlan: businessPlan,
          storeId: storeId.toString(),
        ),
        _digitalPaymentName,
        businessPlanStatus,
        storeId,
      );
    }

    _isLoading = false;
    update();
  }
}
