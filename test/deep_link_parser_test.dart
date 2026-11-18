import 'package:flutter_test/flutter_test.dart';
import 'package:Oxygen_Mart/helper/deep_link_parser.dart';

void main() {
  group('DeepLinkParser Tests', () {
    test('parses canonical product deep link correctly', () {
      final uri = Uri.parse('https://oxygenmart.online/product/101');
      expect(DeepLinkParser.parseProductId(uri), equals(101));
    });

    test('parses www host canonical product deep link correctly', () {
      final uri = Uri.parse('https://www.oxygenmart.online/product/202');
      expect(DeepLinkParser.parseProductId(uri), equals(202));
    });

    test('parses new.oxygenmart.online staging host deep link correctly', () {
      final uri = Uri.parse('https://new.oxygenmart.online/product/250');
      expect(DeepLinkParser.parseProductId(uri), equals(250));
    });

    test('parses http scheme product deep link gracefully', () {
      final uri = Uri.parse('http://oxygenmart.online/product/303');
      expect(DeepLinkParser.parseProductId(uri), equals(303));
    });

    test('handles trailing slashes gracefully', () {
      final uri = Uri.parse('https://oxygenmart.online/product/404/');
      expect(DeepLinkParser.parseProductId(uri), equals(404));
    });

    test('parses product link with query parameters attached', () {
      final uri = Uri.parse('https://oxygenmart.online/product/101?utm_source=whatsapp&fbclid=xyz');
      expect(DeepLinkParser.parseProductId(uri), equals(101));
    });

    test('parses product link with slug after ID', () {
      final uri = Uri.parse('https://oxygenmart.online/product/101/fresh-milk-1-liter');
      expect(DeepLinkParser.parseProductId(uri), equals(101));
    });

    test('handles uppercase host and path correctly', () {
      final uri = Uri.parse('https://OXYGENMART.ONLINE/PRODUCT/808');
      expect(DeepLinkParser.parseProductId(uri), equals(808));
    });

    test('parses legacy item path alias correctly', () {
      final uri = Uri.parse('https://oxygenmart.online/item/505');
      expect(DeepLinkParser.parseProductId(uri), equals(505));
    });

    test('parses query parameter format for product', () {
      final uri = Uri.parse('https://oxygenmart.online/product?id=606');
      expect(DeepLinkParser.parseProductId(uri), equals(606));
    });

    test('parses query parameter format for item', () {
      final uri = Uri.parse('https://oxygenmart.online/item?id=707');
      expect(DeepLinkParser.parseProductId(uri), equals(707));
    });

    test('returns null for null URI', () {
      expect(DeepLinkParser.parseProductId(null), isNull);
    });

    test('returns null for foreign host', () {
      final uri = Uri.parse('https://evil.com/product/101');
      expect(DeepLinkParser.parseProductId(uri), isNull);
    });

    test('returns null for phishing or unknown subdomain', () {
      final uri = Uri.parse('https://phishing.oxygenmart.online/product/101');
      expect(DeepLinkParser.parseProductId(uri), isNull);
    });

    test('returns null for unsupported scheme', () {
      final uri = Uri.parse('ftp://oxygenmart.online/product/101');
      expect(DeepLinkParser.parseProductId(uri), isNull);
    });

    test('returns null for missing host when scheme is specified', () {
      final uri = Uri.parse('https:///product/101');
      expect(DeepLinkParser.parseProductId(uri), isNull);
    });

    test('returns null for non-product path', () {
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/categories/101')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/store/101')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/cart')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/terms-and-conditions')), isNull);
    });

    test('returns null for invalid/non-numeric product id', () {
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/product/abc')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/product/12.34')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/product/')), isNull);
    });

    test('returns null for zero or negative product id', () {
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/product/0')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/product/-5')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/product?id=0')), isNull);
      expect(DeepLinkParser.parseProductId(Uri.parse('https://oxygenmart.online/product?id=-1')), isNull);
    });

    test('parses iOS custom URL scheme product deep links correctly', () {
      expect(DeepLinkParser.parseProductId(Uri.parse('oxygenmart://product/101')), equals(101));
      expect(DeepLinkParser.parseProductId(Uri.parse('oxygenmart://item/202')), equals(202));
      expect(DeepLinkParser.parseProductId(Uri.parse('oxygenmart://product?id=303')), equals(303));
      expect(DeepLinkParser.parseProductId(Uri.parse('oxygenmart://oxygenmart.online/product/404')), equals(404));
      expect(DeepLinkParser.parseProductId(Uri.parse('oxygenmart://evil.com/product/101')), isNull);
    });
  });
}
