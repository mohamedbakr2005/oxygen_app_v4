import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class AddressHelper {
  static Future<bool> saveUserAddressInSharedPref(AddressModel address) async {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    String userAddress = jsonEncode(address.toJson());
    Get.find<ApiClient>().updateHeader(
      sharedPreferences.getString(AppConstants.token),
      address.zoneIds,
      [],
      sharedPreferences.getString(AppConstants.languageCode),
      Get.find<SplashController>().module?.id ??
          Get.find<SplashController>().cacheModule?.id,
      address.latitude,
      address.longitude,
    );
    return await sharedPreferences.setString(
        AppConstants.userAddress, userAddress);
  }

  static AddressModel? getUserAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    final jsonString = sharedPreferences.getString(AppConstants.userAddress);

    if (jsonString == null) {
      return null; // مفيش عنوان محفوظ → رجّع null عادي
    }

    try {
      return AddressModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Address catch exception: $e');
      return null;
    }
  }

  static bool clearAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }
}
