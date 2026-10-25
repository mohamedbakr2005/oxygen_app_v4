import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/category/domain/models/category_model.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/review/domain/models/review_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/cart_suggested_item_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/recommended_product_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_banner_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_category_item_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/domain/services/store_service_interface.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/module_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class StoreController extends GetxController implements GetxService {
  final StoreServiceInterface storeServiceInterface;
  StoreController({required this.storeServiceInterface});

  StoreModel? _storeModel;
  StoreModel? get storeModel => _storeModel;
  
  int _storeRequestId = 0;

  List<Store>? _popularStoreList;
  List<Store>? get popularStoreList => _popularStoreList;

  List<Store>? _latestStoreList;
  List<Store>? get latestStoreList => _latestStoreList;

  List<Store>? _topOfferStoreList;
  List<Store>? get topOfferStoreList => _topOfferStoreList;

  List<Store>? _featuredStoreList;
  List<Store>? get featuredStoreList => _featuredStoreList;

  List<Store>? _visitAgainStoreList;
  List<Store>? get visitAgainStoreList => _visitAgainStoreList;

  Store? _store;
  Store? get store => _store;

  ItemModel? _storeItemModel;
  ItemModel? get storeItemModel => _storeItemModel;

  ItemModel? _storeSearchItemModel;
  ItemModel? get storeSearchItemModel => _storeSearchItemModel;

  int _categoryIndex = 0;
  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _filterType = 'all';
  String get filterType => _filterType;

  String _storeType = 'all';
  String get storeType => _storeType;

  List<ReviewModel>? _storeReviewList;
  List<ReviewModel>? get storeReviewList => _storeReviewList;

  String _type = 'all';
  String get type => _type;

  String _searchType = 'all';
  String get searchType => _searchType;

  String _searchText = '';
  String get searchText => _searchText;

  bool _currentState = true;
  bool get currentState => _currentState;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  List<XFile> _pickedPrescriptions = [];
  List<XFile> get pickedPrescriptions => _pickedPrescriptions;

  RecommendedItemModel? _recommendedItemModel;
  RecommendedItemModel? get recommendedItemModel => _recommendedItemModel;

  CartSuggestItemModel? _cartSuggestItemModel;
  CartSuggestItemModel? get cartSuggestItemModel => _cartSuggestItemModel;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<StoreBannerModel>? _storeBanners;
  List<StoreBannerModel>? get storeBanners => _storeBanners;

  List<Store>? _recommendedStoreList;
  List<Store>? get recommendedStoreList => _recommendedStoreList;

  StoreCategoryItemModel? _storeCategoryItemsModel;
  StoreCategoryItemModel? get storeCategoryItemsModel => _storeCategoryItemsModel;

  StoreModel? _quickDeliveryStoreList;
  StoreModel? get quickDeliveryStoreList => _quickDeliveryStoreList;

  static const int _quickDeliveryPageSize = 10;
  int _quickDeliveryPage = 1;
  int get quickDeliveryPage => _quickDeliveryPage;

  bool _isQuickDeliveryPaginating = false;
  bool get isQuickDeliveryPaginating => _isQuickDeliveryPaginating;

  StoreModel? _expressDeliveryStoreList;
  StoreModel? get expressDeliveryStoreList => _expressDeliveryStoreList;

  bool _isExpressDeliveryPaginating = false;
  bool get isExpressDeliveryPaginating => _isExpressDeliveryPaginating;

  String _expressDeliverySearchName = '';
  String get expressDeliverySearchName => _expressDeliverySearchName;

  StoreModel? _nearbyStoreList;
  StoreModel? get nearbyStoreList => _nearbyStoreList;

  static const int _nearbyPageSize = 10;
  int _nearbyPage = 1;
  int get nearbyPage => _nearbyPage;

  bool _isNearbyPaginating = false;
  bool get isNearbyPaginating => _isNearbyPaginating;

  String _nearbySearchName = '';
  String get nearbySearchName => _nearbySearchName;

  StoreModel? _topRatedStoreList;
  StoreModel? get topRatedStoreList => _topRatedStoreList;

  static const int _topRatedPageSize = 12;
  bool _isTopRatedPaginating = false;
  bool get isTopRatedPaginating => _isTopRatedPaginating;

  String _topRatedSearchName = '';
  String get topRatedSearchName => _topRatedSearchName;

  // List<Store>? _topOfferStoreList;
  // List<Store>? get topOfferStoreList => _topOfferStoreList;

  double getRestaurantDistance(LatLng storeLatLng) {
    double distance = 0;
    distance = Geolocator.distanceBetween(
            storeLatLng.latitude,
            storeLatLng.longitude,
            double.parse(
                AddressHelper.getUserAddressFromSharedPref()!.latitude!),
            double.parse(
                AddressHelper.getUserAddressFromSharedPref()!.longitude!)) /
        1000;
    return distance;
  }

  String filteringUrl(String slug) {
    return storeServiceInterface.filterRestaurantLinkUrl(slug, _store!);
  }

  void pickPrescriptionImage(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedPrescriptions = [];
    } else {
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 50);
      if (xFile != null) {
        _pickedPrescriptions.add(xFile);
      }
      update();
    }
  }

  void removePrescriptionImage(int index) {
    _pickedPrescriptions.removeAt(index);
    update();
  }

  void changeFavVisibility() {
    _showFavButton = !_showFavButton;
    update();
  }

  void hideAnimation() {
    _currentState = false;
  }

  void showButtonAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      _currentState = true;
      update();
    });
  }

  Future<void> getRestaurantRecommendedItemList(
      int? storeId, bool reload) async {
    if (reload) {
      _storeModel = null;
      update();
    }
    RecommendedItemModel? recommendedItemModel =
        await storeServiceInterface.getStoreRecommendedItemList(storeId);
    if (recommendedItemModel != null) {
      _recommendedItemModel = recommendedItemModel;
    }
    update();
  }

  Future<void> getCartStoreSuggestedItemList(int? storeId) async {
    CartSuggestItemModel? cartSuggestItemModel =
        await storeServiceInterface.getCartStoreSuggestedItemList(
            storeId,
            Get.find<LocalizationController>().locale.languageCode,
            ModuleHelper.getModule(),
            ModuleHelper.getCacheModule()?.id,
            ModuleHelper.getModule()?.id);
    if (cartSuggestItemModel != null) {
      _cartSuggestItemModel = cartSuggestItemModel;
    }
    update();
  }

  Future<void> getStoreBannerList(int? storeId) async {
    List<StoreBannerModel>? storeBanners =
        await storeServiceInterface.getStoreBannerList(storeId);
    if (storeBanners != null) {
      _storeBanners = [];
      _storeBanners!.addAll(storeBanners);
    }
    update();
  }

  Future<void> getStoreList(int offset, bool reload,
      {DataSourceEnum source = DataSourceEnum.local}) async {
    final int requestId = _storeRequestId;
    if (reload) {
      _storeModel = null;
      update();
    }
    StoreModel? storeModel;
    if (source == DataSourceEnum.local && offset == 1) {
      storeModel = await storeServiceInterface.getStoreList(
          offset, _filterType, _storeType,
          source: DataSourceEnum.local);
      if (requestId != _storeRequestId) return;
      _prepareStoreModel(storeModel, offset);
      getStoreList(offset, false, source: DataSourceEnum.client);
    } else {
      storeModel = await storeServiceInterface.getStoreList(
          offset, _filterType, _storeType,
          source: DataSourceEnum.client);
      if (requestId != _storeRequestId) return;
      _prepareStoreModel(storeModel, offset);
    }
  }

  _prepareStoreModel(StoreModel? storeModel, int offset) {
    if (storeModel != null) {
      if (offset == 1) {
        _storeModel = storeModel;
      } else {
        _storeModel!.totalSize = storeModel.totalSize;
        _storeModel!.offset = storeModel.offset;
        _storeModel!.stores!.addAll(storeModel.stores!);
      }
      update();
    }
  }

  void setFilterType(String type) {
    _filterType = type;
    getStoreList(1, true);
  }

  void setStoreType(String type) {
    _storeType = type;
    getStoreList(1, true);
  }

  void resetStoreData() {
    _filterType = 'all';
    _storeType = 'all';
  }

  void clearStoreDetails() {
    _store = null;
    _categoryIndex = 0;
    _categoryList = null;
    _storeItemModel = null;
    _storeSearchItemModel = null;
    _searchText = '';
    _isSearching = false;
    _recommendedItemModel = null;
  }

  void clearStoreData() {
    _storeRequestId++;
    _storeModel = null;
    _popularStoreList = null;
    _latestStoreList = null;
    _featuredStoreList = null;
    _topOfferStoreList = null;
    _recommendedStoreList = null;
    _visitAgainStoreList = null;
    _filterType = 'all';
    _storeType = 'all';
    _type = 'all';
    _categoryIndex = 0;
    _categoryList = null;
    _storeItemModel = null;
    _storeSearchItemModel = null;
    _store = null;
    update();
  }

  Future<void> getPopularStoreList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _storeRequestId;
    _type = type;
    if (reload) {
      _popularStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_popularStoreList == null || reload || fromRecall) {
      List<Store>? popularStoreList;
      if (dataSource == DataSourceEnum.local) {
        popularStoreList = await storeServiceInterface.getPopularStoreList(type,
            source: DataSourceEnum.local);
        if (requestId != _storeRequestId) return;
        if (popularStoreList != null) {
          _popularStoreList = [];
          _popularStoreList!.addAll(popularStoreList);
        }
        update();
        getPopularStoreList(false, type, notify,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        popularStoreList = await storeServiceInterface.getPopularStoreList(type,
            source: DataSourceEnum.client);
        if (requestId != _storeRequestId) return;
        if (popularStoreList != null) {
          _popularStoreList = [];
          _popularStoreList!.addAll(popularStoreList);
        }
        update();
      }
    }
  }

  Future<void> getLatestStoreList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _storeRequestId;
    _type = type;
    if (reload) {
      _latestStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_latestStoreList == null || reload || fromRecall) {
      List<Store>? latestStoreList;
      if (dataSource == DataSourceEnum.local) {
        latestStoreList = await storeServiceInterface.getLatestStoreList(type,
            source: DataSourceEnum.local);
        if (requestId != _storeRequestId) return;
        if (latestStoreList != null) {
          _latestStoreList = [];
          _latestStoreList!.addAll(latestStoreList);
        }
        update();
        getLatestStoreList(false, type, notify,
            fromRecall: true, dataSource: DataSourceEnum.client);
      } else {
        latestStoreList = await storeServiceInterface.getLatestStoreList(type,
            source: DataSourceEnum.client);
        if (requestId != _storeRequestId) return;
        if (latestStoreList != null) {
          _latestStoreList = [];
          _latestStoreList!.addAll(latestStoreList);
        }
        update();
      }
    }
  }

  Future<void> getFeaturedStoreList(
      {bool reload = false,
      bool notify = true,
      DataSourceEnum dataSource = DataSourceEnum.local}) async {
    final int requestId = _storeRequestId;
    if (reload) {
      _featuredStoreList = null;
    }
    if (notify) {
      update();
    }
    List<Store>? stores;
    if (dataSource == DataSourceEnum.local) {
      stores =
          await storeServiceInterface.getFeaturedStoreList(source: dataSource);
      if (requestId != _storeRequestId) return;
      _prepareFeaturedStore(stores);
      getFeaturedStoreList(reload: false, dataSource: DataSourceEnum.client);
    } else {
      stores = await storeServiceInterface.getFeaturedStoreList(
          source: DataSourceEnum.client);
      if (requestId != _storeRequestId) return;
      _prepareFeaturedStore(stores);
    }
  }

  _prepareFeaturedStore(List<Store>? stores) {
    if (stores != null) {
      _featuredStoreList = [];
      List<Modules> moduleList = [];
      moduleList.addAll(storeServiceInterface.moduleList());
      for (Store store in stores) {
        for (var module in moduleList) {
          if (module.id == store.moduleId) {
            if (module.pivot!.zoneId == store.zoneId) {
              _featuredStoreList!.add(store);
            }
          }
        }
      }
    }
    update();
  }

  Future<void> getVisitAgainStoreList(
      {bool fromModule = false,
      DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _storeRequestId;
    if (fromModule && !fromRecall) {
      _visitAgainStoreList = null;
    }
    List<Store>? stores;
    if (dataSource == DataSourceEnum.local) {
      stores = await storeServiceInterface.getVisitAgainStoreList(
          source: DataSourceEnum.local);
      if (requestId != _storeRequestId) return;
      _prepareVisitAgainStore(stores);
      getVisitAgainStoreList(
          dataSource: DataSourceEnum.client, fromRecall: true);
    } else {
      stores = await storeServiceInterface.getVisitAgainStoreList(
          source: DataSourceEnum.client);
      if (requestId != _storeRequestId) return;
      _prepareVisitAgainStore(stores);
    }
  }

  _prepareVisitAgainStore(List<Store>? stores) {
    if (stores != null) {
      _visitAgainStoreList = [];
      List<Modules> moduleList = [];
      moduleList.addAll(storeServiceInterface.moduleList());
      for (var store in stores) {
        for (var module in moduleList) {
          if (module.id == store.moduleId) {
            if (module.pivot!.zoneId == store.zoneId) {
              _visitAgainStoreList!.add(store);
            }
          }
        }
      }
    }
    update();
  }

  void setCategoryList() {
    if (Get.find<CategoryController>().categoryList != null && _store != null) {
      _categoryList = [];
      _categoryList!.add(CategoryModel(id: 0, name: 'all'.tr));
      final bool hasSpecificCategories = _store!.categoryIds != null && _store!.categoryIds!.isNotEmpty;
      for (var category in Get.find<CategoryController>().categoryList!) {
        if (!hasSpecificCategories || _store!.categoryIds!.contains(category.id)) {
          _categoryList!.add(category);
        }
      }
    }
  }

  Future<void> initCheckoutData(int? storeId) async {
    Get.find<CouponController>().removeCouponData(false);
    Get.find<CheckoutController>().clearPrevData();
    await Get.find<StoreController>()
        .getStoreDetails(Store(id: storeId), false);
    Get.find<CheckoutController>().initializeTimeSlot(_store!);
  }


  Future<Store?> getStoreDetails(Store store, bool fromModule,
      {bool fromCart = false, String slug = '', bool calculateDistance = true}) async {
    _categoryIndex = 0;
    if (store.name != null) {
      _store = store;
    } else {
      _isLoading = true;
      _store = null;
      Store? storeDetails = await storeServiceInterface.getStoreDetails(
          store.id.toString(),
          fromCart,
          slug,
          Get.find<LocalizationController>().locale.languageCode,
          ModuleHelper.getModule(),
          ModuleHelper.getCacheModule()?.id,
          ModuleHelper.getModule()?.id);
      if (storeDetails != null) {
        _store = storeDetails;
        Get.find<CheckoutController>().initializeTimeSlot(_store!);
        if (!fromCart && slug.isEmpty && calculateDistance) {
          Get.find<CheckoutController>().getDistanceInKM(
            LatLng(
              double.parse(
                  AddressHelper.getUserAddressFromSharedPref()!.latitude!),
              double.parse(
                  AddressHelper.getUserAddressFromSharedPref()!.longitude!),
            ),
            LatLng(double.parse(_store!.latitude!),
                double.parse(_store!.longitude!)),
          );
        }
        if (slug.isNotEmpty) {
          await Get.find<LocationController>().setStoreAddressToUserAddress(
              LatLng(double.parse(_store!.latitude!),
                  double.parse(_store!.longitude!)));
        }
        if (fromModule) {
          HomeScreen.loadData(true);
        } else {
          Get.find<CheckoutController>().clearPrevData();
        }
      }
      Get.find<CheckoutController>().setOrderType(
        _store != null
            ? _store!.delivery!
                ? 'delivery'
                : 'take_away'
            : 'delivery',
        notify: false,
      );
      _isLoading = false;
      update();
    }
    return _store;
  }

  Future<void> getRecommendedStoreList(
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _storeRequestId;
    if (!fromRecall) {
      _recommendedStoreList = null;
    }
    List<Store>? recommendedStoreList;
    print('=====recommanded call $dataSource');
    if (dataSource == DataSourceEnum.local) {
      recommendedStoreList = await storeServiceInterface
          .getRecommendedStoreList(source: DataSourceEnum.local);
      if (requestId != _storeRequestId) return;
      _prepareRecommendedStores(recommendedStoreList);
      getRecommendedStoreList(
          dataSource: DataSourceEnum.client, fromRecall: true);
    } else {
      recommendedStoreList = await storeServiceInterface
          .getRecommendedStoreList(source: DataSourceEnum.client);
      if (requestId != _storeRequestId) return;
      _prepareRecommendedStores(recommendedStoreList);
    }
  }

  _prepareRecommendedStores(List<Store>? recommendedStoreList) {
    if (recommendedStoreList != null) {
      _recommendedStoreList = [];
      _recommendedStoreList!.addAll(recommendedStoreList);
    }
    update();
  }

  Future<void> getTopOfferStoreList(bool reload, bool notify, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    final int requestId = _storeRequestId;
    if (reload) {
      _topOfferStoreList = null;
    }
    if (notify) {
      update();
    }
    if (_topOfferStoreList == null || reload || fromRecall) {
      List<Store>? topOfferStoreList;
      if (dataSource == DataSourceEnum.local) {
        topOfferStoreList = await storeServiceInterface.getTopOfferStoreList(source: DataSourceEnum.local);
        if (requestId != _storeRequestId) return;
        _prepareTopOfferStores(topOfferStoreList);
        getTopOfferStoreList(false, notify, dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        topOfferStoreList = await storeServiceInterface.getTopOfferStoreList(source: DataSourceEnum.client);
        if (requestId != _storeRequestId) return;
        _prepareTopOfferStores(topOfferStoreList);
      }
    }
  }

  void _prepareTopOfferStores(List<Store>? topOfferStoreList) {
    if (topOfferStoreList != null) {
      _topOfferStoreList = [];
      _topOfferStoreList!.addAll(topOfferStoreList);
    }
    update();
  }

  Future<void> getStoreItemList(
      int? storeID, int offset, String type, bool notify) async {
    if (offset == 1 || _storeItemModel == null) {
      _type = type;
      _storeItemModel = null;
      if (notify) {
        update();
      }
    }
    ItemModel? storeItemModel = await storeServiceInterface.getStoreItemList(
      storeID,
      offset,
      (_store != null && _store!.categoryIds!.isNotEmpty && _categoryIndex != 0)
          ? _categoryList![_categoryIndex].id
          : 0,
      type,
    );
    if (storeItemModel != null) {
      if (offset == 1) {
        _storeItemModel = storeItemModel;
      } else {
        _storeItemModel!.items!.addAll(storeItemModel.items!);
        _storeItemModel!.totalSize = storeItemModel.totalSize;
        _storeItemModel!.offset = storeItemModel.offset;
      }
    }
    update();
  }

  Future<void> getStoreSearchItemList(
      String searchText, String? storeID, int offset, String type) async {
    if (searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    } else {
      _isSearching = true;
      _searchText = searchText;
      _type = type;
      if (offset == 1 || _storeSearchItemModel == null) {
        _searchType = type;
        _storeSearchItemModel = null;
        update();
      }
      ItemModel? storeSearchItemModel =
          await storeServiceInterface.getStoreSearchItemList(
              searchText,
              storeID,
              offset,
              type,
              (_store != null &&
                      _store!.categoryIds!.isNotEmpty &&
                      _categoryIndex != 0)
                  ? _categoryList![_categoryIndex].id
                  : 0);
      if (storeSearchItemModel != null) {
        if (offset == 1) {
          _storeSearchItemModel = storeSearchItemModel;
        } else {
          _storeSearchItemModel!.items!.addAll(storeSearchItemModel.items!);
          _storeSearchItemModel!.totalSize = storeSearchItemModel.totalSize;
          _storeSearchItemModel!.offset = storeSearchItemModel.offset;
        }
      }
      update();
    }
  }

  void changeSearchStatus({bool isUpdate = true}) {
    _isSearching = !_isSearching;
    if (isUpdate) {
      update();
    }
  }

  void initSearchData() {
    _storeSearchItemModel = ItemModel(items: []);
    _searchText = '';
  }

  void setCategoryIndex(int index, {bool itemSearching = false}) {
    _categoryIndex = index;
    if (itemSearching) {
      _storeSearchItemModel = null;
      getStoreSearchItemList(_searchText, _store!.id.toString(), 1, type);
    } else {
      _storeItemModel = null;
      getStoreItemList(_store!.id, 1, Get.find<StoreController>().type, false);
    }
    update();
  }

  bool isStoreClosed(bool today, bool active, List<Schedules>? schedules) {
    if (!active) {
      return true;
    }
    DateTime date = DateTime.now();
    if (!today) {
      date = date.add(const Duration(days: 1));
    }
    int weekday = date.weekday;
    if (weekday == 7) {
      weekday = 0;
    }
    for (int index = 0; index < schedules!.length; index++) {
      if (weekday == schedules[index].day) {
        return false;
      }
    }
    return true;
  }

  bool isStoreOpenNow(bool active, List<Schedules>? schedules) {
    if (isStoreClosed(true, active, schedules)) {
      return false;
    }
    int weekday = DateTime.now().weekday;
    if (weekday == 7) {
      weekday = 0;
    }
    for (int index = 0; index < schedules!.length; index++) {
      if (weekday == schedules[index].day &&
          DateConverter.isAvailable(
              schedules[index].openingTime, schedules[index].closingTime)) {
        return true;
      }
    }
    return false;
  }

  bool isOpenNow(Store store) => store.open == 1 && store.active!;

  double? getDiscount(Store store) =>
      store.discount != null ? store.discount!.discount : 0;

  String? getDiscountType(Store store) =>
      store.discount != null ? store.discount!.discountType : 'percent';

  void shareStore() {
    if (ResponsiveHelper.isDesktop(Get.context)) {
      String shareUrl =
          '${AppConstants.webHostedUrl}${filteringUrl(store!.slug ?? '')}';

      Clipboard.setData(ClipboardData(text: shareUrl));
      showCustomSnackBar('store_url_copied'.tr, isError: false);
    } else {
      String shareUrl =
          '${AppConstants.webHostedUrl}${filteringUrl(store!.slug ?? '')}';
      Share.share(shareUrl);
    }
  }

  Future<void> getStoreCategoryItems(int storeId, {bool notify = true}) async {
    _storeCategoryItemsModel = null;
    if (notify) update();
    _storeCategoryItemsModel = await storeServiceInterface.getStoreCategoryItems(storeId);
    update();
  }

  void clearStoreCategoryItems() {
    _storeCategoryItemsModel = null;
    _recommendedItemModel = null;
  }

  Future<void> getQuickDeliveryStoreList({bool reload = false, int? moduleId}) async {
    if (reload) {
      _quickDeliveryStoreList = null;
      _quickDeliveryPage = 1;
    }
    final StoreModel? response = await storeServiceInterface.getQuickDeliveryStores(
      offset: 1, limit: _quickDeliveryPageSize, moduleId: moduleId,
    );
    if (response != null) {
      _quickDeliveryStoreList = response;
      _quickDeliveryPage = 1;
      update();
    }
  }

  Future<void> loadMoreQuickDeliveryStores({int? moduleId}) async {
    final StoreModel? current = _quickDeliveryStoreList;
    if (current == null || _isQuickDeliveryPaginating) return;

    final int loaded = current.stores?.length ?? 0;
    final int total = current.totalSize ?? 0;
    if (loaded >= total) return;

    _isQuickDeliveryPaginating = true;
    update();

    final int nextOffset = (loaded ~/ _quickDeliveryPageSize) + 1;
    final StoreModel? response = await storeServiceInterface.getQuickDeliveryStores(
      offset: nextOffset, limit: _quickDeliveryPageSize, moduleId: moduleId,
    );
    if (response?.stores != null) {
      current.stores!.addAll(response!.stores!);
      current.offset = response.offset;
      current.totalSize = response.totalSize;
      _quickDeliveryPage = nextOffset;
    }
    _isQuickDeliveryPaginating = false;
    update();
  }

  Future<void> getExpressDeliveryStoreList({bool reload = false, int? moduleId, String? name}) async {
    if (name != null) _expressDeliverySearchName = name;
    if (reload) {
      _expressDeliveryStoreList = null;
      update();
    }
    final StoreModel? response = await storeServiceInterface.getQuickDeliveryStores(
      offset: 1, limit: _quickDeliveryPageSize, moduleId: moduleId, name: _expressDeliverySearchName,
    );
    if (response != null) {
      _expressDeliveryStoreList = response;
      update();
    }
  }

  Future<void> loadMoreExpressDeliveryStores({int? moduleId}) async {
    final StoreModel? current = _expressDeliveryStoreList;
    if (current == null || _isExpressDeliveryPaginating) return;

    final int loaded = current.stores?.length ?? 0;
    final int total = current.totalSize ?? 0;
    if (loaded >= total) return;

    _isExpressDeliveryPaginating = true;
    update();

    final int nextOffset = (loaded ~/ _quickDeliveryPageSize) + 1;
    final StoreModel? response = await storeServiceInterface.getQuickDeliveryStores(
      offset: nextOffset, limit: _quickDeliveryPageSize, moduleId: moduleId, name: _expressDeliverySearchName,
    );
    if (response?.stores != null) {
      current.stores!.addAll(response!.stores!);
      current.offset = response.offset;
      current.totalSize = response.totalSize;
    }
    _isExpressDeliveryPaginating = false;
    update();
  }

  void clearExpressDeliveryStoreList() {
    _expressDeliveryStoreList = null;
    _expressDeliverySearchName = '';
  }

  Future<void> getNearbyStoreList({bool reload = false, int? moduleId, String? name}) async {
    if (name != null) _nearbySearchName = name;
    if (reload) {
      _nearbyStoreList = null;
      _nearbyPage = 1;
      update();
    }
    final StoreModel? response = await storeServiceInterface.getNearbyStores(
      offset: 1, limit: _nearbyPageSize, moduleId: moduleId, name: _nearbySearchName,
    );
    if (response != null) {
      _nearbyStoreList = response;
      _nearbyPage = 1;
      update();
    }
  }

  Future<void> loadMoreNearbyStores({int? moduleId}) async {
    final StoreModel? current = _nearbyStoreList;
    if (current == null || _isNearbyPaginating) return;

    final int loaded = current.stores?.length ?? 0;
    final int total = current.totalSize ?? 0;
    if (loaded >= total) return;

    _isNearbyPaginating = true;
    update();

    final int nextOffset = (loaded ~/ _nearbyPageSize) + 1;
    final StoreModel? response = await storeServiceInterface.getNearbyStores(
      offset: nextOffset, limit: _nearbyPageSize, moduleId: moduleId, name: _nearbySearchName,
    );
    if (response?.stores != null) {
      current.stores!.addAll(response!.stores!);
      current.offset = response.offset;
      current.totalSize = response.totalSize;
      _nearbyPage = nextOffset;
    }
    _isNearbyPaginating = false;
    update();
  }

  Future<void> getTopRatedStoreList({bool reload = false, DataSourceEnum source = DataSourceEnum.local, String? name}) async {
    if (name != null) _topRatedSearchName = name;
    if (reload) {
      _topRatedStoreList = null;
      update();
    }
    final bool searching = _topRatedSearchName.isNotEmpty;
    final DataSourceEnum effectiveSource = searching ? DataSourceEnum.client : source;
    final StoreModel? response = await storeServiceInterface.getStoreList(1, 'all', 'top_rated', source: effectiveSource);
    if (response != null) {
      _topRatedStoreList = response;
      update();
    }
    if (!searching && source == DataSourceEnum.local) {
      getTopRatedStoreList(reload: false, source: DataSourceEnum.client);
    }
  }

  Future<void> loadMoreTopRatedStores() async {
    final StoreModel? current = _topRatedStoreList;
    if (current == null || _isTopRatedPaginating) return;

    final int loaded = current.stores?.length ?? 0;
    final int total = current.totalSize ?? 0;
    if (loaded >= total) return;

    _isTopRatedPaginating = true;
    update();

    final int nextOffset = (loaded ~/ _topRatedPageSize) + 1;
    final StoreModel? response = await storeServiceInterface.getStoreList(nextOffset, 'all', 'top_rated', source: DataSourceEnum.client);
    if (response?.stores != null) {
      current.stores!.addAll(response!.stores!);
      current.offset = response.offset;
      current.totalSize = response.totalSize;
    }
    _isTopRatedPaginating = false;
    update();
  }

  void clearTopRatedStoreList() {
    _topRatedStoreList = null;
    _topRatedSearchName = '';
  }
}
