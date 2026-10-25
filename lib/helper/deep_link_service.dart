import 'dart:async';

import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/item/domain/services/item_service_interface.dart';
import 'package:Oxygen_Mart/features/item/screens/item_details_screen.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/deep_link_parser.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DeepLinkService extends GetxService {
  static const Duration _duplicateWindow = Duration(seconds: 3);

  final AppLinks _appLinks;

  DeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  bool _initialized = false;
  bool _homeReady = false;
  bool _homeDataReady = false;
  bool _navigationLocked = false;
  int? _pendingProductId;
  String? _lastQueuedKey;
  DateTime? _lastQueuedAt;
  String? _lastHandledKey;
  DateTime? _lastHandledAt;

  int? get pendingProductId => _pendingProductId;
  bool get isHomeReady => _homeReady;
  bool get isHomeDataReady => _homeDataReady;

  @visibleForTesting
  void queueFromUriForTesting(Uri? uri) => _queueFromUri(uri);

  @visibleForTesting
  void setHomeReadyForTesting(bool value) => _homeReady = value;

  @visibleForTesting
  void setHomeDataReadyForTesting(bool value) => _homeDataReady = value;

  @visibleForTesting
  void resetStateForTesting() {
    _initialized = false;
    _homeReady = false;
    _homeDataReady = false;
    _navigationLocked = false;
    _pendingProductId = null;
    _lastQueuedKey = null;
    _lastQueuedAt = null;
    _lastHandledKey = null;
    _lastHandledAt = null;
  }

  Future<void> init() async {
    if (_initialized || GetPlatform.isWeb) {
      return;
    }

    _initialized = true;

    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        if (kDebugMode) {
          debugPrint('[DEEP LINK] Cold-start initial link received: $initialUri');
        }
        _queueFromUri(initialUri);
      }
    } catch (error) {
      debugPrint('[DEEP LINK] Initial link error: $error');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        if (kDebugMode) {
          debugPrint('[DEEP LINK] Warm-start stream link received: $uri');
        }
        _queueFromUri(uri);
      },
      onError: (Object error) {
        debugPrint('[DEEP LINK] Stream error: $error');
      },
    );
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  /// Called by HomeScreen when its first frame has rendered and navigator is active.
  void onHomeFirstFrameRendered() {
    _homeReady = true;
    if (_pendingProductId != null) {
      if (kDebugMode) {
        debugPrint('[DEEP LINK] onHomeFirstFrameRendered: pending product $_pendingProductId');
      }
      unawaited(_tryOpenPendingProduct());
    }
  }

  /// Called by HomeScreen when its initial loadData finishes and all APIs are resolved.
  void onHomeDataLoaded() {
    _homeDataReady = true;
    if (_pendingProductId != null) {
      if (kDebugMode) {
        debugPrint('[DEEP LINK] onHomeDataLoaded: pending product $_pendingProductId');
      }
      unawaited(_tryOpenPendingProduct());
    }
  }

  void _queueFromUri(Uri? uri) {
    final int? productId = DeepLinkParser.parseProductId(uri);
    if (productId == null) {
      if (kDebugMode && uri != null) {
        debugPrint('[DEEP LINK] Ignored non-product or invalid URI: $uri');
      }
      return;
    }

    if (_isCurrentProductRoute(productId)) {
      if (kDebugMode) {
        debugPrint('[DEEP LINK] Product $productId is already currently active. Suppressing duplicate navigation.');
      }
      _rememberHandled(productId);
      return;
    }

    final String eventKey = _eventKey(productId);
    if (_isDuplicate(eventKey)) {
      if (kDebugMode) {
        debugPrint('[DEEP LINK] Duplicate event within duplicate window suppressed for key $eventKey');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[DEEP LINK] Queued product ID $productId from URI $uri');
    }

    _pendingProductId = productId;
    _lastQueuedKey = eventKey;
    _lastQueuedAt = DateTime.now();

    if (_shouldResetToHome()) {
      if (kDebugMode) {
        debugPrint('[DEEP LINK] Resetting route stack to Home before opening product $productId');
      }
      _homeReady = false;
      _homeDataReady = false;
      Get.offAllNamed(RouteHelper.getInitialRoute());
      return;
    }

    unawaited(_tryOpenPendingProduct());
  }

  Future<void> _tryOpenPendingProduct() async {
    if (_pendingProductId == null || _navigationLocked || !_homeReady) {
      return;
    }

    // Ensure backend configuration is loaded before navigating
    if (!_isConfigReady()) {
      if (kDebugMode) {
        debugPrint('[DEEP LINK] Config not ready yet, deferring product navigation for $_pendingProductId');
      }
      return;
    }

    final String currentRoutePath = _routePath(Get.currentRoute);
    if (currentRoutePath != RouteHelper.initial &&
        currentRoutePath != RouteHelper.main) {
      return;
    }

    final int productId = _pendingProductId!;
    if (_isCurrentProductRoute(productId)) {
      _pendingProductId = null;
      _rememberHandled(productId);
      return;
    }

    _navigationLocked = true;
    _pendingProductId = null;

    try {
      if (kDebugMode) {
        debugPrint('[DEEP LINK] Resolving product and module for: $productId');
      }

      // Step 1: Pre-fetch item to identify its module
      Item? item;
      try {
        if (Get.isRegistered<ItemServiceInterface>()) {
          item = await Get.find<ItemServiceInterface>().getItemDetails(productId);
        }
      } catch (e) {
        debugPrint('[DEEP LINK] Error pre-fetching item $productId: $e');
      }

      // Step 2: Ensure module list is loaded in SplashController
      if (Get.isRegistered<SplashController>()) {
        final splashCtrl = Get.find<SplashController>();
        if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
          try {
            await splashCtrl.getModules();
          } catch (_) {}
        }

        // Step 3: Find target module for this product
        ModuleModel? targetModule;
        if (item?.moduleId != null && splashCtrl.moduleList != null) {
          for (final m in splashCtrl.moduleList!) {
            if (m.id == item!.moduleId) {
              targetModule = m;
              break;
            }
          }
        }

        // Fallback: Default to grocery module or first available module
        if (targetModule == null && splashCtrl.moduleList != null && splashCtrl.moduleList!.isNotEmpty) {
          for (final m in splashCtrl.moduleList!) {
            if (m.moduleType == AppConstants.grocery) {
              targetModule = m;
              break;
            }
          }
          targetModule ??= splashCtrl.moduleList!.first;
        }

        // Step 4: If not already in the target module, enter it and load all its APIs so HomeScreen is fully ready
        if (targetModule != null && (splashCtrl.module == null || splashCtrl.module!.id != targetModule.id)) {
          if (kDebugMode) {
            debugPrint('[DEEP LINK] Switching to module ${targetModule.id} (${targetModule.moduleName}) and loading full home data...');
          }
          await splashCtrl.switchModuleByModel(targetModule);
          await HomeScreen.loadData(true, fromModule: true);
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }

      // Step 5: Navigate directly to product details
      if (kDebugMode) {
        debugPrint('[DEEP LINK] Navigating to product details: $productId');
      }
      await Get.toNamed(
        RouteHelper.getItemDetailsRoute(productId, false, fromDeeplink: true),
        arguments: item != null ? ItemDetailsScreen(item: item, inStorePage: false) : null,
      );
      _rememberHandled(productId);
    } catch (e) {
      debugPrint('[DEEP LINK] Navigation error for product $productId: $e');
    } finally {
      _navigationLocked = false;
    }
  }

  bool _shouldResetToHome() {
    final String currentRoutePath = _routePath(Get.currentRoute);
    if (currentRoutePath.isEmpty || currentRoutePath == RouteHelper.splash) {
      return false;
    }

    return currentRoutePath != RouteHelper.initial &&
        currentRoutePath != RouteHelper.main;
  }

  bool _isConfigReady() {
    if (!Get.isRegistered<SplashController>()) {
      return false;
    }
    final SplashController splashController = Get.find<SplashController>();
    return splashController.configModel != null;
  }

  bool _isCurrentProductRoute(int productId) {
    final Uri? currentRoute = Uri.tryParse(Get.currentRoute);
    if ((currentRoute?.path ?? '') != RouteHelper.itemDetails) {
      return false;
    }

    return int.tryParse(currentRoute?.queryParameters['id'] ?? '') == productId;
  }

  bool _isDuplicate(String eventKey) {
    final DateTime now = DateTime.now();

    final bool recentlyQueued =
        _lastQueuedKey == eventKey &&
        _lastQueuedAt != null &&
        now.difference(_lastQueuedAt!) <= _duplicateWindow;

    final bool recentlyHandled =
        _lastHandledKey == eventKey &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!) <= _duplicateWindow;

    return recentlyQueued || recentlyHandled;
  }

  void _rememberHandled(int productId) {
    _lastHandledKey = _eventKey(productId);
    _lastHandledAt = DateTime.now();
  }

  String _eventKey(int productId) => 'product:$productId';

  String _routePath(String route) {
    if (route.isEmpty) {
      return '';
    }

    return Uri.tryParse(route)?.path ?? route;
  }
}