import 'package:easy_localization/easy_localization.dart';

import '../../generated/locale_keys.g.dart';

enum RegistrationGender { male, female }

extension RegistrationGenderLabel on RegistrationGender {
  String get displayText {
    return switch (this) {
      RegistrationGender.male => LocaleKeys.profile_setup_gender_male.tr(),
      RegistrationGender.female => LocaleKeys.profile_setup_gender_female.tr(),
    };
  }

  String get apiKey => name;
}

enum RegistrationGoal {
  gainWeight,
  loseWeight,
  getFitter,
  gainMoreFlexible,
  learnTheBasic,
}

enum RegistrationActivity { rookie, beginner, intermediate, advance, trueBeast }

extension RegistrationGoalLabel on RegistrationGoal {
  String get displayText {
    return switch (this) {
      RegistrationGoal.gainWeight => LocaleKeys.profile_setup_gain_weight.tr(),
      RegistrationGoal.loseWeight => LocaleKeys.profile_setup_lose_weight.tr(),
      RegistrationGoal.getFitter => LocaleKeys.profile_setup_get_fitter.tr(),
      RegistrationGoal.gainMoreFlexible =>
        LocaleKeys.profile_setup_gain_more_flexible.tr(),
      RegistrationGoal.learnTheBasic =>
        LocaleKeys.profile_setup_learn_the_basic.tr(),
    };
  }
}

extension RegistrationActivityLabel on RegistrationActivity {
  String get displayText {
    return switch (this) {
      RegistrationActivity.rookie => LocaleKeys.profile_setup_rookie.tr(),
      RegistrationActivity.beginner => LocaleKeys.profile_setup_beginner.tr(),
      RegistrationActivity.intermediate =>
        LocaleKeys.profile_setup_intermediate.tr(),
      RegistrationActivity.advance => LocaleKeys.profile_setup_advance.tr(),
      RegistrationActivity.trueBeast =>
        LocaleKeys.profile_setup_true_beast.tr(),
    };
  }
}

extension RegistrationGoalApiKey on RegistrationGoal {
  String get apiKey => switch (this) {
    RegistrationGoal.gainWeight => 'Gain weight',
    RegistrationGoal.loseWeight => 'Lose weight',
    RegistrationGoal.getFitter => 'Get fitter',
    RegistrationGoal.gainMoreFlexible => 'Gain more flexible',
    RegistrationGoal.learnTheBasic => 'Learn the basic',
  };
}

extension RegistrationActivityApiKey on RegistrationActivity {
  String get apiKey => switch (this) {
    RegistrationActivity.rookie => 'level1',
    RegistrationActivity.beginner => 'level2',
    RegistrationActivity.intermediate => 'level3',
    RegistrationActivity.advance => 'level4',
    RegistrationActivity.trueBeast => 'level5',
  };
}
