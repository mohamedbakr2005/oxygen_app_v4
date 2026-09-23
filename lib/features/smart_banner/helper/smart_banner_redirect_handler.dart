import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/features/offer/offer_screen.dart';
import 'package:Oxygen_Mart/features/smart_banner/domain/models/smart_banner_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';

class SmartBannerRedirectHandler {
  const SmartBannerRedirectHandler._();

  static void handle(SmartBanner banner) {
    switch (banner.redirectType) {
      case 'module_home':
        _handleModuleHome(banner);
        return;

      case 'store_page':
        _handleStorePage(banner);
        return;

      case 'category':
        _handleCategory(banner);
        return;

      case 'offer_page':
        Get.to(() => const OfferScreen());
        return;

      default:
        return;
    }
  }

  static void _handleModuleHome(SmartBanner banner) {
    final int? moduleId = banner.moduleId;
    if (moduleId == null) return;
    final SplashController splash = Get.find<SplashController>();
    final List<ModuleModel>? modules = splash.moduleList;
    if (modules == null || modules.isEmpty) return;
    final ModuleModel? target = modules.firstWhereOrNull((ModuleModel m) => m.id == moduleId);
    if (target != null) {
      splash.switchModule(target);
    }
  }

  static void _handleStorePage(SmartBanner banner) {
    if (banner.redirectTargetId == null) {
      return;
    }
    if (Get.find<SplashController>().moduleList != null) {
      for (ModuleModel module in Get.find<SplashController>().moduleList!) {
        if (module.id == banner.moduleId) {
          Get.find<SplashController>().setModule(module);
          break;
        }
      }
    }
    Get.toNamed(RouteHelper.getStoreRoute(
      id: banner.redirectTargetId,
      page: 'store',
      slug: 'store_${banner.redirectTargetId}',
      moduleId: banner.moduleId?.toString(),
    ));
  }

  static void _handleCategory(SmartBanner banner) {
    if (banner.redirectTargetId == null) {
      return;
    }
    if (Get.find<SplashController>().moduleList != null) {
      for (ModuleModel module in Get.find<SplashController>().moduleList!) {
        if (module.id == banner.moduleId) {
          Get.find<SplashController>().setModule(module);
          break;
        }
      }
    }
    Get.toNamed(RouteHelper.getCategoryItemRoute(
      banner.redirectTargetId, banner.title ?? '',
      moduleId: banner.moduleId,
      slug: 'category_${banner.redirectTargetId}',
    ));
  }
}
