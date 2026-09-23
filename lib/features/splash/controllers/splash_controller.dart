import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/common/models/config_model.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/item/controllers/campaign_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/domain/models/landing_model.dart';
import 'package:Oxygen_Mart/features/splash/domain/services/splash_service_interface.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
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

  /// Guard: prevents concurrent getConfigData calls
  bool _isConfigLoading = false;

  /// Guard: prevents concurrent onModuleActivated calls
  bool _isModuleActivating = false;

  DateTime get currentTime => DateTime.now();

  void selectModuleIndex(int index) {
    _selectedModuleIndex = index;
    update();
  }

  Future<void> getConfigData(
      {NotificationBodyModel? notificationBody,
      bool loadModuleData = false,
      bool loadLandingData = false,
      bool fromMainFunction = false,
      bool fromDemoReset = false}) async {
    // Guard: prevent concurrent config loads
    if (_isConfigLoading) return;
    _isConfigLoading = true;

    _hasConnection = true;
    _moduleIndex = 0;

    try {
      // Phase 1: Serve cached data instantly for fast UI
      if (!fromDemoReset) {
        Response localResponse = await splashServiceInterface.getConfigData(
            source: DataSourceEnum.local);
        if (localResponse.statusCode == 200) {
          _data = localResponse.body;
          _configModel = ConfigModel.fromJson(localResponse.body);
          update(); // UI gets cached data immediately
        }
      }

      // Phase 2: Fetch fresh server data (ONE request only)
      Response clientResponse = await splashServiceInterface.getConfigData(
          source: DataSourceEnum.client);

      if (clientResponse.statusCode == 200) {
        _data = clientResponse.body;
        _configModel = ConfigModel.fromJson(clientResponse.body);

        // Set module (pure state, no API calls)
        if (_configModel!.module != null) {
          await setModule(_configModel!.module);
        } else if (GetPlatform.isWeb || (loadModuleData && _module != null)) {
          ModuleModel? savedModule =
              GetPlatform.isWeb ? splashServiceInterface.getModule() : _module;

          // On web: if no saved module, auto-select grocery module
          if (GetPlatform.isWeb && savedModule == null) {
            List<ModuleModel>? modules = await splashServiceInterface.getModules(
                source: DataSourceEnum.client);
            if (modules != null && modules.isNotEmpty) {
              // Try to find grocery module first, otherwise pick the first module
              ModuleModel? groceryModule;
              for (var m in modules) {
                if (m.moduleType == AppConstants.grocery) {
                  groceryModule = m;
                  break;
                }
              }
              savedModule = groceryModule ?? modules.first;
              _prepareModuleList(modules);
            }
          }

          await setModule(savedModule);
        }

        // Load module data ONCE after module is set
        if (_module != null) {
          await onModuleActivated();
        }

        if (loadLandingData) {
          await getLandingPageData();
        }

        // Routing — runs ONCE
        if (fromMainFunction) {
          _mainConfigRouting();
          route(body: notificationBody);
        } else if (fromDemoReset) {
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
        } else {
          route(body: notificationBody);
        }

        _onRemoveLoader();
      } else {
        if (clientResponse.statusText == ApiClient.noInternetMessage) {
          _hasConnection = false;
        }
      }
    } finally {
      _isConfigLoading = false;
      update();
    }
  }

  /// Routing after config is loaded from main function.
  /// Does NOT call getFavouriteList — that's handled by onModuleActivated.
  _mainConfigRouting() {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<AuthController>().updateToken();
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

  Future<void> initSharedData() async {
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

  /// PURE state setter — ZERO API calls.
  /// All downstream API calls are handled by onModuleActivated().
  Future<void> setModule(ModuleModel? module, {bool notify = true}) async {
    _module = module;
    splashServiceInterface.setModule(module);
    if (module != null) {
      if (_configModel != null && _data != null) {
        final moduleConfigData = _data!['module_config'];
        if (moduleConfigData != null &&
            moduleConfigData[module.moduleType] != null) {
          _configModel!.moduleConfig!.module =
              Module.fromJson(moduleConfigData[module.moduleType]);
        }
      }
      await splashServiceInterface.setCacheModule(module);
    }
    if (notify) {
      update();
    }
  }

  /// Single orchestrator for all post-module-set API calls.
  /// Runs ONCE per module activation — guarded against concurrent calls.
  Future<void> onModuleActivated() async {
    if (_module == null) return;
    if (_isModuleActivating) return;
    _isModuleActivating = true;

    try {
      final int? storeId = await Get.find<StoreController>().resolveAndSetActiveStoreForModule(_module!.id);

      final futures = <Future>[];

      // Cart: load for logged-in or guest users
      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          cacheModule != null) {
        futures.add(Get.find<CartController>().getCartDataOnline(storeId: storeId));
      }

      // User-specific data
      if (AuthHelper.isLoggedIn()) {
        futures.add(Get.find<HomeController>().getCashBackOfferList());
        futures.add(Get.find<FavouriteController>().getFavouriteList());
        if (Get.find<ProfileController>().userInfoModel?.proStatus ?? false) {
          futures.add(Get.find<ProController>().getProActiveOffer(moduleType: _module?.moduleType));
        }
      }

      await Future.wait(futures);
    } finally {
      _isModuleActivating = false;
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

  Future<void> getModules({Map<String, String>? headers}) async {
    _moduleIndex = 0;

    // Phase 1: local cache for instant UI
    List<ModuleModel>? localModules = await splashServiceInterface.getModules(
        headers: headers, source: DataSourceEnum.local);
    _prepareModuleList(localModules);

    // Phase 2: fresh server data (one request)
    List<ModuleModel>? clientModules = await splashServiceInterface.getModules(
        headers: headers, source: DataSourceEnum.client);
    _prepareModuleList(clientModules);
  }

  _prepareModuleList(List<ModuleModel>? moduleList) {
    if (moduleList == null) return;
    print("MODULES:++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    for (var m in moduleList) {
      print("${m.id} - ${m.moduleName} - ${m.moduleType}");
    }
    if (moduleList != null) {
      _moduleList = [];
      _moduleList!.addAll(moduleList);
    }
    update();
  }

  Future<void> _showInterestPage() async {
    if (!Get.find<ProfileController>()
            .userInfoModel!
            .selectedModuleForInterest!
            .contains(Get.find<SplashController>().module!.id) &&
        (Get.find<SplashController>().module!.moduleType == 'food' ||
            Get.find<SplashController>().module!.moduleType == 'grocery' ||
            Get.find<SplashController>().module!.moduleType == 'ecommerce')) {
      print('interest page${Get.find<SplashController>().module?.toJson()}');
      await Get.toNamed(RouteHelper.getInterestRoute());
    }
  }

  Future<void> switchModule(ModuleModel newModule) async {
    if (_module == null || _module!.id != newModule.id) {
      if (kDebugMode) {
        print('--- SWITCHING MODULE ---');
        print('Old Module: ${_module?.moduleName}');
        print('New Module: ${newModule.moduleName}');
      }

      // 1. Pure state set
      await setModule(newModule);

      // 2. Clear stale data from previous module
      Get.find<ItemController>().clearItemLists();
      Get.find<StoreController>().clearStoreData(); // New clear method
      Get.find<HomeController>().clearModuleData();
      Get.find<BannerController>().clearBanner();
      Get.find<CategoryController>().clearCategoryList();
      Get.find<CampaignController>().itemAndBasicCampaignNull();
      Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: true);
      Get.find<HomeController>().forcefullyNullCashBackOffers();

      // 3. Fetch specific zone config based on new module headers
      await Get.find<LocationController>().syncZoneData();

      if (kDebugMode) {
        print('Zone ID after sync: ${Get.find<LocationController>().zoneID}');
      }

      // 4. Load new module data ONCE via orchestrator (no duplicates)
      await onModuleActivated();

      // 5. Force UI rebuild by tearing down all screens and returning to dash
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
  }

  int getCacheModule() {
    return splashServiceInterface.getCacheModule()?.id ?? 0;
  }

  void setModuleIndex(int index) {
    _moduleIndex = index;
    update();
  }

  Future<void> removeModule() async {
    await setModule(null);
    Get.find<HomeController>().forcefullyNullCashBackOffers();
    Get.find<CampaignController>().itemAndBasicCampaignNull();

    // These are legitimate — they fetch module-selector screen data
    await Future.wait([
      Get.find<BannerController>().getFeaturedBanner(),
      getModules(),
      Get.find<StoreController>().getFeaturedStoreList(),
      if (AuthHelper.isLoggedIn())
        Get.find<AddressController>().getAddressList(),
    ]);
  }

  void removeCacheModule() {
    splashServiceInterface.setCacheModule(null);
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
}
