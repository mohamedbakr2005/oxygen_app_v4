import 'dart:async';

import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/deep_link_parser.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DeepLinkService extends GetxService {
  static const Duration _duplicateWindow = Duration(seconds: 3);

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  bool _initialized = false;
  bool _homeReady = false;
  bool _navigationLocked = false;
  int? _pendingProductId;
  String? _lastQueuedKey;
  DateTime? _lastQueuedAt;
  String? _lastHandledKey;
  DateTime? _lastHandledAt;

  int? get pendingProductId => _pendingProductId;

  Future<void> init() async {
    if (_initialized || GetPlatform.isWeb) {
      return;
    }

    _initialized = true;

    try {
      _queueFromUri(await _appLinks.getInitialLink());
    } catch (error) {
      debugPrint('DeepLinkService initial link error: $error');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _queueFromUri,
      onError: (Object error) {
        debugPrint('DeepLinkService stream error: $error');
      },
    );
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  void onHomeFirstFrameRendered() {
    _homeReady = true;
    unawaited(_tryOpenPendingProduct());
  }

  void _queueFromUri(Uri? uri) {
    final int? productId = DeepLinkParser.parseProductId(uri);
    if (productId == null) {
      return;
    }

    if (_isCurrentProductRoute(productId)) {
      _rememberHandled(productId);
      return;
    }

    final String eventKey = _eventKey(productId);
    if (_isDuplicate(eventKey)) {
      return;
    }

    _pendingProductId = productId;
    _lastQueuedKey = eventKey;
    _lastQueuedAt = DateTime.now();

    if (_shouldResetToHome()) {
      _homeReady = false;
      Get.offAllNamed(RouteHelper.getInitialRoute());
      return;
    }

    unawaited(_tryOpenPendingProduct());
  }

  Future<void> _tryOpenPendingProduct() async {
    if (_pendingProductId == null || _navigationLocked || !_homeReady) {
      return;
    }

    if (!_hasReadyModule()) {
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
      await Get.toNamed(RouteHelper.getItemDetailsRoute(productId, false));
      _rememberHandled(productId);
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

  bool _hasReadyModule() {
    final SplashController splashController = Get.find<SplashController>();
    return splashController.module?.id != null ||
        splashController.cacheModule?.id != null ||
        splashController.configModel?.module?.id != null;
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