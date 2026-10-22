sealed class RegisterIntent {
  const RegisterIntent();
}

final class TogglePasswordVisibilityIntent extends RegisterIntent {
  const TogglePasswordVisibilityIntent();
}
final class SubmitAccountCredentialsIntent extends RegisterIntent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const SubmitAccountCredentialsIntent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

// Wizard Intents
final class UpdateGenderIntent extends RegisterIntent {
  final String gender;
  const UpdateGenderIntent(this.gender);
}

final class UpdateAgeIntent extends RegisterIntent {
  final int age;
  const UpdateAgeIntent(this.age);
}

final class UpdateWeightIntent extends RegisterIntent {
  final num weight;
  const UpdateWeightIntent(this.weight);
}

final class UpdateHeightIntent extends RegisterIntent {
  final num height;
  const UpdateHeightIntent(this.height);
}

final class UpdateGoalIntent extends RegisterIntent {
  final String goal;
  const UpdateGoalIntent(this.goal);
}

// Final Submit Intent
final class SubmitFullRegistrationIntent extends RegisterIntent {
  final String activityLevel;
  const SubmitFullRegistrationIntent(this.activityLevel);
}
// Screen 1: User Intents
final class SignInWithGoogleIntent extends RegisterIntent {
  const SignInWithGoogleIntent();
}

