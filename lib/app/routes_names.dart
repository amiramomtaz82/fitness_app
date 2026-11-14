class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit-profile';
  static const String webView = '/web-view';
  static const String workouts = '/workouts';
  static const String smartCoach = '/smart-coach';
  static const String food = '/food';
  static const String foodMealSegment = 'meal';
  static const String foodMeal = '$food/$foodMealSegment/:mealId';

  static String foodMealLocation(String mealId) =>
      '$food/$foodMealSegment/$mealId';

  static const String foodRecommendationPath = 'food-recommendation';
  static const String foodRecommendation = '$home/$foodRecommendationPath';

  // Step 1 (You)
  static const String multiStepRegistration = '/multi-step-registration';
  static const String exercise = '/exercise';
  static const String popularTrainingGroup = '/popular-training-group';
  static const String popularTrainingExercise = '/popular-training-exercise';
  static const String exerciseVideo = '/exercise-video';
}
