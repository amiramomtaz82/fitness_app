import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';

void main() {
  group('FormValidators', () {
    requiredFieldTests();
    emailFieldTests();
    passwordFieldTests();
    confirmPasswordTests();
    weightFieldTests();
    repsFieldTests();
  });
}

void requiredFieldTests() {
  group('validateRequired', () {
    rejectsBlankRequired();
    acceptsRequiredText();
  });
}

void rejectsBlankRequired() {
  test('returns empty when null or whitespace', () {
    expect(FormValidators.validateRequired(null), ValidationError.empty);
    expect(FormValidators.validateRequired(''), ValidationError.empty);
    expect(FormValidators.validateRequired('   '), ValidationError.empty);
  });
}

void acceptsRequiredText() {
  test('returns null when valid value provided', () {
    expect(FormValidators.validateRequired('valid text'), isNull);
  });
}

void emailFieldTests() {
  group('validateEmail', () {
    rejectsBlankEmail();
    rejectsInvalidEmail();
    acceptsValidEmail();
  });
}

void rejectsBlankEmail() {
  test('returns empty when null or empty', () {
    expect(FormValidators.validateEmail(null), ValidationError.empty);
    expect(FormValidators.validateEmail(''), ValidationError.empty);
  });
}

void rejectsInvalidEmail() {
  test('returns invalidEmail when email format is invalid', () {
    expect(FormValidators.validateEmail('invalid-email'), _invalidEmail);
    expect(FormValidators.validateEmail('test@'), _invalidEmail);
    expect(FormValidators.validateEmail('@example.com'), _invalidEmail);
  });
}

void acceptsValidEmail() {
  test('returns null when valid email is provided', () {
    expect(FormValidators.validateEmail('user@example.com'), isNull);
    expect(FormValidators.validateEmail('first.last@domain.co'), isNull);
  });
}

void passwordFieldTests() {
  group('validatePassword', () {
    rejectsBlankPassword();
    rejectsShortPassword();
    rejectsPasswordWithoutUppercase();
    rejectsPasswordWithoutLowercase();
    rejectsPasswordWithoutDigit();
    rejectsPasswordWithoutSpecialChar();
    acceptsValidPassword();
  });
}

void rejectsBlankPassword() {
  test('returns empty when null or empty', () {
    expect(FormValidators.validatePassword(null), ValidationError.empty);
    expect(FormValidators.validatePassword(''), ValidationError.empty);
  });
}

void rejectsShortPassword() {
  test('returns passwordTooShort when less than 8 characters', () {
    expect(FormValidators.validatePassword('Ab1!xyz'), _shortPassword);
  });
}

void rejectsPasswordWithoutUppercase() {
  test('returns passwordMissingUppercase when uppercase is missing', () {
    expect(
      FormValidators.validatePassword('lowercase123!'),
      ValidationError.passwordMissingUppercase,
    );
  });
}

void rejectsPasswordWithoutLowercase() {
  test('returns passwordMissingLowercase when lowercase is missing', () {
    expect(
      FormValidators.validatePassword('UPPERCASE123!'),
      ValidationError.passwordMissingLowercase,
    );
  });
}

void rejectsPasswordWithoutDigit() {
  test('returns passwordMissingNumber when digits are missing', () {
    expect(FormValidators.validatePassword('LongPasswordNoDigit!'), _noDigit);
  });
}

void rejectsPasswordWithoutSpecialChar() {
  test(
    'returns passwordMissingSpecialChar when special character is missing',
    () {
      expect(
        FormValidators.validatePassword('Passwordd123'),
        ValidationError.passwordMissingSpecialChar,
      );
    },
  );
}

void acceptsValidPassword() {
  test('returns null when valid password meets criteria', () {
    expect(FormValidators.validatePassword('StrongPassword@123'), isNull);
    expect(FormValidators.validatePassword('Password!123'), isNull);
    expect(FormValidators.validatePassword('Elevate#2026'), isNull);
  });
}

