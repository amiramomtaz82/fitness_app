abstract final class AppAssets {
  AppAssets._();

  static const String _basePath = 'assets/images';

  // Auth & Profile Backgrounds
  static const String authProfileBG = '$_basePath/authProfileBG.png';
  static const String foodBG = '$_basePath/foodBG.png';
  static const String boardingBG = '$_basePath/boardingBG.png';

  // Onboarding
  static const String boarding1 = '$_basePath/boardin(1).png';

  static const String boarding2 = '$_basePath/boarding(2).png';
  static const String boarding3 = '$_basePath/boarding(3).png';

  // Social & Auth Icons
  static const String google = '$_basePath/google.png';
  static const String facebook = '$_basePath/facebook.png';
  static const String mail = '$_basePath/mail.png';
  static const String lock = '$_basePath/lock.png';
  static const String eye = '$_basePath/eye.png';
  static const String user = '$_basePath/user.png';
  static const String person = '$_basePath/person.png';
  static const String male = '$_basePath/male.png';
  static const String female = '$_basePath/female.png';

  // App & Navigation Icons
  static const String logo = '$_basePath/logo.png';
  static const String home = '$_basePath/home.png';
  static const String chat = '$_basePath/chat.png';
  static const String exercise = '$_basePath/exercise.png';
  static const String logout = '$_basePath/logout.png';
  static const String help = '$_basePath/Help.png';
  static const String back = '$_basePath/back.svg';
  // ignore: constant_identifier_names
  static const String Help = help;
  static const String robot = '$_basePath/Robot.png';
  // ignore: constant_identifier_names
  static const String Robot = robot;

  // Settings & Security
  static const String lockSetting = '$_basePath/Lock Setting.png';
  // ignore: constant_identifier_names
  static const String LockSetting = lockSetting;
  static const String securityWarning = '$_basePath/Security Warning.png';
  // ignore: constant_identifier_names
  static const String SecurityWarning = securityWarning;
}

/// Alias for [AppAssets]
typedef AppImages = AppAssets;
