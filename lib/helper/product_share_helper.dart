import 'package:share_plus/share_plus.dart';

class ProductShareHelper {
  /// Current active product deep-link base URL.
  /// When deploying to production on oxygenmart.online, change this to:
  /// static const String productBaseUrl = 'https://oxygenmart.online/product';
  static const String productBaseUrl = 'https://new.oxygenmart.online/product';
  static const String _sharePrefix = 'Check out this product on Oxygen Mart:';

  static String buildProductDeepLink(int productId) {
    return '$productBaseUrl/$productId';
  }

  static String buildProductShareText(int productId) {
    return '$_sharePrefix\n${buildProductDeepLink(productId)}';
  }

  static Future<void> shareProduct(int? productId) async {
    if (productId == null || productId <= 0) {
      return;
    }

    await Share.share(buildProductShareText(productId));
  }
}
