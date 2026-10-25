import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/features/category/domain/models/category_model.dart';
import 'package:Oxygen_Mart/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:Oxygen_Mart/features/category/domain/services/category_service_interface.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';

class CategoryService implements CategoryServiceInterface {
  final CategoryRepositoryInterface categoryRepositoryInterface;
  CategoryService({required this.categoryRepositoryInterface});

  @override
  Future<List<CategoryModel>?> getCategoryList(bool allCategory,
      {DataSourceEnum? source}) async {
    return await categoryRepositoryInterface.getList(
        allCategory: allCategory, categoryList: true, source: source);
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID,
      {DataSourceEnum? source}) async {
    return await categoryRepositoryInterface.getList(
        id: parentID, subCategoryList: true, source: source);
  }

  @override
  Future<ItemModel?> getCategoryItemList(
      String? categoryID, int offset, String type,
      {DataSourceEnum? source}) async {
    return await categoryRepositoryInterface.getList(
        id: categoryID, offset: offset, type: type, categoryItemList: true, source: source);
  }

  @override
  Future<StoreModel?> getCategoryStoreList(
      String? categoryID, int offset, String type) async {
    return await categoryRepositoryInterface.getList(
        id: categoryID, offset: offset, type: type, categoryStoreList: true);
  }

  @override
  Future<Response> getSearchData(
      String? query, String? categoryID, bool isStore, String type) async {
    return await categoryRepositoryInterface.getSearchData(
        query, categoryID, isStore, type);
  }

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    return await categoryRepositoryInterface.saveUserInterests(interests);
  }
}
