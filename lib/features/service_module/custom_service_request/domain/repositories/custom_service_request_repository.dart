import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/features/service_module/custom_service_request/domain/repositories/custom_service_request_repository_interface.dart';

class CustomServiceRequestRepository implements CustomServiceRequestRepositoryInterface {
  final ApiClient apiClient;
  CustomServiceRequestRepository({required this.apiClient});
}
