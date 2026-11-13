import 'package:Oxygen_Mart/api/response_parser.dart';

class PromotionalBanner {
  String? basicSectionNearbyFullUrl;
  String? bottomSectionBannerFullUrl;

  PromotionalBanner({
    this.basicSectionNearbyFullUrl,
    this.bottomSectionBannerFullUrl,
  });

  factory PromotionalBanner.fromResponse(dynamic body) {
    if (body is Map) {
      final dynamic flat = body['bottom_section_banner_full_url'];
      final dynamic nearby = body['basic_section_nearby_full_url'];
      return PromotionalBanner(
        basicSectionNearbyFullUrl: nearby is String ? nearby : null,
        bottomSectionBannerFullUrl: flat is String && flat.isNotEmpty ? flat : _firstBannerUrlIn(body),
      );
    }
    return PromotionalBanner(bottomSectionBannerFullUrl: _firstBannerUrlIn(body));
  }

  static String? _firstBannerUrlIn(dynamic body) {
    for (final dynamic entry in ResponseParser.listOrEmpty(body)) {
      if (entry is Map) {
        final dynamic url = entry['value_full_url'];
        if (url is String && url.isNotEmpty) return url;
      }
    }
    return null;
  }

  PromotionalBanner.fromJson(Map<String, dynamic> json) {
    basicSectionNearbyFullUrl = json['basic_section_nearby_full_url'];
    bottomSectionBannerFullUrl = json['bottom_section_banner_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['basic_section_nearby_full_url'] = basicSectionNearbyFullUrl;
    data['bottom_section_banner_full_url'] = bottomSectionBannerFullUrl;
    return data;
  }
}