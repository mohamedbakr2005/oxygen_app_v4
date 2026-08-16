import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/category/domain/services/category_service_interface.dart';
import 'package:Oxygen_Mart/features/service_module/request_service/domain/services/requested_service_service_interface.dart';

class RequestedServiceController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  final RequestedServiceServiceInterface requestedServiceServiceInterface;

  RequestedServiceController({required this.categoryServiceInterface, required this.requestedServiceServiceInterface});
}
