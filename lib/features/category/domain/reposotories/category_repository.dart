import 'dart:convert';

import 'package:get/get.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/api/local_client.dart';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/features/category/domain/models/category_model.dart';
import 'package:Oxygen_Mart/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;
  CategoryRepository({required this.apiClient});

  @override
  Future getList(
      {int? offset,
      bool categoryList = false,
      bool subCategoryList = false,
      bool categoryItemList = false,
      bool categoryStoreList = false,
      bool? allCategory,
      String? id,
      String? type,
      DataSourceEnum? source}) async {
    if (categoryList) {
      return await _getCategoryList(
          allCategory!, source ?? DataSourceEnum.client);
    } else if (subCategoryList) {
      return await _getSubCategoryList(id, source ?? DataSourceEnum.client);
    } else if (categoryItemList) {
      return await _getCategoryItemList(id, offset!, type!, source ?? DataSourceEnum.client);
    } else if (categoryStoreList) {
      return await _getCategoryStoreList(id, offset!, type!);
    }
  }

  Future<List<CategoryModel>?> _getCategoryList(
      bool allCategory, DataSourceEnum source) async {
    List<CategoryModel>? categoryList;
    Map<String, String>? header = allCategory
        ? {
            'Content-Type': 'application/json; charset=UTF-8',
            AppConstants.localizationKey:
                Get.find<LocalizationController>().locale.languageCode,
          }
        : null;

    Map<String, String>? cacheHeader = header ?? apiClient.getHeader();

    String cacheId = AppConstants.categoryUri +
        (Get.find<SplashController>().module?.id?.toString() ?? '0');

    switch (source) {
      case DataSourceEnum.client:
        Response response =
            await apiClient.getData(AppConstants.categoryUri, headers: header);
        if (ApiClient.isSuccessCode(response.statusCode)) {
          final List<dynamic> categoriesJson = ResponseParser.listOrEmpty(response.body);
          categoryList = [];
          for (final dynamic category in categoriesJson) {
            categoryList!.add(CategoryModel.fromJson(category));
          }
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(categoriesJson), cacheHeader);
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(
            DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          categoryList = [];
          for (final dynamic category in ResponseParser.listOrEmpty(jsonDecode(cacheResponseData))) {
            categoryList!.add(CategoryModel.fromJson(category));
          }
        }
    }

    return categoryList;
  }

  Future<List<CategoryModel>?> _getSubCategoryList(String? parentID, DataSourceEnum source) async {
    List<CategoryModel>? subCategoryList;
    String cacheId = '${AppConstants.subCategoryUri}$parentID';

    switch (source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(cacheId);
        if (ApiClient.isSuccessCode(response.statusCode)) {
          final List<dynamic> subCategoriesJson = ResponseParser.listOrEmpty(response.body);
          subCategoryList = [];
          for (final dynamic category in subCategoriesJson) {
            subCategoryList.add(CategoryModel.fromJson(category));
          }
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(subCategoriesJson), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(
            DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          subCategoryList = [];
          for (final dynamic category in ResponseParser.listOrEmpty(jsonDecode(cacheResponseData))) {
            subCategoryList.add(CategoryModel.fromJson(category));
          }
        }
    }

    return subCategoryList;
  }

  Future<ItemModel?> _getCategoryItemList(
      String? categoryID, int offset, String type, DataSourceEnum source) async {
    ItemModel? categoryItem;
    String cacheId = '${AppConstants.categoryItemUri}$categoryID?limit=1000&offset=1&type=$type';

    switch (source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(cacheId);
        if (response.statusCode == 200) {
          categoryItem = ItemModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId,
              jsonEncode(response.body), apiClient.getHeader());
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(
            DataSourceEnum.local, cacheId, null, null);
        if (cacheResponseData != null) {
          categoryItem = ItemModel.fromJson(jsonDecode(cacheResponseData));
        }
    }

    return categoryItem;
  }

  Future<StoreModel?> _getCategoryStoreList(
      String? categoryID, int offset, String type) async {
    StoreModel? categoryStore;
    Response response = await apiClient.getData(
        '${AppConstants.categoryStoreUri}$categoryID?limit=10&offset=$offset&type=$type');
    if (response.statusCode == 200) {
      categoryStore = StoreModel.fromJson(response.body);
    }
    return categoryStore;
  }

  @override
  Future<Response> getSearchData(
      String? query, String? categoryID, bool isStore, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
    );
  }

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    Response response = await apiClient
        .postData(AppConstants.interestUri, {"interest": interests});
    return (response.statusCode == 200);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
