import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';
import 'package:Oxygen_Mart/common/widgets/confirmation_dialog.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/item_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/common_condition_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/item/domain/services/item_service_interface.dart';
import 'package:Oxygen_Mart/features/category/domain/services/category_service_interface.dart';
import 'package:Oxygen_Mart/features/item/screens/item_details_screen.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/module_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/images.dart';

class ItemController extends GetxController implements GetxService {
  final ItemServiceInterface itemServiceInterface;
  ItemController({required this.itemServiceInterface});

  List<Item>? _popularItemList;
  List<Item>? get popularItemList => _popularItemList;

  List<Item>? _reviewedItemList;
  List<Item>? get reviewedItemList => _reviewedItemList;

  List<Item>? _recommendedItemList;
  List<Item>? get recommendedItemList => _recommendedItemList;

  List<Item>? _discountedItemList;
  List<Item>? get discountedItemList => _discountedItemList;

  List<Item>? _relatedItemList;
  List<Item>? get relatedItemList => _relatedItemList;

  List<Categories>? _reviewedCategoriesList;
  List<Categories>? get reviewedCategoriesList => _reviewedCategoriesList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDetailsLoading = false;
  bool get isDetailsLoading => _isDetailsLoading;

  bool _detailsError = false;
  bool get detailsError => _detailsError;

  bool _isDirectlyAdding = false;
  bool get isDirectlyAdding => _isDirectlyAdding;

  List<int>? _variationIndex;
  List<int>? get variationIndex => _variationIndex;

  List<List<bool?>> _selectedVariations = [];
  List<List<bool?>> get selectedVariations => _selectedVariations;

  int? _quantity = 1;
  int? get quantity => _quantity;

  List<bool> _addOnActiveList = [];
  List<bool> get addOnActiveList => _addOnActiveList;

  List<int?> _addOnQtyList = [];
  List<int?> get addOnQtyList => _addOnQtyList;

  String _popularType = 'all';
  String get popularType => _popularType;

  String _reviewedType = 'all';
  String get reviewType => _reviewedType;

  String _discountedType = 'all';
  String get discountedType => _discountedType;

  static final List<String> _itemTypeList = ['all', 'veg', 'non_veg'];
  List<String> get itemTypeList => _itemTypeList;

  int _imageIndex = 0;
  int get imageIndex => _imageIndex;

  int _cartIndex = -1;
  int get cartIndex => _cartIndex;

  Item? _item;
  Item? get item => _item;

  int _productSelect = 0;
  int get productSelect => _productSelect;

  int _imageSliderIndex = 0;
  int get imageSliderIndex => _imageSliderIndex;

  List<bool> _collapseVariation = [];
  List<bool> get collapseVariation => _collapseVariation;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _itemRequestId = 0;

  bool _isReadMore = false;
  bool get isReadMore => _isReadMore;

  BasicMedicineModel? _basicMedicineModel;
  BasicMedicineModel? get basicMedicineModel => _basicMedicineModel;

  List<CommonConditionModel>? _commonConditions;
  List<CommonConditionModel>? get commonConditions => _commonConditions;

  int _selectedCommonCondition = 0;
  int get selectedCommonCondition => _selectedCommonCondition;

  List<Item>? _conditionWiseProduct;
  List<Item>? get conditionWiseProduct => _conditionWiseProduct;

  ItemModel? _featuredCategoriesItem;
  ItemModel? get featuredCategoriesItem => _featuredCategoriesItem;

  int _selectedCategory = 0;
  int get selectedCategory => _selectedCategory;

  void selectCategory(int index) {
    _selectedCategory = index;
    update();
  }

  void selectCommonCondition(int index) {
    _selectedCommonCondition = index;
    getConditionsWiseItem(_commonConditions![index].id!, true);
    update();
  }

  void changeReadMore({bool? value, bool notify = true}) {
    _isReadMore = value ?? !_isReadMore;
    if(notify) update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }

  void clearItemLists() {
    _itemRequestId++;
    _popularItemList = null;
    _reviewedItemList = null;
    _discountedItemList = null;
    _featuredCategoriesItem = null;
    _recommendedItemList = null;
    _relatedItemList = null;
  }

