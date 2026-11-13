import 'package:flutter_test/flutter_test.dart';
import 'package:Oxygen_Mart/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:Oxygen_Mart/features/bundle/domain/models/bundle_model.dart';
import 'package:Oxygen_Mart/features/happy_hour/domain/models/happy_hour_model.dart';

void main() {
  group('Phase 3 New Features - Model Serialization & Deserialization Tests', () {
    test('HappyHourModel parses correctly from JSON', () {
      final Map<String, dynamic> json = {
        'is_running': true,
        'happy_hour': {
          'id': 101,
          'slug': 'happy-hour-special',
          'title': 'Night Mega Discount',
          'short_description': '20% off all orders',
          'cover_image_full_url': 'https://example.com/cover.png',
          'icon_full_url': 'https://example.com/icon.png',
          'discount': 20.0,
          'min_order_amount': 50.0,
          'is_permanent': false,
        }
      };

      final running = RunningHappyHourModel.fromJson(json);
      expect(running.isRunning, true);
      expect(running.happyHour, isNotNull);
      expect(running.happyHour!.id, 101);
      expect(running.happyHour!.title, 'Night Mega Discount');
      expect(running.happyHour!.discount, 20.0);
      expect(running.happyHour!.minOrderAmount, 50.0);
    });

    test('BogoOfferCardModel parses correctly from JSON', () {
      final Map<String, dynamic> json = {
        'id': 12,
        'slug': 'bogo-burger-deal',
        'title': 'Buy 1 Burger Get 1 Free',
        'buy_qty': 1,
        'get_qty': 1,
        'offer_label': 'Buy 1 Get 1',
        'remaining_uses': 3,
      };

      final bogo = BogoOfferCardModel.fromJson(json);
      expect(bogo.id, 12);
      expect(bogo.slug, 'bogo-burger-deal');
      expect(bogo.title, 'Buy 1 Burger Get 1 Free');
      expect(bogo.buyQty, 1);
      expect(bogo.getQty, 1);
      expect(bogo.remainingUses, 3);
    });

    test('BundleModel parses correctly from JSON', () {
      final Map<String, dynamic> json = {
        'id': 55,
        'name': 'Family Meal Bundle',
        'store_id': 9,
        'store_name': 'Tasty Grill',
        'base_price': 150.0,
        'bundle_price': 120.0,
        'is_available': true,
        'items': [
          {'id': 1, 'name': 'Burger', 'price': 50.0, 'quantity': 2},
          {'id': 2, 'name': 'Fries', 'price': 25.0, 'quantity': 2},
        ]
      };

      final bundle = Bundle.fromJson(json);
      expect(bundle.id, 55);
      expect(bundle.name, 'Family Meal Bundle');
      expect(bundle.storeId, 9);
      expect(bundle.basePrice, 150.0);
      expect(bundle.bundlePrice, 120.0);
      expect(bundle.isAvailable, true);
      expect(bundle.items?.length, 2);
    });
  });
}
