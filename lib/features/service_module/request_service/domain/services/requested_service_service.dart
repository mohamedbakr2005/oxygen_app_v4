import 'package:Oxygen_Mart/features/service_module/request_service/domain/repositories/requested_service_repository_interface.dart';
import 'package:Oxygen_Mart/features/service_module/request_service/domain/services/requested_service_service_interface.dart';

class RequestedServiceService implements RequestedServiceServiceInterface {
  final RequestedServiceRepositoryInterface requestedServiceRepositoryInterface;
  RequestedServiceService({required this.requestedServiceRepositoryInterface});
}
