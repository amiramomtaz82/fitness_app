// lib/core/validation/form_validators.dart

import 'package:fitness_app/core/validation/validation_errors.dart';

class FormValidators {
  /// Validates standard required text
  static ValidationError? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.empty;
    }
    return null;
  }

  /// Validates email address format
  static ValidationError? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.empty;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return ValidationError.invalidEmail;
    }
    return null;
  }

  /// Validates password strength matching backend pattern:
  /// /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$/
  /// (min 8 chars, uppercase, lowercase, digit, special character from [#?!@$%^&*-])
  static ValidationError? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.empty;
    }
    if (value.length < 8) {
      return ValidationError.passwordTooShort;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return ValidationError.passwordMissingUppercase;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return ValidationError.passwordMissingLowercase;
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return ValidationError.passwordMissingNumber;
    }
    if (!RegExp(r'[#?!@$%^&*-]').hasMatch(value)) {
      return ValidationError.passwordMissingSpecialChar;
    }
    return null;
  }

  /// Validates Egyptian phone number (010, 011, 012, 015 followed by 8 digits)
  static ValidationError? validateEgyptianPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.empty;
    }
    final regex = RegExp(r'^01[0125][0-9]{8}$');
    if (!regex.hasMatch(value.trim())) {
      return ValidationError.invalidPhoneNumber;
    }
    return null;
  }

  /// Validates gender (male or female, case-insensitive)
  static ValidationError? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.empty;
    }
    final lower = value.trim().toLowerCase();
    if (lower != 'male' && lower != 'female') {
      return ValidationError.invalidGender;
    }
    return null;
  }

  /// Validates password confirmation
  static ValidationError? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return ValidationError.empty;
    }
    if (password != confirmPassword) {
      return ValidationError.passwordsDoNotMatch;
    }
    return null;
  }

  /// Validates a one-time reset/verification code of [length] digits.
  static ValidationError? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.trim().length < length) {
      return ValidationError.incompleteOtp;
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return ValidationError.incompleteOtp;
    }
    return null;
  }

  // ==========================================
  // Fitness-Specific Input Validators
  // ==========================================

  /// Validates body weight (e.g., between 20 kg and 350 kg)
  static ValidationError? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.empty;
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return ValidationError.notANumber;
    }
    if (weight < 20.0) {
      return ValidationError.valueBelowMinimum;
    }
    if (weight > 350.0) {
      return ValidationError.valueAboveMaximum;
    }
    return null;
  }

  /// Validates workout reps or sets (positive integer)
  static ValidationError? validateRepsOrSets(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.empty;
    }
    final number = int.tryParse(value);
    if (number == null) {
      return ValidationError.notANumber;
    }
    if (number <= 0) {
      return ValidationError.valueBelowMinimum;
    }
    if (number > 1000) {
      return ValidationError.valueAboveMaximum;
    }
    return null;
  }
}
