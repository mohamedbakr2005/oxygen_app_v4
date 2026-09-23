import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';

class MaintenanceHelper{
  static bool isMaintenanceEnable() {
    bool isMaintenanceMode = Get.find<SplashController>().configModel?.maintenanceMode ?? false;
    String platform = GetPlatform.isWeb ? 'user_web_app' : 'user_mobile_app';

    bool isInMaintenance = isMaintenanceMode && Get.find<SplashController>().configModel?.maintenanceModeData != null
        && (Get.find<SplashController>().configModel?.maintenanceModeData?.maintenanceSystemSetup?.contains(platform) ?? false);

    return isInMaintenance;
  }
}
