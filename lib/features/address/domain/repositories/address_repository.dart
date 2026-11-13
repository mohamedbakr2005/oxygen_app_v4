import 'package:get/get_connect/connect.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/address/domain/repositories/address_repository_interface.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class AddressRepository implements AddressRepositoryInterface<AddressModel> {
  final ApiClient apiClient;

  AddressRepository({required this.apiClient});

  @override
  Future add(AddressModel addressModel) async {
    return await _addAddress(addressModel);
  }

  Future<ResponseModel> _addAddress(AddressModel addressModel) async {
    Response response = await apiClient.postData(
        AppConstants.addAddressUri, addressModel.toJson(),
        handleError: false);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      final String? message = (response.body is Map ? response.body["message"] : null) ?? response.statusText;
      List<int> zoneIds = [];
      for (final dynamic z in ResponseParser.listOrEmpty(response.body, legacyKey: 'zone_ids')) {
        zoneIds.add(z is int ? z : int.tryParse(z.toString()) ?? 0);
      }
      return ResponseModel(true, message, zoneIds: zoneIds);
    } else {
      return ResponseModel(
          false,
          response.statusText == 'Out of coverage!'
              ? 'service_not_available_in_this_area'.tr
              : response.statusText);
    }
  }

  @override
  Future delete(int? id) async {
    return await _removeAddressByID(id);
  }

  Future<ResponseModel> _removeAddressByID(int? id) async {
    Response response = await apiClient.postData(
        '${AppConstants.removeAddressUri}$id', {"_method": "delete"},
        handleError: false);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      final String? message = (response.body is Map ? response.body['message'] : null) ?? response.statusText;
      return ResponseModel(true, message);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async {
    return await _getAllAddress();
  }

  Future<List<AddressModel>?> _getAllAddress() async {
    List<AddressModel>? addressList;
    Response response = await apiClient.getData(AppConstants.addressListUri);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      addressList = [];
      for (final dynamic address in ResponseParser.listOrEmpty(response.body, legacyKey: 'addresses')) {
        addressList.add(AddressModel.fromJson(address));
      }
    }
    return addressList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) async {
    return await _updateAddress(body, id);
  }

  Future<ResponseModel> _updateAddress(
      Map<String, dynamic> addressBody, int? addressId) async {
    Response response = await apiClient.putData(
        '${AppConstants.updateAddressUri}$addressId', addressBody);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      final String? message = (response.body is Map ? response.body["message"] : null) ?? response.statusText;
      return ResponseModel(true, message);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }
}
