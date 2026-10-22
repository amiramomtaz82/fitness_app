import 'package:easy_localization/easy_localization.dart';

import '../../../../generated/locale_keys.g.dart';

enum RegistrationGender { male, female }

extension RegistrationGenderLabel on RegistrationGender {
  String get displayText {
    return switch (this) {
      RegistrationGender.male => LocaleKeys.profile_setup_male.tr(),
      RegistrationGender.female => LocaleKeys.profile_setup_female.tr(),
    };
  }
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
