import 'dart:async';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/common/models/config_model.dart' hide DownloadUserAppLinks;
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/campaign_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/smart_banner/controllers/smart_banner_controller.dart';
import 'package:Oxygen_Mart/features/splash/domain/models/app_download_section_model.dart';
import 'package:Oxygen_Mart/features/splash/domain/models/landing_model.dart' hide DownloadUserAppLinks;
import 'package:Oxygen_Mart/features/splash/domain/services/splash_service_interface.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/maintance_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/helper/splash_route_helper.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool get proStaus => _configModel?.proMemberStatus ?? false;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  ModuleModel? _module;
  ModuleModel? get module => _module;

  ModuleModel? _cacheModule;
  ModuleModel? get cacheModule => _cacheModule;

  List<ModuleModel>? _moduleList;
  List<ModuleModel>? get moduleList => _moduleList;

  int _moduleIndex = 0;
  int get moduleIndex => _moduleIndex;

  Map<String, dynamic>? _data = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedModuleIndex = 0;
  int get selectedModuleIndex => _selectedModuleIndex;

  int _moduleSwitchToken = 0;
  Timer? _moduleLoadDebounce;

  LandingModel? _landingModel;
  LandingModel? get landingModel => _landingModel;

  bool _savedCookiesData = false;
  bool get savedCookiesData => _savedCookiesData;

  bool _webSuggestedLocation = false;
  bool get webSuggestedLocation => _webSuggestedLocation;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  bool _showReferBottomSheet = false;
  bool get showReferBottomSheet => _showReferBottomSheet;

  Uri? _deeplinkRoute;
  Uri? get deeplinkRoute => _deeplinkRoute;

  void setDeeplink(Uri? route) {
    _deeplinkRoute = route;
  }

  bool _splashRouted = false;

  DateTime get currentTime => DateTime.now();

  void selectModuleIndex(int index, {bool canUpdate = true}) {
    _selectedModuleIndex = index;
    if (canUpdate) {
      update();
    }
  }

  void selectModuleByTabIndex(int tabIndex) {
    selectModuleIndex(tabIndex);
    if (tabIndex == 0) return;
    final int moduleListIndex = tabIndex - 1;
    if (_moduleList != null && moduleListIndex >= 0 && moduleListIndex < _moduleList!.length) {
      switchModule(moduleListIndex, true);
    }
  }

  void selectHomeModule() {
    selectModuleIndex(0);
    if (!ResponsiveHelper.isDesktop(Get.context) &&
        _module != null &&
        _configModel?.module == null &&
        _moduleList != null &&
        _moduleList!.length != 1) {
      removeModule();
      Get.find<StoreController>().resetStoreData();
    }
  }

  Future<void> getConfigData({
    bool handleMaintenanceMode = false,
    NotificationBodyModel? notificationBody,
    bool loadModuleData = false,
    bool loadLandingData = false,
    DataSourceEnum source = DataSourceEnum.local,
    bool fromMainFunction = false,
    bool fromDemoReset = false,
    bool canRoute = true,
    bool fromSplash = false,
  }) async {
    _hasConnection = true;
    _moduleIndex = 0;
    Response response;
    if (source == DataSourceEnum.local && !fromDemoReset) {
      response = await splashServiceInterface.getConfigData(source: DataSourceEnum.local);
      _handleConfigResponse(response, handleMaintenanceMode, loadModuleData, loadLandingData, fromMainFunction, fromDemoReset, notificationBody, canRoute, fromSplash);
      getConfigData(handleMaintenanceMode: handleMaintenanceMode, loadModuleData: loadModuleData, loadLandingData: loadLandingData, source: DataSourceEnum.client, notificationBody: notificationBody, canRoute: canRoute, fromSplash: fromSplash);
    } else {
      response = await splashServiceInterface.getConfigData(source: DataSourceEnum.client);
      _handleConfigResponse(response, handleMaintenanceMode, loadModuleData, loadLandingData, fromMainFunction, fromDemoReset, notificationBody, canRoute, fromSplash);
    }
  }

  Future<void> _handleConfigResponse(
    Response response,
    bool handleMaintenanceMode,
    bool loadModuleData,
    bool loadLandingData,
    bool fromMainFunction,
    bool fromDemoReset,
    NotificationBodyModel? notificationBody,
    bool canRoute,
    bool fromSplash,
  ) async {
    if (response.statusCode == 200) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      if (_configModel!.module != null) {
        setModule(_configModel!.module);
      } else if (GetPlatform.isWeb || (loadModuleData && _module != null)) {
        setModule(GetPlatform.isWeb ? splashServiceInterface.getModule() : _module);
      }

      if (kDebugMode) {
        print('[SPLASH CONFIG] deeplink url: $_deeplinkRoute and canRoute: $canRoute, fromSplash: $fromSplash, fromMainFunction: $fromMainFunction, currentRoute: ${Get.currentRoute}');
      }
      if (!canRoute || _deeplinkRoute != null) {
        return;
      }

      bool isMaintenanceMode = _configModel!.maintenanceMode ?? false;
      bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();

      splashServiceInterface.handleInitialTopicSubscription();
      if (isInMaintenance && handleMaintenanceMode) {
        Get.offNamed(RouteHelper.getUpdateRoute(false));
        _onRemoveLoader();
        update();
        return;
      } else if (handleMaintenanceMode && ((Get.currentRoute.contains(RouteHelper.update) && !isMaintenanceMode) || !isInMaintenance)) {
        Get.offNamed(RouteHelper.getInitialRoute());
      }

      if (fromMainFunction) {
        if (kDebugMode) {
          print('[SPLASH] fromMainFunction routing executed (no dashboard navigation, background sync only)');
        }
        _mainConfigRouting();
      } else if (fromDemoReset) {
        if (kDebugMode) {
          print('[DASHBOARD NAVIGATION] reason: fromDemoReset, currentRoute: ${Get.currentRoute}');
        }
        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
      } else if (!fromSplash) {
        if (kDebugMode) {
          print('[SPLASH NAVIGATION] reason: !fromSplash, currentRoute: ${Get.currentRoute}');
        }
        route(body: notificationBody);
      } else if (!_splashRouted) {
        _splashRouted = true;
        if (kDebugMode) {
          print('[SPLASH NAVIGATION] reason: initial cold-start splash routing, currentRoute: ${Get.currentRoute}');
        }
        route(body: notificationBody);
      } else {
        if (kDebugMode) {
          print('[SPLASH] Splash routing already completed (_splashRouted=true), suppressing unexpected dashboard navigation. currentRoute: ${Get.currentRoute}');
        }
      }
      _onRemoveLoader();
    } else {
      if (response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
    }
    update();
  }

  Future<void> _mainConfigRouting() async {
    if (GetPlatform.isWeb) {
      bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();
      if (isInMaintenance) {
        Get.offNamed(RouteHelper.getUpdateRoute(false));
      }
    }
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<AuthController>().updateToken();
      if (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() != AppConstants.ride) {
        await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      preloader.remove();
    }
  }

  Future<void> getLandingPageData() async {
    // Phase 1: local cache for instant UI
    LandingModel? localModel = await splashServiceInterface.getLandingPageData(
        source: DataSourceEnum.local);
    _prepareLandingModel(localModel);

    // Phase 2: fresh server data (one request)
    LandingModel? clientModel = await splashServiceInterface.getLandingPageData(
        source: DataSourceEnum.client);
    _prepareLandingModel(clientModel);
  }

  _prepareLandingModel(LandingModel? landingModel) {
    if (landingModel != null) {
      _landingModel = landingModel;
      hoverStates = List<bool>.generate(
          _landingModel!.availableZoneList!.length, (index) => false);
    }
    update();
  }

  void resetSplashRouted() {
    _splashRouted = false;
  }

  Future<void> initSharedData() async {
    _splashRouted = false;
    if (!GetPlatform.isWeb) {
      _module = null;
      splashServiceInterface.initSharedData();
    } else {
      _module = await splashServiceInterface.initSharedData();
    }
    _cacheModule = splashServiceInterface.getCacheModule();
    // Pure state set — no API side effects
    await setModule(_module, notify: false);
  }

  void setCacheConfigModule(ModuleModel? cacheModule) {
    _configModel!.moduleConfig!.module =
        Module.fromJson(_data!['module_config'][cacheModule!.moduleType]);
  }

  bool? showIntro() {
    return splashServiceInterface.showIntro();
  }

  void disableIntro() {
    splashServiceInterface.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  Future<void> setModule(ModuleModel? module, {bool notify = true, bool fromModuleDialog = false}) async {
    _module = module;
    splashServiceInterface.setModule(module);
    if (module != null) {
      if (kDebugMode) {
        print('[MODULE CONTEXT] Active module set: ${module.id} (${module.moduleName} - ${module.moduleType})');
      }
      if (_configModel != null && _data != null) {
        final moduleConfigData = _data!['module_config'];
        if (moduleConfigData != null &&
            moduleConfigData[module.moduleType] != null) {
          _configModel!.moduleConfig!.module =
              Module.fromJson(moduleConfigData[module.moduleType]);
        }
      }
      _cacheModule = await splashServiceInterface.setCacheModule(module);
      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && _cacheModule != null) {
        Get.find<CartController>().getAllCarts();
      }
    } else {
      if (kDebugMode) {
        print('[MODULE CONTEXT] Active module cleared (null)');
      }
    }

    if (AuthHelper.isLoggedIn()) {
      if (_module != null) {
        Get.find<HomeController>().getCashBackOfferList();
        if (Get.find<ProfileController>().userInfoModel?.proStatus ?? false) {
          Get.find<ProController>().getProActiveOffer(moduleType: module?.moduleType);
        }
        Get.find<FavouriteController>().getFavouriteList();
      }
    }

    if (notify) {
      update();
    }
  }

  Module getModuleConfig(String? moduleType) {
    if (_data == null || _data!['module_config'] == null || moduleType == null) {
      return Module(newVariation: false);
    }

    if (!_data!['module_config'].containsKey(moduleType)) {
      return Module(newVariation: false);
    }

    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    module.newVariation = moduleType == 'food';
    return module;
  }

  Future<bool> getModules({Map<String, String>? headers, DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _moduleIndex = 0;
    List<ModuleModel>? moduleList;
    if (dataSource == DataSourceEnum.local) {
      moduleList = await splashServiceInterface.getModules(headers: headers, source: DataSourceEnum.local);
      getModules(headers: headers, dataSource: DataSourceEnum.client);
      return _prepareModuleList(moduleList);
    } else {
      moduleList = await splashServiceInterface.getModules(headers: headers, source: DataSourceEnum.client);
      return _prepareModuleList(moduleList);
    }
  }

  bool _prepareModuleList(List<ModuleModel>? moduleList) {
    if (moduleList != null) {
      _moduleList = [];
      _moduleList!.addAll(moduleList);
      if (kDebugMode) {
        print('[MODULES LOADED] Count: ${_moduleList!.length}');
        for (var m in _moduleList!) {
          print(' -> ${m.id}: ${m.moduleName} (${m.moduleType})');
        }
      }
      update();
      return true;
    } else {
      update();
      return false;
    }
  }

  Future<void> _showInterestPage() async {
    final user = Get.find<ProfileController>().userInfoModel;
    final ModuleModel? module = _module;
    if (user == null || module == null) {
      return;
    }
    final String moduleType = module.moduleType?.toString() ?? '';
    final bool isInterestModule = moduleType == AppConstants.food ||
        moduleType == AppConstants.pharmacy ||
        moduleType == AppConstants.grocery ||
        moduleType == AppConstants.ecommerce;
    final bool alreadySelected =
        user.selectedModuleForInterest?.contains(module.id) ?? false;
    if (!isInterestModule || alreadySelected) {
      return;
    }

    await Get.find<CategoryController>()
        .getCategoryList(true, allCategory: false)
        .then((_) async {
      if (Get.find<CategoryController>().categoryList != null &&
          Get.find<CategoryController>().categoryList!.isNotEmpty) {
        await Get.toNamed(RouteHelper.getInterestRoute());
      }
    });
  }

  void switchModule(dynamic moduleOrIndex, [bool? fromPhone]) async {
    ModuleModel? targetModule;
    if (moduleOrIndex is int) {
      if (_moduleList != null && moduleOrIndex >= 0 && moduleOrIndex < _moduleList!.length) {
        targetModule = _moduleList![moduleOrIndex];
      }
    } else if (moduleOrIndex is ModuleModel) {
      targetModule = moduleOrIndex;
    }
    if (targetModule == null) return;
    await switchModuleByModel(targetModule);
  }

  Future<void> switchModuleByModel(ModuleModel targetModule) async {
    if (kDebugMode) {
      print('=============================================');
      print('[MODULE ENTER] Target: ${targetModule.id} (${targetModule.moduleName} - ${targetModule.moduleType}) | Current: ${_module?.id}');
      print('=============================================');
    }
    if (_module == null || _module!.id != targetModule.id) {
      final int token = ++_moduleSwitchToken;

      await setModule(targetModule);

      if (token != _moduleSwitchToken) return;

      Get.find<CartController>().getAllCarts();
      Get.find<ItemController>().clearItemLists();
      Get.find<StoreController>().clearStoreData();
      Get.find<BannerController>().clearBanner();
      Get.find<CategoryController>().clearCategoryList();
      Get.find<CampaignController>().itemAndBasicCampaignNull();
      Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);

      if (AuthHelper.isLoggedIn()) {
        Get.find<HomeController>().getCashBackOfferList();
        try {
          await _showInterestPage();
        } catch (_) {}
        if (token != _moduleSwitchToken) return;
      }

      _moduleLoadDebounce?.cancel();
      _moduleLoadDebounce = Timer(const Duration(milliseconds: 350), () {
        if (token == _moduleSwitchToken) {
          HomeScreen.loadData(true, fromModule: true);
        }
      });
    }
  }

  ModuleModel? getCacheModule() {
    return splashServiceInterface.getCacheModule();
  }

  void setModuleIndex(int index) {
    _moduleIndex = index;
    update();
  }

  Future<void> removeModule() async {
    if (kDebugMode) {
      print('=============================================');
      print('[MODULE EXIT] Leaving module: ${_module?.id} (${_module?.moduleName})');
      print('=============================================');
    }
    await setModule(null);
    Get.find<BannerController>().getFeaturedBanner();
    Get.find<SmartBannerController>().getSmartBanners(notify: false);
    getModules();
    Get.find<HomeController>().forcefullyNullCashBackOffers();
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
    Get.find<StoreController>().getFeaturedStoreList();
    Get.find<CampaignController>().itemAndBasicCampaignNull();
    if (_deeplinkRoute != null) {
      setDeeplink(null);
      HomeScreen.loadData(false);
    }
  }

  Future<void> removeCacheModule() async {
    _cacheModule = await splashServiceInterface.setCacheModule(null);
  }

  void clearDataNull(ModuleModel foundModule) {
    Get.find<CartController>().getAllCarts();
    Get.find<ItemController>().clearItemLists();
    Get.find<StoreController>().clearStoreData();
    Get.find<BannerController>().clearBanner();
    Get.find<CategoryController>().clearCategoryList();
    Get.find<CampaignController>().itemAndBasicCampaignNull();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);
  }

  Future<bool> subscribeMail(String email) async {
    _isLoading = true;
    update();
    ResponseModel responseModel =
        await splashServiceInterface.subscribeEmail(email);
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  void saveCookiesData(bool data) {
    splashServiceInterface.saveCookiesData(data);
    _savedCookiesData = true;
    update();
  }

  getCookiesData() {
    _savedCookiesData = splashServiceInterface.getSavedCookiesData();
    update();
  }

  void cookiesStatusChange(String? data) {
    splashServiceInterface.cookiesStatusChange(data);
  }

  bool getAcceptCookiesStatus(String data) =>
      splashServiceInterface.getAcceptCookiesStatus(data);

  void saveWebSuggestedLocationStatus(bool data) {
    splashServiceInterface.saveSuggestedLocationStatus(data);
    _webSuggestedLocation = true;
    update();
  }

  void getWebSuggestedLocationStatus() {
    _webSuggestedLocation = splashServiceInterface.getSuggestedLocationStatus();
  }

  void setRefreshing(bool status) {
    _isRefreshing = status;
    update();
  }

  void saveReferBottomSheetStatus(bool data) {
    splashServiceInterface.saveReferBottomSheetStatus(data);
    _showReferBottomSheet = data;
    update();
  }

  void getReferBottomSheetStatus() {
    _showReferBottomSheet = splashServiceInterface.getReferBottomSheetStatus();
  }

  var hoverStates = <bool>[];

  void setHover(int index, bool state) {
    hoverStates[index] = state;
    update();
  }

  void togglePaymentIncompleteBottomSheet(bool status) {
  }

  void savePaymentIncompleteSheetStatus(bool hide) {
  }

  AppDownloadSectionModel? _appDownloadSection;
  AppDownloadSectionModel? get appDownloadSection => _appDownloadSection;

  String? _pusherConnectionStatus;
  String? get pusherConnectionStatus => _pusherConnectionStatus;

  void setPusherStatus(String? connection) {
    _pusherConnectionStatus = connection;
  }

  Future<void> fetchAppDownloadSection() async {
    AppDownloadSectionModel? appDownloadSectionModel = await splashServiceInterface.getAppDownloadSection();
    if (appDownloadSectionModel == null) return;
    _appDownloadSection = appDownloadSectionModel;
    update();
  }

  DownloadUserAppLinks? get links => _appDownloadSection?.downloadUserAppLinks;

  String get appDownloadQrUrl {
    if (links?.appleStoreUrl?.isNotEmpty ?? false) return links!.appleStoreUrl!;
    if (links?.playstoreUrl?.isNotEmpty ?? false) return links!.playstoreUrl!;
    return '';
  }

  bool get showAppDownloadSection => (links?.playstoreUrl?.isNotEmpty ?? false) && (links?.appleStoreUrl?.isNotEmpty ?? false);
}
