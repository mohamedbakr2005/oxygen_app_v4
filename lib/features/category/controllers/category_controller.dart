import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/features/category/domain/models/category_model.dart';
import 'package:Oxygen_Mart/features/category/domain/services/category_service_interface.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  List<Item>? _categoryItemList;
  List<Item>? get categoryItemList => _categoryItemList;

  List<Store>? _categoryStoreList;
  List<Store>? get categoryStoreList => _categoryStoreList;

  List<Item>? _searchItemList = [];
  List<Item>? get searchItemList => _searchItemList;

  List<Store>? _searchStoreList = [];
  List<Store>? get searchStoreList => _searchStoreList;

  List<bool>? _interestSelectedList;
  List<bool>? get interestSelectedList => _interestSelectedList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _restPageSize;
  int? get restPageSize => _restPageSize;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  int _subCategoryIndex = 0;
  int get subCategoryIndex => _subCategoryIndex;

  String _type = 'all';
  String get type => _type;

  bool _isStore = false;
  bool get isStore => _isStore;

  String? _searchText = '';
  String? get searchText => _searchText;

  int _offset = 1;
  int get offset => _offset;

  String? _currentCategoryId;
  String? get currentCategoryId => _currentCategoryId;

  void clearCategoryList() {
    _categoryList = null;
    _subCategoryList = null;
    _categoryItemList = null;
    _categoryStoreList = null;
  }

  void clearCategoryData() {
    _currentCategoryId = null;
    _subCategoryList = null;
    _categoryItemList = null;
    _categoryStoreList = null;
    _searchItemList = [];
    _searchStoreList = [];
    _isSearching = false;
    _isLoading = false;
  }

  Future<void> getCategoryList(bool reload,
      {bool allCategory = false,
      DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    print("we get category list");
    if (_categoryList == null || reload || fromRecall) {
      if (reload) {
        _categoryList = null;
      }
      List<CategoryModel>? categoryList;
      if (dataSource == DataSourceEnum.local) {
        print("YES");
        categoryList = await categoryServiceInterface
            .getCategoryList(allCategory, source: DataSourceEnum.local);
        _prepareCategoryList(categoryList);
        getCategoryList(false,
            fromRecall: true,
            allCategory: allCategory,
            dataSource: DataSourceEnum.client);
      } else {
        print("NO");
        categoryList = await categoryServiceInterface
            .getCategoryList(allCategory, source: DataSourceEnum.client);
        _prepareCategoryList(categoryList);
      }
    }
  }

  _prepareCategoryList(List<CategoryModel>? categoryList) {
    if (categoryList != null) {
      _categoryList = [];
      _interestSelectedList = [];
      _categoryList!.addAll(categoryList);
      for (int i = 0; i < _categoryList!.length; i++) {
        _interestSelectedList!.add(false);
      }
    }
    update();
  }

  Future<void> loadCategoryData(String? categoryID, {bool reload = false, bool notify = true}) async {
    _subCategoryIndex = 0;
    final bool isDifferentCategory = _currentCategoryId != categoryID;
    _currentCategoryId = categoryID;

    if (reload || isDifferentCategory) {
      _subCategoryList = null;
      _categoryItemList = null;
      _categoryStoreList = null;
      _isSearching = false;
      _isLoading = true;
      if (notify) {
        update();
      }
    }

    // Step 1: Load from local SQLite cache for this specific category
    final localSubFuture = categoryServiceInterface.getSubCategoryList(categoryID, source: DataSourceEnum.local);
    final localItemFuture = categoryServiceInterface.getCategoryItemList(categoryID, 1, 'all', source: DataSourceEnum.local);

    final localResults = await Future.wait([localSubFuture, localItemFuture]);
    final List<CategoryModel>? localSub = localResults[0] as List<CategoryModel>?;
    final ItemModel? localItem = localResults[1] as ItemModel?;

    if (_currentCategoryId == categoryID) {
      if (localSub != null && localSub.isNotEmpty) {
        _subCategoryList = [
          // CategoryModel(id: int.parse(categoryID!), name: 'all'.tr),
          ...localSub,
        ];
      }
      if (localItem != null && localItem.items != null && localItem.items!.isNotEmpty) {
        _categoryItemList = localItem.items;
        _pageSize = localItem.totalSize;
      }
      if (_subCategoryList != null || _categoryItemList != null) {
        update();
      }
    }

    // Step 2: Fetch fresh data from network in parallel
    final clientSubFuture = categoryServiceInterface.getSubCategoryList(categoryID, source: DataSourceEnum.client);
    final clientItemFuture = categoryServiceInterface.getCategoryItemList(categoryID, 1, 'all', source: DataSourceEnum.client);

    final results = await Future.wait([clientSubFuture, clientItemFuture]);
    final List<CategoryModel>? clientSub = results[0] as List<CategoryModel>?;
    final ItemModel? clientItem = results[1] as ItemModel?;

    if (_currentCategoryId == categoryID) {
      if (clientSub != null) {
        _subCategoryList = [
          // CategoryModel(id: int.parse(categoryID!), name: 'all'.tr),
          ...clientSub,
        ];
      }
      if (clientItem != null && clientItem.items != null) {
        _categoryItemList = clientItem.items;
        _pageSize = clientItem.totalSize;
      }
      _isLoading = false;
      update();
    }

    String categoryName = 'Unknown';
    if (_categoryList != null) {
      try {
        categoryName = _categoryList!.firstWhere((element) => element.id.toString() == categoryID).name ?? 'Unknown';
      } catch (_) {}
    }
    try {
      Get.find<MetaAnalyticsService>().viewCategory(
        categoryId: categoryID ?? '',
        categoryName: categoryName,
      );
    } catch (_) {}
  }

  void getSubCategoryList(String? categoryID) async {
    await loadCategoryData(categoryID);
  }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    update(['sub_category']);
    final String? targetId = (_subCategoryList != null && _subCategoryList!.isNotEmpty && index < _subCategoryList!.length)
        ? _subCategoryList![index].id.toString()
        : categoryID;
    if (_isStore) {
      getCategoryStoreList(targetId, 1, _type, true);
    } else {
      getCategoryItemList(targetId, 1, _type, true);
    }
  }

  void getCategoryItemList(String? categoryID, int offset, String type, bool notify) async {
    if (offset > 1) return;
    _offset = 1;
    if (offset == 1) {
      if (_type == type) {
        _isSearching = false;
      }
      _type = type;
      if (notify) {
        update();
      }
      _categoryItemList = null;
    }
    ItemModel? categoryItem = await categoryServiceInterface.getCategoryItemList(categoryID, 1, type, source: DataSourceEnum.client);
    if (categoryItem != null) {
      _categoryItemList = categoryItem.items ?? [];
      _pageSize = categoryItem.totalSize;
      _isLoading = false;
    }
    update();
  }

  void getCategoryStoreList(String? categoryID, int offset, String type, bool notify) async {
    _offset = offset;
    if (offset == 1) {
      if (_type == type) {
        _isSearching = false;
      }
      _type = type;
      if (notify) {
        update();
      }
      _categoryStoreList = null;
    }
    StoreModel? categoryStore = await categoryServiceInterface.getCategoryStoreList(categoryID, offset, type);
    if (categoryStore != null) {
      if (offset == 1) {
        _categoryStoreList = [];
      }
      _categoryStoreList!.addAll(categoryStore.stores!);
      _restPageSize = categoryStore.totalSize;
      _isLoading = false;
    }
    update();
  }

  void searchData(String? query, String? categoryID, String type) async {
    if ((_isStore && query!.isNotEmpty) ||
        (!_isStore && query!.isNotEmpty /*&& query != _itemResultText*/)) {
      _searchText = query;
      _type = type;
      _isStore ? _searchStoreList = null : _searchItemList = null;
      _isSearching = true;
      update();

      Response response = await categoryServiceInterface.getSearchData(
          query, categoryID, _isStore, type);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          _isStore ? _searchStoreList = [] : _searchItemList = [];
        } else {
          if (_isStore) {
            _searchStoreList = [];
            _searchStoreList!
                .addAll(StoreModel.fromJson(response.body).stores!);
            update();
          } else {
            _searchItemList = [];
            _searchItemList!.addAll(ItemModel.fromJson(response.body).items!);
          }
        }
      }
      update();
    }
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _searchItemList = [];
    if (_categoryItemList != null) {
      _searchItemList!.addAll(_categoryItemList!);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<bool> saveInterest(List<int?> interests) async {
    _isLoading = true;
    update();
    bool isSuccess =
        await categoryServiceInterface.saveUserInterests(interests);
    _isLoading = false;
    update();
    return isSuccess;
  }

  void addInterestSelection(int index) {
    _interestSelectedList![index] = !_interestSelectedList![index];
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isStore = isRestaurant;
    update();
  }

  String? getCategoryNameById(int? id) {
    if (id == null || _categoryList == null) return null;
    for (CategoryModel category in _categoryList!) {
      if (category.id == id) return category.name;
    }
    return null;
  }
}
