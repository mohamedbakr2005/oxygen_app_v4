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

  void clearCategoryList() {
    _categoryList = null;
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

  void getSubCategoryList(String? categoryID) async {
    _subCategoryIndex = 0;
    _subCategoryList = null;
    _categoryItemList = null;
    List<CategoryModel>? subCategoryList =
        await categoryServiceInterface.getSubCategoryList(categoryID);
    if (subCategoryList != null) {
      _subCategoryList = [];
      _subCategoryList!
          .add(CategoryModel(id: int.parse(categoryID!), name: 'all'.tr));
      _subCategoryList!.addAll(subCategoryList);
      getCategoryItemList(categoryID, 1, 'all', false);
      
      String categoryName = 'Unknown';
      if (_categoryList != null && categoryID != null) {
        try {
          categoryName = _categoryList!.firstWhere((element) => element.id.toString() == categoryID).name ?? 'Unknown';
        } catch (e) {}
      }
      Get.find<MetaAnalyticsService>().viewCategory(
        categoryId: categoryID ?? 'unknown',
        categoryName: categoryName,
      );
    }
  }

  void setSubCategoryIndex(int index, String? categoryID) {
    _subCategoryIndex = index;
    update(['sub_category']);
    if (_isStore) {
      getCategoryStoreList(
          _subCategoryIndex == 0
              ? categoryID
              : _subCategoryList![index].id.toString(),
          1,
          _type,
          true);
    } else {
      getCategoryItemList(
          _subCategoryIndex == 0
              ? categoryID
              : _subCategoryList![index].id.toString(),
          1,
          _type,
          true);
    }
  }

  void getCategoryItemList(
      String? categoryID, int offset, String type, bool notify) async {
    if (offset > 1) return; // Ignore any pagination requests

    print("ENTER getCategoryItemList");
    print("categoryID=$categoryID");
    print("offset=$offset");
    print("type=$type");

    _offset = 1;

    _categoryItemList = null;
    
    if (notify) {
      update();
    }

    ItemModel? categoryItem = await categoryServiceInterface
        .getCategoryItemList(categoryID, 1, type);

    print("API RESULT = ${categoryItem != null}");

    if (categoryItem != null) {
      print("ITEMS COUNT = ${categoryItem.items?.length}");
      print("TOTAL SIZE = ${categoryItem.totalSize}");

      // Store all returned products directly, replacing addAll to prevent duplicates
      _categoryItemList = categoryItem.items ?? [];

      print("FINAL LIST COUNT = ${_categoryItemList!.length}");

      _pageSize = categoryItem.totalSize;
      _isLoading = false;
    }

    update();
  }

  void getCategoryStoreList(
      String? categoryID, int offset, String type, bool notify) async {
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
    StoreModel? categoryStore = await categoryServiceInterface
        .getCategoryStoreList(categoryID, offset, type);
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
}
