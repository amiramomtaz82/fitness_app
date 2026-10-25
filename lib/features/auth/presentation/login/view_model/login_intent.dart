sealed class LoginIntent {
  const LoginIntent();
}

class LoginSubmittedIntent extends LoginIntent {
  final String email;
  final String password;

  const LoginSubmittedIntent({required this.email, required this.password});
}

class TogglePasswordVisibilityIntent extends LoginIntent {
  const TogglePasswordVisibilityIntent();
}

class NavigateToRegisterIntent extends LoginIntent {
  const NavigateToRegisterIntent();
}

class NavigateToForgetPasswordIntent extends LoginIntent {
  const NavigateToForgetPasswordIntent();
}

class SignInWithGoogleIntent extends LoginIntent {
  const SignInWithGoogleIntent();
}

class SignInWithFacebookIntent extends LoginIntent {
  const SignInWithFacebookIntent();
}
