import 'package:flutter_test/flutter_test.dart';
import 'package:Oxygen_Mart/helper/validate_check.dart';
import 'package:Oxygen_Mart/features/verification/domein/models/verification_data_model.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/helper/custom_validator.dart';

void main() {
  group('Email Validation Tests (Optional & Required)', () {
    test('validateEmail allows null or empty when required is false', () {
      expect(ValidateCheck.validateEmail(null, required: false), isNull);
      expect(ValidateCheck.validateEmail('', required: false), isNull);
      expect(ValidateCheck.validateEmail('   ', required: false), isNull);
    });

    test('validateEmail validates format when provided and required is false', () {
      expect(ValidateCheck.validateEmail('valid.email@example.com', required: false), isNull);
      expect(ValidateCheck.validateEmail('customer123@domain.org', required: false), isNull);

      final invalidResult = ValidateCheck.validateEmail('not-an-email', required: false);
      expect(invalidResult, isNotNull);
      expect(invalidResult, contains('enter_valid_email_address'));

      final invalidResult2 = ValidateCheck.validateEmail('test@invalid', required: false);
      expect(invalidResult2, isNotNull);
    });

    test('validateEmail enforces required when required is true', () {
      final nullResult = ValidateCheck.validateEmail(null, required: true);
      expect(nullResult, isNotNull);
      expect(nullResult, contains('email_field_is_required'));

      final emptyResult = ValidateCheck.validateEmail('', required: true);
      expect(emptyResult, isNotNull);
      expect(emptyResult, contains('email_field_is_required'));

      final whitespaceResult = ValidateCheck.validateEmail('   ', required: true);
      expect(whitespaceResult, isNotNull);
      expect(whitespaceResult, contains('email_field_is_required'));

      expect(ValidateCheck.validateEmail('valid@example.com', required: true), isNull);
    });
  });

  group('Phone Masking Tests', () {
    test('maskPhone masks destination phone numbers cleanly', () {
      final masked = ValidateCheck.maskPhone('+201028972661');
      expect(masked, isNotEmpty);
      expect(masked, contains('*'));
      expect(masked.startsWith('+201'), isTrue);
      expect(masked.endsWith('661'), isTrue);
    });

    test('maskPhone handles short and edge case numbers safely', () {
      expect(ValidateCheck.maskPhone(null), equals(''));
      expect(ValidateCheck.maskPhone(''), equals(''));
      expect(ValidateCheck.maskPhone('123'), equals('123'));
      expect(ValidateCheck.maskPhone('1234'), equals('1234'));
      expect(ValidateCheck.maskPhone('1234567'), contains('*'));
    });
  });

  group('VerificationDataModel Serialization Tests', () {
    test('VerificationDataModel correctly serializes and deserializes name and orderId', () {
      final model = VerificationDataModel(
        phone: '+201028972661',
        email: 'test@example.com',
        verificationType: 'phone',
        otp: '123456',
        loginType: 'otp',
        guestId: 'guest_123',
        name: 'John Doe',
        orderId: '10045',
      );

      final json = model.toJson();
      expect(json['phone'], equals('+201028972661'));
      expect(json['email'], equals('test@example.com'));
      expect(json['otp'], equals('123456'));
      expect(json['login_type'], equals('otp'));
      expect(json['guest_id'], equals('guest_123'));
      expect(json['name'], equals('John Doe'));
      expect(json['order_id'], equals('10045'));

      final reconstructed = VerificationDataModel.fromJson(json);
      expect(reconstructed.name, equals('John Doe'));
      expect(reconstructed.orderId, equals('10045'));
      expect(reconstructed.phone, equals('+201028972661'));
    });

    test('VerificationDataModel works when name and orderId are null', () {
      final model = VerificationDataModel(
        phone: '+201028972661',
        otp: '123456',
        loginType: 'otp',
      );

      final json = model.toJson();
      expect(json['name'], isNull);
      expect(json['order_id'], isNull);

      final reconstructed = VerificationDataModel.fromJson(json);
      expect(reconstructed.name, isNull);
      expect(reconstructed.orderId, isNull);
    });
  });

  group('PlaceOrderBodyModel Passwordless Checkout Tests', () {
    test('PlaceOrderBodyModel handles null password and optional email cleanly', () {
      final placeOrderBody = PlaceOrderBodyModel(
        isGuest: 1,
        cart: [],
        couponDiscountAmount: 0,
        couponCode: null,
        orderAmount: 150.0,
        orderType: 'delivery',
        paymentMethod: 'cash_on_delivery',
        storeId: 1,
        distance: 2.5,
        discountAmount: 0,
        orderNote: '',
        receiverDetails: null,
        parcelCategoryId: null,
        chargePayer: null,
        dmTips: '0',
        unavailableItemNote: '',
        cutlery: 0,
        partialPayment: 0,
        guestId: 1,
        isBuyNow: 0,
        extraPackagingAmount: 0,
        createNewUser: 1,
        contactPersonName: 'Jane Guest',
        contactPersonNumber: '+201028972661',
        guestEmail: null,
        password: null,
      );

      final json = placeOrderBody.toJson();
      expect(json.containsKey('password'), isFalse);
      expect(json.containsKey('contact_person_email'), isFalse);
      expect(json['contact_person_name'], equals('Jane Guest'));
      expect(json['contact_person_number'], equals('+201028972661'));
      expect(json['create_new_user'], equals('1'));
    });
  });

  group('Phone Normalization & CustomValidator Tests', () {
    test('Normalizes Egyptian numbers with 010 and country code +20', () async {
      final valid1 = await CustomValidator.isPhoneValid('+2001028972661');
      expect(valid1.isValid, isTrue);
      expect(valid1.phone, equals('+201028972661'));

      final valid2 = await CustomValidator.isPhoneValid('+201028972661');
      expect(valid2.isValid, isTrue);
      expect(valid2.phone, equals('+201028972661'));
    });
  });
}
