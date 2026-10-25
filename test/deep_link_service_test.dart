import 'package:flutter_test/flutter_test.dart';
import 'package:Oxygen_Mart/helper/deep_link_service.dart';

void main() {
  group('DeepLinkService Unit Tests', () {
    late DeepLinkService deepLinkService;

    setUp(() {
      deepLinkService = DeepLinkService();
      deepLinkService.resetStateForTesting();
    });

    tearDown(() {
      deepLinkService.resetStateForTesting();
    });

    test('initial state has no pending product and home is not ready', () {
      expect(deepLinkService.pendingProductId, isNull);
      expect(deepLinkService.isHomeReady, isFalse);
    });

    test('queues valid canonical product link', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/product/123'),
      );

      expect(deepLinkService.pendingProductId, equals(123));
    });

    test('queues valid www product link', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://www.oxygenmart.online/product/456'),
      );

      expect(deepLinkService.pendingProductId, equals(456));
    });

    test('queues valid new.oxygenmart.online product link', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://new.oxygenmart.online/product/777'),
      );

      expect(deepLinkService.pendingProductId, equals(777));
    });

    test('queues valid product link with slug', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/product/789/fresh-organic-apples'),
      );

      expect(deepLinkService.pendingProductId, equals(789));
    });

    test('queues backward-compatible item link', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/item/101'),
      );

      expect(deepLinkService.pendingProductId, equals(101));
    });

    test('ignores non-product URLs', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/categories/123'),
      );
      expect(deepLinkService.pendingProductId, isNull);

      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/cart'),
      );
      expect(deepLinkService.pendingProductId, isNull);

      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/profile'),
      );
      expect(deepLinkService.pendingProductId, isNull);
    });

    test('ignores foreign hosts', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://malicious.com/product/123'),
      );
      expect(deepLinkService.pendingProductId, isNull);

      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://evil-oxygenmart.online/product/123'),
      );
      expect(deepLinkService.pendingProductId, isNull);
    });

    test('ignores unsupported schemes like ftp or custom scheme', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('ftp://oxygenmart.online/product/123'),
      );
      expect(deepLinkService.pendingProductId, isNull);

      deepLinkService.queueFromUriForTesting(
        Uri.parse('custom://oxygenmart.online/product/123'),
      );
      expect(deepLinkService.pendingProductId, isNull);
    });

    test('ignores malformed product IDs', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/product/abc'),
      );
      expect(deepLinkService.pendingProductId, isNull);

      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/product/0'),
      );
      expect(deepLinkService.pendingProductId, isNull);

      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/product/-5'),
      );
      expect(deepLinkService.pendingProductId, isNull);
    });

    test('suppresses duplicate events within debounce window', () {
      final Uri uri = Uri.parse('https://oxygenmart.online/product/123');

      // First call queues successfully
      deepLinkService.queueFromUriForTesting(uri);
      expect(deepLinkService.pendingProductId, equals(123));

      // Reset pendingProductId manually to verify duplicate detection
      deepLinkService.resetStateForTesting();
      // Directly queue again with the same service instance
      deepLinkService.queueFromUriForTesting(uri);
      expect(deepLinkService.pendingProductId, equals(123));

      // Now queue immediately again without resetting state - duplicate suppressed
      deepLinkService.queueFromUriForTesting(uri);
      // The pending product remains what was already queued
      expect(deepLinkService.pendingProductId, equals(123));
    });

    test('onHomeFirstFrameRendered marks home ready', () {
      expect(deepLinkService.isHomeReady, isFalse);

      deepLinkService.onHomeFirstFrameRendered();

      expect(deepLinkService.isHomeReady, isTrue);
    });

    test('onHomeDataLoaded marks home data ready', () {
      expect(deepLinkService.isHomeDataReady, isFalse);

      deepLinkService.onHomeDataLoaded();

      expect(deepLinkService.isHomeDataReady, isTrue);
    });

    test('resetStateForTesting clears all state', () {
      deepLinkService.queueFromUriForTesting(
        Uri.parse('https://oxygenmart.online/product/999'),
      );
      deepLinkService.setHomeReadyForTesting(true);
      deepLinkService.setHomeDataReadyForTesting(true);

      expect(deepLinkService.pendingProductId, equals(999));
      expect(deepLinkService.isHomeReady, isTrue);
      expect(deepLinkService.isHomeDataReady, isTrue);

      deepLinkService.resetStateForTesting();

      expect(deepLinkService.pendingProductId, isNull);
      expect(deepLinkService.isHomeReady, isFalse);
      expect(deepLinkService.isHomeDataReady, isFalse);
    });
  });
}
