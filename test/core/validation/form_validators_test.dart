import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormValidators.validateRequired', () {
    test('null and blank values are empty errors', () {
      expect(FormValidators.validateRequired(null), ValidationError.empty);
      expect(FormValidators.validateRequired(''), ValidationError.empty);
      expect(FormValidators.validateRequired('   '), ValidationError.empty);
    });

    test('any non-blank text passes', () {
      expect(FormValidators.validateRequired('a'), isNull);
    });
  });

  group('FormValidators.validateEmail', () {
    test('null and blank values are empty errors', () {
      expect(FormValidators.validateEmail(null), ValidationError.empty);
      expect(FormValidators.validateEmail(''), ValidationError.empty);
      expect(FormValidators.validateEmail('  '), ValidationError.empty);
    });

    test('well formed addresses pass', () {
      expect(FormValidators.validateEmail('user@mail.com'), isNull);
      expect(FormValidators.validateEmail('first.last@sub.domain.co'), isNull);
      expect(FormValidators.validateEmail('user_name-1@mail-2.info'), isNull);
      expect(FormValidators.validateEmail('  user@mail.com  '), isNull);
      expect(FormValidators.validateEmail('User@Mail.COM'), isNull);
    });

    test('malformed addresses are invalid email errors', () {
      expect(
        FormValidators.validateEmail('not-an-email'),
        ValidationError.invalidEmail,
      );
      expect(FormValidators.validateEmail('a@b'), ValidationError.invalidEmail);
      expect(
        FormValidators.validateEmail('a@b.c'),
        ValidationError.invalidEmail,
      );
      expect(
        FormValidators.validateEmail('a@.com'),
        ValidationError.invalidEmail,
      );
      expect(
        FormValidators.validateEmail('@mail.com'),
        ValidationError.invalidEmail,
      );
      expect(
        FormValidators.validateEmail('user mail@.com'),
        ValidationError.invalidEmail,
      );
      expect(
        FormValidators.validateEmail('user+tag@mail.com'),
        ValidationError.invalidEmail,
      );
      expect(
        FormValidators.validateEmail('user@mail.travel'),
        ValidationError.invalidEmail,
      );
    });
  });

  group('FormValidators.validatePassword', () {
    test('null and blank values are empty errors', () {
      expect(FormValidators.validatePassword(null), ValidationError.empty);
      expect(FormValidators.validatePassword(''), ValidationError.empty);
      expect(FormValidators.validatePassword('   '), ValidationError.empty);
    });

    test('under eight characters is too short', () {
      expect(
        FormValidators.validatePassword('short'),
        ValidationError.passwordTooShort,
      );
      expect(
        FormValidators.validatePassword('abc123'),
        ValidationError.passwordTooShort,
      );
    });

    test('eight characters without a digit misses the number rule', () {
      expect(
        FormValidators.validatePassword('Abcdefg@'),
        ValidationError.passwordMissingNumber,
      );
    });

    test('a password without an uppercase letter is rejected', () {
      expect(
        FormValidators.validatePassword('abcdefg@1'),
        ValidationError.passwordMissingUppercase,
      );
    });

    test('a password without a lowercase letter is rejected', () {
      expect(
        FormValidators.validatePassword('ABCDEFG@1'),
        ValidationError.passwordMissingLowercase,
      );
    });

    test('a password without a special character is rejected', () {
      expect(
        FormValidators.validatePassword('Abcdefg1'),
        ValidationError.passwordMissingSpecialChar,
      );
    });

    test('eight or more characters meeting every rule pass', () {
      expect(FormValidators.validatePassword('Abcdefg@1'), isNull);
      expect(FormValidators.validatePassword('NewPass@1'), isNull);
      expect(FormValidators.validatePassword('longerPassword@123'), isNull);
    });
  });

  group('FormValidators.validateConfirmPassword', () {
    test('blank confirmation is an empty error', () {
      expect(
        FormValidators.validateConfirmPassword('NewPass1', null),
        ValidationError.empty,
      );
      expect(
        FormValidators.validateConfirmPassword('NewPass1', ''),
        ValidationError.empty,
      );
    });

    test('differing passwords do not match', () {
      expect(
        FormValidators.validateConfirmPassword('NewPass1', 'OtherPass1'),
        ValidationError.passwordsDoNotMatch,
      );
      expect(
        FormValidators.validateConfirmPassword('NewPass1', 'newpass1'),
        ValidationError.passwordsDoNotMatch,
      );
    });

    test('identical passwords pass', () {
      expect(
        FormValidators.validateConfirmPassword('NewPass1', 'NewPass1'),
        isNull,
      );
    });
  });

  group('FormValidators.validateOtp', () {
    test('codes shorter than the required length are incomplete', () {
      expect(FormValidators.validateOtp(null), ValidationError.incompleteOtp);
      expect(FormValidators.validateOtp(''), ValidationError.incompleteOtp);
      expect(
        FormValidators.validateOtp('12345'),
        ValidationError.incompleteOtp,
      );
      expect(
        FormValidators.validateOtp('123', length: 4),
        ValidationError.incompleteOtp,
      );
    });

    test('non-digit content is incomplete', () {
      expect(
        FormValidators.validateOtp('12a456'),
        ValidationError.incompleteOtp,
      );
      expect(
        FormValidators.validateOtp('12 456'),
        ValidationError.incompleteOtp,
      );
    });

    test('full digit codes pass', () {
      expect(FormValidators.validateOtp('123456'), isNull);
      expect(FormValidators.validateOtp('7542', length: 4), isNull);
      expect(FormValidators.validateOtp(' 7542 ', length: 4), isNull);
    });
  });

  group('FormValidators.validateWeight', () {
    test('blank and non-numeric values are rejected', () {
      expect(FormValidators.validateWeight(null), ValidationError.empty);
      expect(FormValidators.validateWeight('abc'), ValidationError.notANumber);
    });

    test('values outside the 20-350 band are rejected', () {
      expect(
        FormValidators.validateWeight('19'),
        ValidationError.valueBelowMinimum,
      );
      expect(
        FormValidators.validateWeight('351'),
        ValidationError.valueAboveMaximum,
      );
    });

    test('values inside the band pass', () {
      expect(FormValidators.validateWeight('80.5'), isNull);
      expect(FormValidators.validateWeight('20'), isNull);
      expect(FormValidators.validateWeight('350'), isNull);
    });
  });

  group('FormValidators.validateRepsOrSets', () {
    test('blank and non-integer values are rejected', () {
      expect(FormValidators.validateRepsOrSets(null), ValidationError.empty);
      expect(
        FormValidators.validateRepsOrSets('ten'),
        ValidationError.notANumber,
      );
      expect(
        FormValidators.validateRepsOrSets('1.5'),
        ValidationError.notANumber,
      );
    });

    test('zero and negative numbers are below the minimum', () {
      expect(
        FormValidators.validateRepsOrSets('0'),
        ValidationError.valueBelowMinimum,
      );
      expect(
        FormValidators.validateRepsOrSets('-3'),
        ValidationError.valueBelowMinimum,
      );
    });

    test('over one thousand is above the maximum', () {
      expect(
        FormValidators.validateRepsOrSets('1001'),
        ValidationError.valueAboveMaximum,
      );
    });

    test('valid positive integers pass', () {
      expect(FormValidators.validateRepsOrSets('12'), isNull);
      expect(FormValidators.validateRepsOrSets('1000'), isNull);
    });
  });
}
