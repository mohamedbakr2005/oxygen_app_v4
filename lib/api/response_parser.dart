class ResponseParser {
  const ResponseParser._();

  static dynamic payloadOf(dynamic decoded) {
    if (decoded is Map && decoded.containsKey('identical_code') && decoded['content'] != null) {
      return decoded['content'];
    }
    return decoded;
  }

  static List<dynamic>? listOf(dynamic body, {String? legacyKey}) {
    final dynamic unwrapped = payloadOf(body);
    if (unwrapped is List) return unwrapped;
    if (unwrapped is Map) {
      if (legacyKey != null) {
        final dynamic legacy = unwrapped[legacyKey];
        if (legacy is List) return legacy;
      }
      final dynamic data = unwrapped['data'];
      if (data is List) return data;
    }
    return null;
  }

  static List<dynamic> listOrEmpty(dynamic body, {String? legacyKey}) =>
      listOf(body, legacyKey: legacyKey) ?? <dynamic>[];

  static List<dynamic> namedListOf(dynamic body, String key) {
    if (body is Map) {
      final dynamic value = body[key];
      if (value is List) return value;
    }
    return <dynamic>[];
  }
}

