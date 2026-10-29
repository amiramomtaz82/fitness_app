class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String workouts = '/workouts';
  static const String smartCoach = '/smart-coach';

  // Nested under home so the bottom bar stays visible
  static const String foodRecommendationPath = 'food-recommendation';
  static const String foodRecommendation = '$home/$foodRecommendationPath';

  // Step 1 (You)
  static const String multiStepRegistration = '/multi-step-registration';
}
