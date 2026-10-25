import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/cart_suggested_item_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/recommended_product_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_banner_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_category_item_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';

abstract class StoreServiceInterface {
  Future<StoreModel?> getStoreList(
      int offset, String filterBy, String storeType,
      {required DataSourceEnum source});
  Future<List<Store>?> getPopularStoreList(String type,
      {required DataSourceEnum source});
  Future<List<Store>?> getLatestStoreList(String type,
      {required DataSourceEnum source});
  Future<List<Store>?> getTopOfferStoreList({required DataSourceEnum source});
  Future<List<Store>?> getFeaturedStoreList({required DataSourceEnum source});
  Future<List<Store>?> getVisitAgainStoreList({required DataSourceEnum source});
  Future<Store?> getStoreDetails(
      String storeID,
      bool fromCart,
      String slug,
      String languageCode,
      ModuleModel? module,
      int? cacheModuleId,
      int? moduleId);
  Future<ItemModel?> getStoreItemList(
      int? storeID, int offset, int? categoryID, String type);
  Future<ItemModel?> getStoreSearchItemList(String searchText, String? storeID,
      int offset, String type, int? categoryID);
  Future<RecommendedItemModel?> getStoreRecommendedItemList(int? storeId);
  Future<CartSuggestItemModel?> getCartStoreSuggestedItemList(
      int? storeId,
      String languageCode,
      ModuleModel? module,
      int? cacheModuleId,
      int? moduleId);
  Future<List<StoreBannerModel>?> getStoreBannerList(int? storeId);
  Future<List<Store>?> getRecommendedStoreList(
      {required DataSourceEnum source});
  List<Modules> moduleList();
  String filterRestaurantLinkUrl(String slug, Store store);
  Future<StoreModel?> getQuickDeliveryStores({int offset, int limit, int? moduleId, String name});
  Future<StoreModel?> getNearbyStores({int offset, int limit, int? moduleId, String name});
  Future<StoreCategoryItemModel?> getStoreCategoryItems(int storeId);
}
