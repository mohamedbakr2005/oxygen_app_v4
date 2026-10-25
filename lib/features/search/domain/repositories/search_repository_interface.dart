import 'package:Oxygen_Mart/features/search/domain/models/popular_categories_model.dart';
import 'package:Oxygen_Mart/features/search/domain/models/search_suggestion_model.dart';
import 'package:Oxygen_Mart/features/search/domain/models/top_category_model.dart';
import 'package:Oxygen_Mart/features/search/domain/models/trending_search_model.dart';
import 'package:Oxygen_Mart/interfaces/repository_interface.dart';

abstract class SearchRepositoryInterface extends RepositoryInterface {
  Future<bool> saveSearchHistory(List<String> searchHistories);
  List<String> getSearchAddress();
  Future<bool> clearSearchHistory();
  @override
  Future getList(
      {int? offset,
      String? query,
      bool? isStore,
      bool isSuggestedItems = false});
  Future<SearchSuggestionModel?> getSearchSuggestions(String searchText);
  Future<List<PopularCategoryModel?>?> getPopularCategories();
  Future<List<TopCategory>?> getTopCategories({int offset = 1});
  Future<List<TrendingSearch>?> getTrendingSearches({bool isGlobal = false});
}

