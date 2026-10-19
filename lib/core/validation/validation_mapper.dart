import 'package:easy_localization/easy_localization.dart';
import '../../generated/locale_keys.g.dart';
import 'validation_errors.dart';

extension ValidationErrorMapper on ValidationError {
  /// Maps enum to user-facing localized string.
  String toMessage() {
    return switch (this) {
      ValidationError.empty => LocaleKeys.validation_field_required.tr(),
      ValidationError.invalidEmail => LocaleKeys.validation_invalid_email.tr(),
      ValidationError.passwordTooShort => LocaleKeys.validation_password_too_short.tr(),
      ValidationError.passwordMissingNumber => LocaleKeys.validation_password_missing_number.tr(),
      ValidationError.passwordsDoNotMatch => LocaleKeys.validation_passwords_dont_match.tr(),
      ValidationError.notANumber => LocaleKeys.validation_not_a_number.tr(),
      ValidationError.valueBelowMinimum => LocaleKeys.validation_value_below_minimum.tr(),
      ValidationError.valueAboveMaximum => LocaleKeys.validation_value_above_maximum.tr(),
    };
  }
}