void confirmPasswordTests() {
  group('validateConfirmPassword', () {
    rejectsBlankConfirmation();
    rejectsDifferentConfirmation();
    acceptsMatchingConfirmation();
  });
}

void rejectsBlankConfirmation() {
  test('returns empty when confirmPassword is null or empty', () {
    expect(FormValidators.validateConfirmPassword('Pass123', null), _empty);
    expect(FormValidators.validateConfirmPassword('Pass123', ''), _empty);
  });
}

void rejectsDifferentConfirmation() {
  test('returns passwordsDoNotMatch when passwords do not match', () {
    expect(
      FormValidators.validateConfirmPassword('Pass123', 'Different123'),
      ValidationError.passwordsDoNotMatch,
    );
  });
}

void acceptsMatchingConfirmation() {
  test('returns null when passwords match', () {
    expect(FormValidators.validateConfirmPassword('Pass123', 'Pass123'), null);
  });
}

void weightFieldTests() {
  group('validateWeight', () {
    rejectsBlankWeight();
    rejectsNonNumericWeight();
    rejectsWeightOutOfRange();
    acceptsValidWeight();
  });
}

void rejectsBlankWeight() {
  test('returns empty when null or empty', () {
    expect(FormValidators.validateWeight(null), _empty);
    expect(FormValidators.validateWeight(''), _empty);
  });
}

void rejectsNonNumericWeight() {
  test('returns notANumber when input is not numeric', () {
    expect(FormValidators.validateWeight('abc'), _notANumber);
    expect(FormValidators.validateWeight('70kg'), _notANumber);
  });
}

void rejectsWeightOutOfRange() {
  test('returns the bound error when weight is outside 20 to 350', () {
    expect(FormValidators.validateWeight('19.9'), _belowMinimum);
    expect(FormValidators.validateWeight('0'), _belowMinimum);
    expect(FormValidators.validateWeight('-10'), _belowMinimum);
    expect(FormValidators.validateWeight('350.1'), _aboveMaximum);
    expect(FormValidators.validateWeight('500'), _aboveMaximum);
  });
}

void acceptsValidWeight() {
  test('returns null when weight is within valid range', () {
    expect(FormValidators.validateWeight('20.0'), isNull);
    expect(FormValidators.validateWeight('75.5'), isNull);
    expect(FormValidators.validateWeight('350.0'), isNull);
  });
}

void repsFieldTests() {
  group('validateRepsOrSets', () {
    rejectsBlankReps();
    rejectsNonNumericReps();
    rejectsRepsOutOfRange();
    acceptsValidReps();
  });
}

void rejectsBlankReps() {
  test('returns empty when null or empty', () {
    expect(FormValidators.validateRepsOrSets(null), _empty);
    expect(FormValidators.validateRepsOrSets(''), _empty);
  });
}

void rejectsNonNumericReps() {
  test('returns notANumber when input is not an integer', () {
    expect(FormValidators.validateRepsOrSets('ten'), _notANumber);
    expect(FormValidators.validateRepsOrSets('12.5'), _notANumber);
  });
}

void rejectsRepsOutOfRange() {
  test('returns the bound error when reps are outside 1 to 1000', () {
    expect(FormValidators.validateRepsOrSets('0'), _belowMinimum);
    expect(FormValidators.validateRepsOrSets('-5'), _belowMinimum);
    expect(FormValidators.validateRepsOrSets('1001'), _aboveMaximum);
  });
}

void acceptsValidReps() {
  test('returns null when valid reps or sets value provided', () {
    expect(FormValidators.validateRepsOrSets('12'), isNull);
  });
}

const _invalidEmail = ValidationError.invalidEmail;
const _shortPassword = ValidationError.passwordTooShort;
const _noDigit = ValidationError.passwordMissingNumber;
const _empty = ValidationError.empty;
const _belowMinimum = ValidationError.valueBelowMinimum;
const _aboveMaximum = ValidationError.valueAboveMaximum;
const _notANumber = ValidationError.notANumber;
