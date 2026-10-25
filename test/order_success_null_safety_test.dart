import 'package:flutter_test/flutter_test.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';

void main() {
  group('Order Success & Checkout Null-Safety Tests', () {
    test('RouteHelper.getOrderSuccessRoute generates valid URI with null contact and customer info', () {
      final route = RouteHelper.getOrderSuccessRoute('100456', null);
      expect(route, contains('id=100456'));
      expect(route, contains('contact_number='));
      expect(route, contains('create_account=null'));
    });

    test('RouteHelper.getOrderSuccessRoute handles phone, createAccount, name, and email correctly', () {
      final route = RouteHelper.getOrderSuccessRoute(
        '100456',
        '+201028972661',
        createAccount: true,
        guestId: 'guest-123',
        customerName: 'Test Customer',
        customerEmail: 'test@example.com',
      );
      expect(route, contains('id=100456'));
      expect(route, contains('contact_number=%2B201028972661'));
      expect(route, contains('create_account=true'));
      expect(route, contains('guest_id=guest-123'));
      expect(route, contains('customer_name=Test%20Customer'));
      expect(route, contains('customer_email=test%40example.com'));
    });

    test('OrderId query parameter sanitization extracts pure order ID', () {
      // Test when order ID contains trailing query parameters e.g. from callbacks
      String rawId = '100789?status=paid';
      String sanitizedId = rawId;
      if (sanitizedId.contains('?')) {
        sanitizedId = sanitizedId.split('?')[0].trim();
      }
      expect(sanitizedId, equals('100789'));
      expect(int.tryParse(sanitizedId), equals(100789));

      // Test when order ID is null or empty
      String? nullId;
      final int? parsedNull = int.tryParse(nullId ?? '');
      expect(parsedNull, isNull);

      String emptyId = '';
      final int? parsedEmpty = int.tryParse(emptyId);
      expect(parsedEmpty, isNull);
    });

    test('Loyalty point calculation safely handles null amounts and fallback rates', () {
      double calculateTotal({double? orderAmount, double? loyaltyRate}) {
        final double amt = orderAmount ?? 0.0;
        final double rate = loyaltyRate ?? 1.0;
        return (amt / 100) * rate;
      }

      // Normal case
      expect(calculateTotal(orderAmount: 500.0, loyaltyRate: 2.0), equals(10.0));
      // Null order amount
      expect(calculateTotal(orderAmount: null, loyaltyRate: 2.0), equals(0.0));
      // Null loyalty rate
      expect(calculateTotal(orderAmount: 200.0, loyaltyRate: null), equals(2.0));
      // Both null
      expect(calculateTotal(orderAmount: null, loyaltyRate: null), equals(0.0));
    });

    test('RouteHelper.getVerificationRoute handles null parameters safely', () {
      final route = RouteHelper.getVerificationRoute(
        null,
        null,
        'token-123',
        RouteHelper.orderSuccess,
        null,
        'otp',
        customerName: null,
        orderId: '100456',
      );
      expect(route, contains('order_id=100456'));
      expect(route, contains('login_type=otp'));
      expect(route, contains('page=${RouteHelper.orderSuccess}'));
    });

    test('Raw Unicode/Arabic decoding crash reproduction and RouteHelper.safeDecodeParam resilience', () {
      // 1. Uri.decodeComponent directly on raw non-ASCII Arabic throws ArgumentError (Illegal percent encoding in URI)
      const String rawArabic = 'ففثسف';
      expect(() => Uri.decodeComponent(rawArabic), throwsA(isA<ArgumentError>()));

      // 2. RouteHelper.safeDecodeParam safely handles already-decoded Arabic text
      expect(RouteHelper.safeDecodeParam(rawArabic), equals('ففثسف'));

      // 3. Handles percent-encoded Arabic text
      const String encodedArabic = '%D9%81%D9%81%D8%AB%D8%B3%D9%81';
      expect(RouteHelper.safeDecodeParam(encodedArabic), equals('ففثسف'));

      // 4. Handles null, empty, and literal 'null'
      expect(RouteHelper.safeDecodeParam(null), isNull);
      expect(RouteHelper.safeDecodeParam(''), isNull);
      expect(RouteHelper.safeDecodeParam('null'), isNull);

      // 5. Handles standard ASCII customer name
      expect(RouteHelper.safeDecodeParam('John Doe'), equals('John Doe'));

      // 6. Handles phone numbers (+ and encoded %2B)
      expect(RouteHelper.safeDecodeParam('+201028972661'), equals('+201028972661'));
      expect(RouteHelper.safeDecodeParam('%2B201028972661'), equals('+201028972661'));

      // 7. Handles strings with percent sign and Arabic without crashing
      const String mixed = '100% Arabic ففثسف';
      expect(RouteHelper.safeDecodeParam(mixed), equals(mixed));
    });

    test('RouteHelper.getPaymentRoute does not output literal "null" for add-fund-url or subscription-url', () {
      final route = RouteHelper.getPaymentRoute(
        '111336',
        4279,
        'delivery',
        73.0,
        true,
        'paymob_accept',
        guestId: '4279',
        contactNumber: '+201028972661',
        addFundUrl: null,
        subscriptionUrl: null,
      );

      expect(route, contains('id=111336'));
      expect(route, contains('payment-method=paymob_accept'));
      expect(route, contains('add-fund-url='));
      expect(route, isNot(contains('add-fund-url=null')));
      expect(route, contains('subscription-url='));
      expect(route, isNot(contains('subscription-url=null')));
    });
  });
}
