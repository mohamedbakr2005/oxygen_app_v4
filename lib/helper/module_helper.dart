import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/config_model.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class ModuleHelper {
  static ModuleModel? getModule() {
    return Get.find<SplashController>().module;
  }

  static ModuleModel? getCacheModule() {
    return Get.find<SplashController>().cacheModule;
  }

  static Module getModuleConfig(String? moduleType) {
    return Get.find<SplashController>().getModuleConfig(moduleType);
  }

  static String? _activeModuleType() {
    if (!Get.isRegistered<SplashController>()) return null;
    return getModule()?.moduleType ?? getCacheModule()?.moduleType;
  }

  static String proMinSpendLabel({String? moduleType, required String fallbackKey}) {
    final String? type = moduleType ?? _activeModuleType();
    switch (type) {
      case AppConstants.parcel:
        return 'min_delivery_fee'.tr;
      case AppConstants.taxi:
        return 'min_rental_trip'.tr;
      case AppConstants.ride:
        return 'min_ride'.tr;
      case 'service':
        return 'min_booking'.tr;
      default:
        return fallbackKey.tr;
    }
  }

  // A food store is a restaurant to the customer; every other module sells from a store.
  static String storeDiscountAppliedLabel({String? moduleType}) {
    final String? type = moduleType ?? _activeModuleType();
    return type == AppConstants.food ? 'restaurant_discount_applied'.tr : 'store_discount_applied'.tr;
  }

  static bool isBookingModule({String? moduleType}) =>
      (moduleType ?? _activeModuleType()) == 'service';

  /// Single source of truth for whether the product-bundle feature is live for
  /// a module — admin's `product_bundle_status` switch plus its per-module
  /// allow-list, both on [ConfigModel].
  static bool isBundleEnabled({String? moduleType}) {
    if (!Get.isRegistered<SplashController>()) return false;
    final ConfigModel? config = Get.find<SplashController>().configModel;
    final String? type = moduleType ?? getModule()?.moduleType ?? getCacheModule()?.moduleType;
    return (config?.productBundleStatus ?? false) && type != null && (config?.productBundleModuleTypes?.contains(type) ?? false);
  }

  static ModuleModel? getModuleByType(String moduleType) {
    final List<ModuleModel> modules = Get.find<SplashController>().moduleList ?? [];
    for (final ModuleModel module in modules) {
      if (module.moduleType == moduleType) {
        return module;
      }
    }
    return null;
  }

  // Single source of truth for module tab labels so every screen that lists
  // modules (dashboard tabs, my-items tabs, etc.) shows the exact same name.
  static String moduleDisplayName(String moduleType, {String? moduleName}) {
    final String? name = moduleName ?? getModuleByType(moduleType)?.moduleName;
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }
    return _fallbackModuleDisplayName(moduleType);
  }

  static String _fallbackModuleDisplayName(String moduleType) {
    if (moduleType == AppConstants.food) {
      return 'Food';
    } else if (moduleType == AppConstants.grocery) {
      return 'Grocery';
    } else if (moduleType == AppConstants.ecommerce) {
      return 'Shop';
    } else if (moduleType == AppConstants.pharmacy) {
      return 'Pharmacy';
    }
    return moduleType.isNotEmpty ? moduleType : 'Module';
  }
}
