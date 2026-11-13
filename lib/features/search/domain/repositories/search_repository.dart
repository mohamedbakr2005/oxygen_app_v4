import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/features/brands/domain/models/brands_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/search/domain/models/popular_categories_model.dart';
import 'package:Oxygen_Mart/features/search/domain/models/search_suggestion_model.dart';
import 'package:Oxygen_Mart/features/search/domain/models/top_category_model.dart';
import 'package:Oxygen_Mart/features/search/domain/models/trending_search_model.dart';
import 'package:Oxygen_Mart/features/search/domain/repositories/search_repository_interface.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class SearchRepository implements SearchRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SearchRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<bool> saveSearchHistory(List<String> searchHistories) async {
    return await sharedPreferences.setStringList(
        AppConstants.searchHistory, searchHistories);
  }

  @override
  List<String> getSearchAddress() {
    return sharedPreferences.getStringList(AppConstants.searchHistory) ?? [];
  }

  @override
  Future<bool> clearSearchHistory() async {
    return sharedPreferences.setStringList(AppConstants.searchHistory, []);
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
  Future getList(
      {int? offset,
      String? query,
      bool? isStore,
      bool isSuggestedItems = false,
      int? moduleId,
      Map<String, String>? filterParams}) async {
    if (isSuggestedItems) {
      return await _getSuggestedItems();
    } else {
      return await _getSearchData(query, isStore!, offset ?? 1, moduleId: moduleId, filterParams: filterParams);
    }
  }

  Future<List<Item>?> _getSuggestedItems() async {
    List<Item>? suggestedItemList;
    Response response = await apiClient.getData(AppConstants.suggestedItemUri);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      suggestedItemList = [];
      for (final dynamic suggestedItem in ResponseParser.listOrEmpty(response.body)) {
        suggestedItemList.add(Item.fromJson(suggestedItem));
      }
    }
    return suggestedItemList;
  }

  Future<Response> _getSearchData(
    String? query,
    bool isStore,
    int offset, {
    int? moduleId,
    Map<String, String>? filterParams,
  }) async {
    final Map<String, String>? headers = moduleId != null
        ? {...apiClient.getHeader(), AppConstants.moduleId: moduleId.toString()}
        : null;
    final bool isServiceModule = Get.isRegistered<SplashController>() &&
        Get.find<SplashController>().module?.moduleType == AppConstants.service;
    final String searchPath = (isServiceModule && !isStore)
        ? AppConstants.serviceSearchUri
        : '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search';
    final StringBuffer uri = StringBuffer(
      '$searchPath?name=${Uri.encodeQueryComponent(query ?? '')}&offset=$offset&limit=10',
    );
    filterParams?.forEach((String key, String value) {
      uri.write('&$key=$value');
    });

    return await apiClient.getData(uri.toString(), headers: headers);
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<SearchSuggestionModel?> getSearchSuggestions(String searchText, {bool isGlobal = false}) async {
    SearchSuggestionModel? searchSuggestionModel;
    final Map<String, String> headers = {...apiClient.getHeader()};
    if (isGlobal) {
      headers.remove(AppConstants.moduleId);
    }
    final bool isServiceModule = Get.isRegistered<SplashController>() &&
        Get.find<SplashController>().module?.moduleType == AppConstants.service;
    final String baseUri = isServiceModule ? AppConstants.serviceItemOrStoreSearchUri : AppConstants.searchSuggestionsUri;
    Response response = await apiClient.getData(
      '$baseUri?name=${Uri.encodeQueryComponent(searchText)}&is_global=${isGlobal ? 1 : 0}',
      headers: headers,
    );
    if (response.statusCode == 200) {
      searchSuggestionModel = SearchSuggestionModel.fromJson(response.body);
    }
    return searchSuggestionModel;
  }

  @override
  Future<List<PopularCategoryModel?>?> getPopularCategories() async {
    List<PopularCategoryModel?>? popularCategoryList;
    Response response =
        await apiClient.getData(AppConstants.searchPopularCategoriesUri);
    if (ApiClient.isSuccessCode(response.statusCode)) {
      popularCategoryList = [];
      for (final dynamic category in ResponseParser.listOrEmpty(response.body)) {
        popularCategoryList.add(PopularCategoryModel.fromJson(category));
      }
    }
    return popularCategoryList;
  }

  @override
  Future<List<BrandModel>?> getBrandList({
    required int moduleId,
    required List<int> zoneIds,
  }) async {
    List<BrandModel>? brandList;
    final Map<String, String> headers = {
      ...apiClient.getHeader(),
      AppConstants.moduleId: moduleId.toString(),
      AppConstants.zoneId: jsonEncode(zoneIds),
      'top': '1',
    };
    Response response = await apiClient.getData(
      AppConstants.brandListUri,
      headers: headers,
    );
    if (response.statusCode == 200) {
      brandList = [];
      for (final dynamic brand in ResponseParser.listOrEmpty(response.body)) {
        brandList.add(BrandModel.fromJson(brand));
      }
    }
    return brandList;
  }

  @override
  Future<List<Store>?> getExclusiveDeals() async {
    List<Store>? stores;
    Response response = await apiClient.getData(AppConstants.exclusiveDealsUri);
    if (response.statusCode == 200) {
      stores = StoreModel.fromJson(response.body).stores;
    }
    return stores;
  }

  @override
  Future<List<TrendingSearch>?> getTrendingSearches({bool isGlobal = false}) async {
    List<TrendingSearch>? trendingSearches;
    final Map<String, String>? headers = isGlobal
        ? ({...apiClient.getHeader()}..remove(AppConstants.moduleId))
        : null;
    Response response = await apiClient.getData(
      '${AppConstants.trendingSearchesUri}${isGlobal ? '?is_global=true' : ''}',
      headers: headers,
    );
    if (response.statusCode == 200) {
      trendingSearches = TrendingSearchModel.fromJson(response.body).trendingSearches;
    }
    return trendingSearches;
  }

  @override
  Future<List<TopCategory>?> getTopCategories({int offset = 1}) async {
    List<TopCategory>? categories;
    final Map<String, String> headers = {...apiClient.getHeader()}..remove(AppConstants.moduleId);
    Response response = await apiClient.getData(
      '${AppConstants.topCategoriesUri}?limit=10&offset=$offset',
      headers: headers,
    );
    if (response.statusCode == 200) {
      categories = TopCategoryModel.fromJson(response.body).categories;
    }
    return categories;
  }
}
