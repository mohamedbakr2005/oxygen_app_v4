import 'package:Oxygen_Mart/features/service_module/service_checkout/domain/repositories/service_checkout_repository_interface.dart';
import 'package:Oxygen_Mart/features/service_module/service_checkout/domain/services/service_checkout_service_interface.dart';

class ServiceCheckoutService implements ServiceCheckoutServiceInterface {
  final ServiceCheckoutRepositoryInterface serviceCheckoutRepositoryInterface;
  ServiceCheckoutService({required this.serviceCheckoutRepositoryInterface});
}
