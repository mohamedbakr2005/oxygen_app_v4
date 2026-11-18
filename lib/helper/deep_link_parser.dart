class DeepLinkParser {
  static const String stagingHost = 'new.oxygenmart.online';
  static const String primaryHost = 'oxygenmart.online';
  static const String secondaryHost = 'www.oxygenmart.online';

  static const String customScheme = 'oxygenmart';

  static const Set<String> _allowedHosts = {
    stagingHost,
    primaryHost,
    secondaryHost,
  };

  /// Extracts and validates the product ID from an incoming deep-link [Uri].
  ///
  /// Expected canonical formats:
  /// - `https://oxygenmart.online/product/{productId}`
  /// - `https://new.oxygenmart.online/product/{productId}`
  /// - `oxygenmart://product/{productId}` (iOS custom URL scheme fallback)
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

    final String scheme = uri.scheme.toLowerCase();
    final bool isCustomScheme = scheme == customScheme;

    // Must be https, http, oxygenmart custom scheme, or empty for relative navigation
    if (scheme.isNotEmpty &&
        scheme != 'https' &&
        scheme != 'http' &&
        !isCustomScheme) {
      return null;
    }

    final List<String> rawSegments = uri.pathSegments
        .where((String segment) => segment.trim().isNotEmpty)
        .toList();

    final List<String> segments;
    if (isCustomScheme) {
      final String host = uri.host.toLowerCase();
      if (host == 'product' || host == 'item') {
        segments = <String>[host, ...rawSegments];
      } else if (_allowedHosts.contains(host)) {
        segments = rawSegments;
      } else {
        return null;
      }
    } else {
      // If host is present, validate it belongs to Oxygen Mart domain
      if (uri.host.isNotEmpty) {
        final String host = uri.host.toLowerCase();
        if (!_allowedHosts.contains(host)) {
          return null;
        }
      } else if (scheme.isNotEmpty) {
        // Scheme present without host (e.g. https:///product/101) is invalid
        return null;
      }
      segments = rawSegments;
    }

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