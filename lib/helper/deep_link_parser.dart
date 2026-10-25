class DeepLinkParser {
  static const String stagingHost = 'new.oxygenmart.online';
  static const String primaryHost = 'oxygenmart.online';
  static const String secondaryHost = 'www.oxygenmart.online';

  static const Set<String> _allowedHosts = {
    stagingHost,
    primaryHost,
    secondaryHost,
  };

  /// Extracts and validates the product ID from an incoming deep-link [Uri].
  ///
  /// Expected canonical formats:
  /// - `https://new.oxygenmart.online/product/{productId}`
  /// - `https://oxygenmart.online/product/{productId}`
  ///
  /// Also accepts supported legacy aliases:
  /// - `/item/{productId}`
  /// - `/product?id={productId}`
  /// - `/item?id={productId}`
  ///
  /// Returns a positive integer product ID if valid, or `null` if invalid,
  /// malformed, foreign host, or unrelated path.
  static int? parseProductId(Uri? uri) {
    if (uri == null) {
      return null;
    }

    // Must be https or http (or empty for relative/internal navigation)
    if (uri.scheme.isNotEmpty && uri.scheme != 'https' && uri.scheme != 'http') {
      return null;
    }

    // If host is present, validate it belongs to Oxygen Mart domain
    if (uri.host.isNotEmpty) {
      final String host = uri.host.toLowerCase();
      if (!_allowedHosts.contains(host)) {
        return null;
      }
    } else if (uri.scheme.isNotEmpty) {
      // Scheme present without host (e.g. https:///product/101) is invalid
      return null;
    }

    final List<String> segments =
        uri.pathSegments.where((String segment) => segment.trim().isNotEmpty).toList();

    if (segments.isEmpty) {
      return null;
    }

    final String firstSegment = segments.first.toLowerCase();
    if (firstSegment != 'product' && firstSegment != 'item') {
      return null;
    }

    // Path segment format: /product/101 or /product/101/slug
    if (segments.length >= 2) {
      final int? productId = int.tryParse(segments[1].trim());
      if (productId != null && productId > 0) {
        return productId;
      }
    }

    // Query parameter format: /product?id=101 or /item?id=101
    if (segments.length == 1) {
      final String? rawId = uri.queryParameters['id']?.trim();
      if (rawId != null && rawId.isNotEmpty) {
        final int? productId = int.tryParse(rawId);
        if (productId != null && productId > 0) {
          return productId;
        }
      }
    }

    return null;
  }
}