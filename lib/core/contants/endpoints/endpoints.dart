class Endpoints {
  Endpoints._();

  static const String domain = 'https://fitness.elevateegy.com';
  static const String baseUrl = 'https://fitness.elevateegy.com/api/v1';

  // Authentication
  static const String signin = '/auth/signin';
  static const String signup = '/auth/signup';
  static const String changePassword = '/auth/change-password';
  static const String uploadPhoto = '/auth/upload-photo';
  static const String profileData = '/auth/profile-data';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgotPassword';
  static const String verifyResetCode = '/auth/verifyResetCode';
  static const String resetPassword = '/auth/resetPassword';
  static const String deleteMe = '/auth/deleteMe';
  static const String editProfile = '/auth/editProfile';

  // Levels & Muscles
  static const String levels = '/levels';
  static const String muscles = '/muscles';
  static const String musclesGroup = '/musclesGroup';
  static const String musclesRandom = '/muscles/random';

  // Meals (TheMealDB - third-party, no auth)
  static const String mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String mealCategories = '/categories.php';
  static const String mealsByCategory = '/filter.php';
  static const String musclesGroupByGroupId = '/musclesGroup/{muscleGroupId}';

  // Exercises
  static const String exercises = '/exercises';
  static const String exercisesRandom = '/exercises/random';
  static const String exercisesByMuscleDifficulty =
      '/exercises/by-muscle-difficulty';
}
