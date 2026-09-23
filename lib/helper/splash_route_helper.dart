import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/maintance_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

// class SplashRouteHelper{

void route({NotificationBodyModel? body}) {
  double? minimumVersion = _getMinimumVersion();
  bool isMaintenanceMode = MaintenanceHelper.isMaintenanceEnable();
  bool needsUpdate = AppConstants.appVersion < minimumVersion!;

  if (kDebugMode) {
    print('[SPLASH ROUTE] route() called: needsUpdate: $needsUpdate, isMaintenanceMode: $isMaintenanceMode, currentRoute: ${Get.currentRoute}, authState: ${AuthHelper.isLoggedIn() ? 'authenticated' : (AuthHelper.isGuestLoggedIn() ? 'guest' : 'unauthenticated')}');
  }

  if (needsUpdate || isMaintenanceMode) {
    Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
  } else if (!GetPlatform.isWeb) {
    if (body != null) {
      _forNotificationRouteProcess(body);
    } else {
      _handleUserRouting();
    }
  } else if (GetPlatform.isWeb) {
    Get.offNamed(RouteHelper.getInitialRoute());
  }
}

double? _getMinimumVersion() {
  if (GetPlatform.isAndroid) {
    return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
  } else if (GetPlatform.isIOS) {
    return Get.find<SplashController>().configModel!.appMinimumVersionIos;
  }
  return 0;
}

void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
  final notificationType = notificationBody?.notificationType;

  final Map<NotificationType, Function> notificationActions = {
    NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(
        notificationBody!.orderId,
        fromNotification: true)),
    NotificationType.block: () =>
        Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
    NotificationType.unblock: () =>
        Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
    NotificationType.message: () => Get.toNamed(RouteHelper.getChatRoute(
        notificationBody: notificationBody,
        conversationID: notificationBody!.conversationId,
        fromNotification: true)),
    NotificationType.otp: () => null,
    NotificationType.add_fund: () =>
        Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
    NotificationType.referral_earn: () =>
        Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
    NotificationType.cashback: () =>
        Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
    NotificationType.loyalty_point: () =>
        Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
    NotificationType.general: () =>
        Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
  };

  notificationActions[notificationType]?.call();
}

Future<void> _forLoggedInUserRouteProcess() async {
  Get.find<AuthController>().updateToken();
  if (AddressHelper.getUserAddressFromSharedPref() != null) {
    if (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() != AppConstants.ride) {
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if (kDebugMode) {
      print('[DASHBOARD NAVIGATION] reason: splash user routing for logged in user -> currentRoute: ${Get.currentRoute}, navigating to: ${RouteHelper.getInitialRoute(fromSplash: true)}');
    }
    Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  } else {
    Get.find<LocationController>()
        .navigateToLocationScreen('splash', offNamed: true);
  }
}

void _newlyRegisteredRouteProcess() {
  if (AppConstants.languages.length > 1) {
    Get.offNamed(RouteHelper.getLanguageRoute('splash'));
  } else {
    Get.offNamed(RouteHelper.getOnBoardingRoute());
  }
}

void _forGuestUserRouteProcess() {
  if (AddressHelper.getUserAddressFromSharedPref() != null) {
    if (kDebugMode) {
      print('[DASHBOARD NAVIGATION] reason: splash user routing for guest user -> currentRoute: ${Get.currentRoute}, navigating to: ${RouteHelper.getInitialRoute(fromSplash: true)}');
    }
    Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  } else {
    Get.find<LocationController>()
        .navigateToLocationScreen('splash', offNamed: true);
  }
}

Future<void> _handleUserRouting() async {
  if (AuthHelper.isLoggedIn()) {
    _forLoggedInUserRouteProcess();
  } else if (Get.find<SplashController>().showIntro() == true) {
    _newlyRegisteredRouteProcess();
  } else if (AuthHelper.isGuestLoggedIn()) {
    _forGuestUserRouteProcess();
  } else {
    await Get.find<AuthController>().guestLogin();
    _forGuestUserRouteProcess();
  }
}
// }