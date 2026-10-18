// lib/core/utils/validation_mapper.dart


import 'package:fitness_app/core/validation/validation_errors.dart';

extension ValidationErrorMapper on ValidationError {
  /// Maps enum to user-facing string.
  /// (If you use localization, you can pass BuildContext: `toMessage(BuildContext context)`)
  String toMessage() {
    return switch (this) {
      ValidationError.empty =>
      'This field is required.',

      ValidationError.invalidEmail =>
      'Please enter a valid email address.',

      ValidationError.passwordTooShort =>
      'Password must be at least 8 characters long.',

      ValidationError.passwordMissingNumber =>
      'Password must contain at least one digit.',

      ValidationError.passwordsDoNotMatch =>
      'Passwords do not match.',

      ValidationError.notANumber =>
      'Please enter a valid numeric value.',

      ValidationError.valueBelowMinimum =>
      'Entered value is too low.',

      ValidationError.valueAboveMaximum =>
      'Entered value exceeds maximum limit.',
    };
  }
}