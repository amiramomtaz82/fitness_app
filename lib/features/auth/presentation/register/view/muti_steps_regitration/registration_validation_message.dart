import '../../../../../../core/validation/validation_errors.dart';
import '../../../../../../generated/locale_keys.g.dart';

extension RegistrationValidationMessage on ValidationError {
  String get messageKey {
    return switch (this) {
      ValidationError.empty => LocaleKeys.validation_field_required,
      ValidationError.invalidGender => LocaleKeys.validation_invalid_gender,
      ValidationError.notANumber => LocaleKeys.validation_not_a_number,
      ValidationError.valueBelowMinimum =>
        LocaleKeys.validation_value_below_minimum,
      ValidationError.valueAboveMaximum =>
        LocaleKeys.validation_value_above_maximum,
      ValidationError.invalidEmail ||
      ValidationError.passwordTooShort ||
      ValidationError.passwordMissingNumber ||
      ValidationError.passwordMissingUppercase ||
      ValidationError.passwordMissingLowercase ||
      ValidationError.passwordMissingSpecialChar ||
      ValidationError.passwordsDoNotMatch ||
      ValidationError.invalidPhoneNumber =>
        LocaleKeys.validation_field_required,
      ValidationError.incompleteOtp => LocaleKeys.validation_incomplete_otp,
    };
  }
}
