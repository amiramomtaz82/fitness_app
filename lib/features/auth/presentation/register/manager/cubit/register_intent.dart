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

// Screen 1: User Intents
final class SignInWithGoogleIntent extends RegisterIntent {
  const SignInWithGoogleIntent();
}
