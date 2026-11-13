import 'package:Oxygen_Mart/local/cache_response.dart';

final database = AppDatabase();

class DbHelper {
  static Future<void> insertOrUpdate(
      {required String id, required CacheResponseCompanion data}) async {
    try {
      final response = await database.getCacheResponseById(id);

      if (response != null) {
        await database.updateCacheResponse(id, data);
      } else {
        await database.insertCacheResponse(data);
      }
    } catch (e) {
      // Ignore cache race condition conflicts
    }
  }
}
