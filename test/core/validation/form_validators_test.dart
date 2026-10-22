import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';

void main() {
  group('FormValidators', () {
    group('validateRequired', () {
      test('returns empty when null or whitespace', () {
        expect(FormValidators.validateRequired(null), ValidationError.empty);
        expect(FormValidators.validateRequired(''), ValidationError.empty);
        expect(FormValidators.validateRequired('   '), ValidationError.empty);
      });

      test('returns null when valid value provided', () {
        expect(FormValidators.validateRequired('valid text'), isNull);
      });
    });

    group('validateEmail', () {
      test('returns empty when null or empty', () {
        expect(FormValidators.validateEmail(null), ValidationError.empty);
        expect(FormValidators.validateEmail(''), ValidationError.empty);
      });

      test('returns invalidEmail when email format is invalid', () {
        expect(
          FormValidators.validateEmail('invalid-email'),
          ValidationError.invalidEmail,
        );
        expect(
          FormValidators.validateEmail('test@'),
          ValidationError.invalidEmail,
        );
        expect(
          FormValidators.validateEmail('@example.com'),
          ValidationError.invalidEmail,
        );
      });

      test('returns null when valid email is provided', () {
        expect(FormValidators.validateEmail('user@example.com'), isNull);
        expect(FormValidators.validateEmail('first.last@domain.co'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns empty when null or empty', () {
        expect(FormValidators.validatePassword(null), ValidationError.empty);
        expect(FormValidators.validatePassword(''), ValidationError.empty);
      });

      test('returns passwordTooShort when less than 8 characters', () {
        expect(
          FormValidators.validatePassword('Short1'),
          ValidationError.passwordTooShort,
        );
      });

      test('returns passwordMissingNumber when digits are missing', () {
        expect(
          FormValidators.validatePassword('LongPasswordNoDigit'),
          ValidationError.passwordMissingNumber,
        );
      });

      test('returns null when valid password meets criteria', () {
        expect(FormValidators.validatePassword('StrongPassword123'), isNull);
      });
    });

    group('validateConfirmPassword', () {
      test('returns empty when confirmPassword is null or empty', () {
        expect(
          FormValidators.validateConfirmPassword('Pass123', null),
          ValidationError.empty,
        );
        expect(
          FormValidators.validateConfirmPassword('Pass123', ''),
          ValidationError.empty,
        );
      });

      test('returns passwordsDoNotMatch when passwords do not match', () {
        expect(
          FormValidators.validateConfirmPassword('Pass123', 'Different123'),
          ValidationError.passwordsDoNotMatch,
        );
      });

      test('returns null when passwords match', () {
        expect(
          FormValidators.validateConfirmPassword('Pass123', 'Pass123'),
          isNull,
        );
      });
    });

    group('validateWeight', () {
      test('returns empty when null or empty', () {
        expect(FormValidators.validateWeight(null), ValidationError.empty);
        expect(FormValidators.validateWeight(''), ValidationError.empty);
      });

      test('returns notANumber when input is not numeric', () {
        expect(
          FormValidators.validateWeight('abc'),
          ValidationError.notANumber,
        );
      });

      test('returns valueBelowMinimum when weight is less than 20', () {
        expect(
          FormValidators.validateWeight('19.9'),
          ValidationError.valueBelowMinimum,
        );
      });

      test('returns valueAboveMaximum when weight is greater than 350', () {
        expect(
          FormValidators.validateWeight('350.1'),
          ValidationError.valueAboveMaximum,
        );
      });

      test('returns null when weight is within valid range', () {
        expect(FormValidators.validateWeight('70.5'), isNull);
      });
    });

    group('validateRepsOrSets', () {
      test('returns empty when null or empty', () {
        expect(FormValidators.validateRepsOrSets(null), ValidationError.empty);
        expect(FormValidators.validateRepsOrSets(''), ValidationError.empty);
      });

      test('returns notANumber when input is not an integer', () {
        expect(
          FormValidators.validateRepsOrSets('abc'),
          ValidationError.notANumber,
        );
      });

      test('returns valueBelowMinimum when <= 0', () {
        expect(
          FormValidators.validateRepsOrSets('0'),
          ValidationError.valueBelowMinimum,
        );
        expect(
          FormValidators.validateRepsOrSets('-5'),
          ValidationError.valueBelowMinimum,
        );
      });

      test('returns valueAboveMaximum when > 1000', () {
        expect(
          FormValidators.validateRepsOrSets('1001'),
          ValidationError.valueAboveMaximum,
        );
      });

      test('returns null when valid reps or sets value provided', () {
        expect(FormValidators.validateRepsOrSets('12'), isNull);
      });
    });
  });
}
