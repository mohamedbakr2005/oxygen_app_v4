class DeepLinkParser {
  static const String _primaryHost = 'oxygenmart.online';
  static const String _secondaryHost = 'www.oxygenmart.online';

  static int? parseProductId(Uri? uri) {
    if (uri == null) {
      return null;
    }

    if (uri.scheme.isNotEmpty && uri.scheme != 'https' && uri.scheme != 'http') {
      return null;
    }

    if (uri.host.isNotEmpty &&
        uri.host != _primaryHost &&
        uri.host != _secondaryHost) {
      return null;
    }

    final List<String> segments =
        uri.pathSegments.where((String segment) => segment.isNotEmpty).toList();

    if (segments.length != 2 || segments.first.toLowerCase() != 'product') {
      return null;
    }

    final int? productId = int.tryParse(segments[1]);
    if (productId == null || productId <= 0) {
      return null;
    }

    return productId;
  }
}