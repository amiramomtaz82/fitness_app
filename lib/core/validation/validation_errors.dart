// lib/core/validation/validation_error.dart

enum ValidationError {
  // General / Auth
  empty,
  invalidEmail,
  passwordTooShort,
  passwordMissingNumber,
  passwordsDoNotMatch,

  // Fitness App Specific (Weight, Reps, Calories, Height)
  notANumber,
  valueBelowMinimum,
  valueAboveMaximum,
}