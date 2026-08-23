import 'package:flutter_test/flutter_test.dart';
import 'package:Oxygen_Mart/helper/validate_check.dart';
import 'package:Oxygen_Mart/helper/custom_validator.dart';

void main() {
  group('Phone Number Normalization Tests', () {
    test('ValidateCheck.getValidPhone normalizes +2001028972661 to +201028972661', () {
      String rawConcatenated = '+2001028972661';
      String normalized = ValidateCheck.getValidPhone(rawConcatenated, withCountryCode: true);
      expect(normalized, equals('+201028972661'));
      expect(normalized, isNot(equals('+2001028972661')));
    });

    test('CustomValidator.isPhoneValid normalizes +2001028972661 to +201028972661', () async {
      String rawConcatenated = '+2001028972661';
      PhoneValid phoneValid = await CustomValidator.isPhoneValid(rawConcatenated);
      expect(phoneValid.isValid, isTrue);
      expect(phoneValid.phone, equals('+201028972661'));
      expect(phoneValid.phone, isNot(equals('+2001028972661')));
    });

    test('Already normalized E.164 number remains unchanged', () {
      String validE164 = '+201028972661';
      String normalized = ValidateCheck.getValidPhone(validE164, withCountryCode: true);
      expect(normalized, equals('+201028972661'));
    });
  });
}