  Future<void> getPopularItemList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _itemRequestId;
    _popularType = type;
    if (reload) {
      _popularItemList = null;
    }
    if (notify) {
      update();
    }
    if (_popularItemList == null || reload || fromRecall) {
      List<Item>? items;
      if (dataSource == DataSourceEnum.local) {
        items = await itemServiceInterface.getPopularItemList(type, dataSource);
        if (requestId != _itemRequestId) return;
        _preparePopularItems(items);
        getPopularItemList(false, type, notify,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        items = await itemServiceInterface.getPopularItemList(type, dataSource);
        if (requestId != _itemRequestId) return;
        _preparePopularItems(items);
      }
    }
  }

  _preparePopularItems(List<Item>? items) {
    if (items != null) {
      _popularItemList = [];
      _popularItemList!.addAll(items);
      _isLoading = false;
    }
    update();
  }

  Future<void> getReviewedItemList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _itemRequestId;
    _reviewedType = type;
    if (reload) {
      _reviewedItemList = null;
    }
    if (notify) {
      update();
    }
    if (_reviewedItemList == null || reload || fromRecall) {
      ItemModel? itemModel;
      if (dataSource == DataSourceEnum.local) {
        itemModel =
            await itemServiceInterface.getReviewedItemList(type, dataSource);
        if (requestId != _itemRequestId) return;
        _preparedReviewedItems(itemModel);
        getReviewedItemList(false, type, notify,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        itemModel =
            await itemServiceInterface.getReviewedItemList(type, dataSource);
        if (requestId != _itemRequestId) return;
        _preparedReviewedItems(itemModel);
      }
    }
  }

  _preparedReviewedItems(ItemModel? itemModel) {
    if (itemModel != null) {
      _reviewedItemList = [];
      _reviewedCategoriesList = [];
      _reviewedItemList!.addAll(itemModel.items ?? <Item>[]);
      _reviewedCategoriesList!.addAll(itemModel.categories ?? <Categories>[]);
      _isLoading = false;
    }
    update();
  }

  Future<void> getDiscountedItemList(bool reload, bool notify, String type,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _itemRequestId;
    _discountedType = type;
    if (reload) {
      _discountedItemList = null;
    }
    if (notify) {
      update();
    }
    if (_discountedItemList == null || reload || fromRecall) {
      List<Item>? items;
      if (dataSource == DataSourceEnum.local) {
        items =
            await itemServiceInterface.getDiscountedItemList(type, dataSource);
        print('======cache spatial item: $items');
        if (requestId != _itemRequestId) return;
        if (items != null) {
          _discountedItemList = [];
          _discountedItemList!.addAll(items);
          _isLoading = false;
        }
        update();
        getDiscountedItemList(false, notify, type,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        items =
            await itemServiceInterface.getDiscountedItemList(type, dataSource);
        if (requestId != _itemRequestId) return;
        if (items != null) {
          _discountedItemList = [];
          _discountedItemList!.addAll(items);
          _isLoading = false;
        }
        update();
      }
    }
  }

  Future<void> getFeaturedCategoriesItemList(bool reload, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _itemRequestId;
    if (reload) {
      _featuredCategoriesItem = null;
    }
    if (notify) {
      update();
    }
    if (_featuredCategoriesItem == null || reload || fromRecall) {
      if (dataSource == DataSourceEnum.local) {
        _featuredCategoriesItem = await itemServiceInterface
            .getFeaturedCategoriesItemList(dataSource);
        if (requestId != _itemRequestId) return;
        update();
        getFeaturedCategoriesItemList(false, notify,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        _featuredCategoriesItem = await itemServiceInterface
            .getFeaturedCategoriesItemList(dataSource);
        if (requestId != _itemRequestId) return;
        update();
      }
    }
  }

  Future<void> getRecommendedItemList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _itemRequestId;
    if (reload) {
      _recommendedItemList = null;
    }
    if (notify) {
      update();
    }
    if (_recommendedItemList == null || reload || fromRecall) {
      List<Item>? items;
      if (dataSource == DataSourceEnum.local) {
        items =
            await itemServiceInterface.getRecommendedItemList(type, dataSource);
        if (requestId != _itemRequestId) return;
        _prepareRecommendedItems(items);

        getRecommendedItemList(false, type, notify,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        items =
            await itemServiceInterface.getRecommendedItemList(type, dataSource);
        if (requestId != _itemRequestId) return;
        _prepareRecommendedItems(items);
      }
    }
  }

  _prepareRecommendedItems(List<Item>? items) {
    if (items != null) {
      _recommendedItemList = [];
      _recommendedItemList!.addAll(items);
      _isLoading = false;
    }
    update();
  }

  Future<void> getBasicMedicine(bool reload, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    final int requestId = _itemRequestId;
    if (reload) {
      _basicMedicineModel = null;
    }
    if (notify) {
      update();
    }
    if (_basicMedicineModel == null || reload || fromRecall) {
      if (dataSource == DataSourceEnum.local) {
        _basicMedicineModel =
            await itemServiceInterface.getBasicMedicine(DataSourceEnum.local);
        if (requestId != _itemRequestId) return;
        _isLoading = false;
        update();
        getBasicMedicine(false, notify,
            fromRecall: true, dataSource: DataSourceEnum.client);
      } else {
        _basicMedicineModel =
            await itemServiceInterface.getBasicMedicine(DataSourceEnum.client);
        if (requestId != _itemRequestId) return;
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> getConditionsWiseItem(int id, bool notify) async {
    final int requestId = _itemRequestId;
    _conditionWiseProduct = null;
    if (notify) {
      update();
    }
    List<Item>? items = await itemServiceInterface.getConditionsWiseItems(id);
    if (requestId != _itemRequestId) return;
    if (items != null) {
      _conditionWiseProduct = [];
      _conditionWiseProduct!.addAll(items);
      _isLoading = false;
    }
    update();
  }

  Future<void> getCommonConditions(bool notify) async {
    final int requestId = _itemRequestId;
    _commonConditions = [];
    if (notify) {
      update();
    }
    List<CommonConditionModel>? conditions =
        await itemServiceInterface.getCommonConditions();
    if (requestId != _itemRequestId) return;
    if (conditions != null) {
      _commonConditions!.addAll(conditions);
      _isLoading = false;
    }
    update();
  }

    Future<void> getItemDetails({
    required int itemId,
    CartModel? cart,
    bool isCampaign = false,
  }) async {
    _item = null;
    _item = await itemServiceInterface.getItemDetails(itemId); // V4 getItemDetails takes id

    if (_item != null) {
      initData(_item, cart);
      setExistInCart(_item, _selectedVariations);
    }
    update();
  }

  String? _extractCategoryId(Item? item) {
    if (item == null) return null;
    if (item.categoryIds != null && item.categoryIds!.isNotEmpty) {
      final mainCat = item.categoryIds!.firstWhereOrNull((c) => c.position == 1 && c.id != null && c.id != 0);
      if (mainCat != null && mainCat.id != null && mainCat.id != 0) {
        return mainCat.id.toString();
      }
      final anyCat = item.categoryIds!.firstWhereOrNull((c) => c.id != null && c.id != 0);
      if (anyCat != null && anyCat.id != null && anyCat.id != 0) {
        return anyCat.id.toString();
      }
    }
    if (item.categoryId != null && item.categoryId != 0) {
      return item.categoryId.toString();
    }
    return null;
  }

  void resetItemDetails(Item item, {bool notify = false}) {
    _isDetailsLoading = true;
    _detailsError = false;
    _item = item;
    _relatedItemList = null;
    _currentIndex = 0;
    if (item.name != null) {
      initData(item, null);
    }
    if (notify) update();
  }

  void clearItemDetails({bool notify = false}) {
    _item = null;
    _isDetailsLoading = true;
    _detailsError = false;
    _relatedItemList = null;
    _currentIndex = 0;
    if (notify) update();
  }

  Future<void> getProductDetails(Item item, {bool notify = false}) async {
    _isDetailsLoading = true;
    _detailsError = false;
    _item = item;
    _relatedItemList = null;

    final String? initialCatId = _extractCategoryId(item);
    if (item.name != null) {
      initData(_item, null);
      if (notify) update();
      if (initialCatId != null) {
        getRelatedItemList(initialCatId, item.id, notify: notify);
      } else {
        _loadFallbackRelatedItems(item.id, notify: notify);
      }
    } else {
      _item = null;
      if (notify) update();
    }

    Item? fullItem;
    try {
      fullItem = await itemServiceInterface.getItemDetails(item.id);
    } catch (e) {
      print('getItemDetails error: $e');
    }

    if (fullItem != null) {
      _item = fullItem;
      _detailsError = false;
      initData(_item, null);
      setExistInCart(_item, _selectedVariations, notify: true);

      // Synchronize active module if item belongs to a specific module
      if (fullItem.moduleId != null && Get.isRegistered<SplashController>()) {
        final splashCtrl = Get.find<SplashController>();
        if (splashCtrl.module == null || splashCtrl.module?.id != fullItem.moduleId) {
          if (splashCtrl.moduleList == null || splashCtrl.moduleList!.isEmpty) {
            await splashCtrl.getModules();
          }
          if (splashCtrl.moduleList != null) {
            for (final m in splashCtrl.moduleList!) {
              if (m.id == fullItem.moduleId) {
                await splashCtrl.switchModuleByModel(m);
                HomeScreen.loadData(true, fromModule: true);
                break;
              }
            }
          }
        }
      }

      final String? fullCatId = _extractCategoryId(_item!) ?? initialCatId;
      if (fullCatId != null) {
        getRelatedItemList(fullCatId, _item!.id, notify: true);
      } else {
        await _loadFallbackRelatedItems(_item?.id, notify: true);
      }

      try {
        Get.find<MetaAnalyticsService>().viewContent(
          contentId: _item!.id?.toString() ?? 'unknown',
          contentName: _item!.name ?? 'unknown',
          currency: 'EGP',
          value: _item!.price ?? 0.0,
          category: fullCatId ?? 'unknown',
          contentIds: [_item!.id?.toString() ?? 'unknown'],
          contents: [
            {
              'id': _item!.id?.toString() ?? 'unknown',
              'quantity': 1,
              'item_price': _item!.price ?? 0.0,
            }
          ],
        );
      } catch (_) {}
    } else if (_item == null) {
      _detailsError = true;
      showCustomSnackBar('item_not_found'.tr);
      _relatedItemList ??= [];
    } else if (_relatedItemList == null) {
      await _loadFallbackRelatedItems(_item?.id, notify: true);
    }
    _isDetailsLoading = false;
    update();
  }

  Future<void> getRelatedItemList(String? categoryId, int? currentItemId, {bool notify = true}) async {
    if (categoryId == null || categoryId.isEmpty || categoryId == '0' || categoryId == 'null') {
      await _loadFallbackRelatedItems(currentItemId, notify: notify);
      return;
    }

    if (_relatedItemList == null && notify) {
      update();
    }

    try {
      final localItem = await Get.find<CategoryServiceInterface>().getCategoryItemList(
        categoryId, 1, 'all', source: DataSourceEnum.local,
      );
      if (localItem != null && localItem.items != null && localItem.items!.isNotEmpty) {
        final filtered = localItem.items!.where((it) => it.id != currentItemId).take(10).toList();
        if (filtered.isNotEmpty) {
          _relatedItemList = filtered;
          if (notify) update();
        }
      }
    } catch (_) {}

    try {
      final categoryItem = await Get.find<CategoryServiceInterface>().getCategoryItemList(
        categoryId, 1, 'all', source: DataSourceEnum.client,
      );
      if (categoryItem != null && categoryItem.items != null && categoryItem.items!.isNotEmpty) {
        final filtered = categoryItem.items!
            .where((it) => it.id != currentItemId)
            .take(10)
            .toList();
        if (filtered.isNotEmpty) {
          _relatedItemList = filtered;
        } else if (_relatedItemList == null || _relatedItemList!.isEmpty) {
          await _loadFallbackRelatedItems(currentItemId, notify: false);
        }
      } else if (_relatedItemList == null || _relatedItemList!.isEmpty) {
        await _loadFallbackRelatedItems(currentItemId, notify: false);
      }
    } catch (e) {
      print('getRelatedItemList error: $e');
      if (_relatedItemList == null || _relatedItemList!.isEmpty) {
        await _loadFallbackRelatedItems(currentItemId, notify: false);
      }
    }

    _relatedItemList ??= [];
    update();
  }

  Future<void> _loadFallbackRelatedItems(int? currentItemId, {bool notify = true}) async {
    try {
      final List<Item>? popularItems = await itemServiceInterface.getPopularItemList('all', DataSourceEnum.client);
      if (popularItems != null && popularItems.isNotEmpty) {
        _relatedItemList = popularItems.where((it) => it.id != currentItemId).take(10).toList();
      } else {
        _relatedItemList = [];
      }
    } catch (_) {
      _relatedItemList = [];
    }
    if (notify) update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void initData(Item? item, CartModel? cart) {
    _variationIndex = [];
    _addOnQtyList = [];
    _addOnActiveList = [];
    _selectedVariations = [];
    _collapseVariation = [];
    _quantity = 1;
    if (item == null) return;
    try {
      final String? moduleType = item.moduleType ??
          ModuleHelper.getModule()?.moduleType ??
          ModuleHelper.getCacheModule()?.moduleType;
      final bool newVariation = ModuleHelper.getModuleConfig(moduleType).newVariation ?? false;

      if (cart != null) {
        _quantity = cart.quantity;
        _addOnActiveList.addAll(itemServiceInterface
            .initializeCartAddonActiveList(cart.addOnIds, item.addOns));
        _addOnQtyList.addAll(itemServiceInterface.initializeCartAddonsQtyList(
            cart.addOnIds, item.addOns));

        if (newVariation) {
          _selectedVariations.addAll(cart.foodVariations ?? []);
          _collapseVariation.addAll(
              itemServiceInterface.collapseVariation(item.foodVariations ?? []));
        } else {
          _variationIndex = itemServiceInterface.initializeCartVariationIndexes(
              cart.variation, item.choiceOptions);
        }
      } else {
        if (newVariation) {
          _selectedVariations.addAll(itemServiceInterface
              .initializeSelectedVariation(item.foodVariations));
          _collapseVariation.addAll(itemServiceInterface
              .initializeCollapseVariation(item.foodVariations));
        } else {
          _variationIndex =
              itemServiceInterface.initializeVariationIndexes(item.choiceOptions);
        }
        _quantity = 1;
        _addOnActiveList
            .addAll(itemServiceInterface.initializeAddonActiveList(item.addOns));
        _addOnQtyList
            .addAll(itemServiceInterface.initializeAddonQtyList(item.addOns));

        setExistInCart(item, _selectedVariations, notify: false);
      }
    } catch (e) {
      print('initData error: $e');
    }
  }

  void cartIndexSet() {
    _cartIndex = -1;
  }

  Future<int> setExistInCart(Item? item, List<List<bool?>>? selectedVariations,
      {bool notify = false}) async {
    if (item == null || item.id == null) return -1;
    try {
      String variationType = await itemServiceInterface.prepareVariationType(
          item.choiceOptions, _variationIndex);

      final String? currentModuleType = item.moduleType ??
          ModuleHelper.getModule()?.moduleType ??
          ModuleHelper.getCacheModule()?.moduleType;
      final bool newVariation = ModuleHelper.getModuleConfig(currentModuleType).newVariation ?? false;

      if (newVariation) {
        _cartIndex = await itemServiceInterface.isExistInCartForBottomSheet(
            Get.find<CartController>().cartList,
            item.id,
            null,
            selectedVariations);
      } else {
        _cartIndex = Get.find<CartController>()
            .isExistInCart(item.id, variationType, false, null);
      }

      if (_cartIndex != -1 && _cartIndex < Get.find<CartController>().cartList.length) {
        _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
        _addOnActiveList = itemServiceInterface.initializeCartAddonActiveList(
            Get.find<CartController>().cartList[_cartIndex].addOnIds,
            item.addOns);
        _addOnQtyList = itemServiceInterface.initializeCartAddonsQtyList(
            Get.find<CartController>().cartList[_cartIndex].addOnIds,
            item.addOns);
      } else {
        _quantity = 1;
      }
    } catch (e) {
      print('setExistInCart error: $e');
      _cartIndex = -1;
      _quantity = 1;
    }
    if (notify) update();
    return _cartIndex;
  }

  void setAddOnQuantity(bool isIncrement, int index) {
    _addOnQtyList[index] = itemServiceInterface.setAddOnQuantity(
        isIncrement, _addOnQtyList[index]!);
    update();
  }

  Future<void> setQuantity(bool isIncrement, int? stock, int? quantityLimit,
      {bool getxSnackBar = false}) async {
    _quantity = await itemServiceInterface.setQuantity(
        isIncrement,
        Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!,
        stock,
        _quantity!,
        quantityLimit,
        getxSnackBar: getxSnackBar);
    update();
  }

  void setCartVariationIndex(int index, int i, Item? item) {
    _variationIndex![index] = i;
    _quantity = 1;
    setExistInCart(item, _selectedVariations);
    update();
  }

  void showMoreSpecificSection(int index) {
    _collapseVariation[index] = !_collapseVariation[index];
    update();
  }

  void setNewCartVariationIndex(int index, int i, Item item) {
    _selectedVariations = itemServiceInterface.setNewCartVariationIndex(
        index, i, item.foodVariations!, _selectedVariations);
    setExistInCart(item, _selectedVariations);
    // if(!item.foodVariations![index].multiSelect!) {
    //   for(int j = 0; j < _selectedVariations[index].length; j++) {
    //     if(item.foodVariations![index].required!){
    //       _selectedVariations[index][j] = j == i;
    //     }else{
    //       if(_selectedVariations[index][j]!){
    //         _selectedVariations[index][j] = false;
    //       }else{
    //         _selectedVariations[index][j] = j == i;
    //       }
    //     }
    //   }
    // } else {
    //   if(!_selectedVariations[index][i]! && selectedVariationLength(_selectedVariations, index) >= item.foodVariations![index].max!) {
    //     showCustomSnackBar(
    //       '${'maximum_variation_for'.tr} ${item.foodVariations![index].name} ${'is'.tr} ${item.foodVariations![index].max}',
    //       getXSnackBar: true,
    //     );
    //   }else {
    //     _selectedVariations[index][i] = !_selectedVariations[index][i]!;
    //   }
    // }
    update();
  }

  int selectedVariationLength(List<List<bool?>> selectedVariations, int index) {
    return itemServiceInterface.selectedVariationLength(
        selectedVariations, index);
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    update();
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if (notify) {
      update();
    }
  }

  void setSelect(int select, bool notify) {
    _productSelect = select;
    if (notify) {
      update();
    }
  }

  void setImageSliderIndex(int index) {
    _imageSliderIndex = index;
    update();
  }

  double? getStartingPrice(Item item) {
    return itemServiceInterface.getStartingPrice(item);
  }

  bool isAvailable(Item item) {
    return DateConverter.isAvailable(
        item.availableTimeStarts, item.availableTimeEnds);
  }

  double? getDiscount(Item item) =>
      item.storeDiscount == 0 ? item.discount : item.storeDiscount;

  String? getDiscountType(Item item) =>
      item.storeDiscount == 0 ? item.discountType : 'percent';

  void navigateToItemPage(Item? item, BuildContext context,
      {bool inStore = false, bool isCampaign = false}) {
    if (Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .showRestaurantText! ||
        item!.moduleType == 'food') {
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              ItemBottomSheet(
                  item: item, inStorePage: inStore, isCampaign: isCampaign),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            )
          : Get.dialog(
              Dialog(
                  child: ItemBottomSheet(
                      item: item,
                      inStorePage: inStore,
                      isCampaign: isCampaign)),
            );
    } else {
      Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, inStore),
          arguments: ItemDetailsScreen(
              item: item, inStorePage: inStore, isCampaign: isCampaign));
    }
  }

  Future<void> itemDirectlyAddToCart(Item? item, BuildContext context,
      {bool inStore = false, bool isCampaign = false}) async {
    if (_isDirectlyAdding || (item?.id != null && Get.isRegistered<CartController>() && Get.find<CartController>().isItemAdding(item!.id))) return;
    _isDirectlyAdding = true;
    update();

    try {
      if (((item!.foodVariations != null && item.foodVariations!.isEmpty) &&
              item.moduleType == AppConstants.food) ||
          (item.variations != null &&
              item.variations!.isEmpty &&
              item.moduleType != AppConstants.food)) {
        double price = item.price!;
        double discount = item.discount!;
        double discountPrice = PriceConverter.convertWithDiscount(
            price, discount, item.discountType)!;

        CartModel cartModel = CartModel(
          null,
          price,
          discount,
          [],
          [],
          (price - discountPrice),
          1,
          [],
          [],
          isCampaign,
          item.stock,
          item,
          item.quantityLimit,
        );

        OnlineCart onlineCart = OnlineCart(
          null,
          isCampaign ? null : item.id,
          isCampaign ? item.id : null,
          price.toString(),
          '',
          null,
          ModuleHelper.getModuleConfig(item.moduleType).newVariation! ? [] : null,
          1,
          [],
          [],
          [],
          'Item',
          storeId: item.storeId,
        );
        if (Get.find<SplashController>()
                .configModel!
                .moduleConfig!
                .module!
                .stock! &&
            item.stock! <= 0) {
          showCustomSnackBar('out_of_stock'.tr);
        } else if (Get.find<CartController>().existAnotherStoreItem(
            cartModel.item!.storeId,
            ModuleHelper.getModule() != null
                ? ModuleHelper.getModule()?.id
                : ModuleHelper.getCacheModule()?.id)) {
          Get.dialog(
              ConfirmationDialog(
                icon: Images.warning,
                title: 'are_you_sure_to_reset'.tr,
                description: Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .showRestaurantText!
                    ? 'if_you_continue'.tr
                    : 'if_you_continue_without_another_store'.tr,
                onYesPressed: () {
                  Get.find<CartController>()
                      .clearCartOnline()
                      .then((success) async {
                    if (success) {
                      bool addSuccess = await Get.find<CartController>()
                          .addToCartOnline(onlineCart, storeId: item.storeId);
                      Get.back();
                      showCustomSnackBar(addSuccess
                          ? 'item_added_to_cart'.tr
                          : 'failed_to_add_to_cart'.tr,
                          isError: !addSuccess,
                          actionLabel: addSuccess ? 'view_cart'.tr : null,
                          onAction: addSuccess ? () => Get.toNamed(RouteHelper.getCartRoute(storeId: item.storeId)) : null);
                    }
                  });
                },
              ),
              barrierDismissible: false);
        } else {
          bool success = await Get.find<CartController>().addToCartOnline(onlineCart, storeId: item.storeId);
          if (success) {
            showCustomSnackBar('item_added_to_cart'.tr,
                isError: false,
                actionLabel: 'view_cart'.tr,
                onAction: () => Get.toNamed(RouteHelper.getCartRoute(storeId: item.storeId)));
          }
        }
      } else if (Get.find<SplashController>()
              .configModel!
              .moduleConfig!
              .module!
              .showRestaurantText! ||
          item.moduleType == AppConstants.food) {
        ResponsiveHelper.isMobile(context)
            ? Get.bottomSheet(
                ItemBottomSheet(
                    item: item, inStorePage: inStore, isCampaign: isCampaign),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              )
            : Get.dialog(
                Dialog(
                    child: ItemBottomSheet(
                        item: item,
                        inStorePage: inStore,
                        isCampaign: isCampaign)),
              );
      } else {
        Get.toNamed(RouteHelper.getItemDetailsRoute(item.id, inStore),
            arguments: ItemDetailsScreen(item: item, inStorePage: inStore));
      }
    } finally {
      _isDirectlyAdding = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }
}




