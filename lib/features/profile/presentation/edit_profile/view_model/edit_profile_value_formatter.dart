import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/contants/registration_options.dart';
import '../../../domain/entities/profile_params.dart';
import '../view/models/picker_option.dart';
import 'edit_profile_field.dart';

abstract final class EditProfileValueFormatter {
  EditProfileValueFormatter._();

  static List<PickerOption> options(EditProfileField field) {
    assert(!field.isNumeric);
    return switch (field) {
      EditProfileField.goal => _from(
        RegistrationGoal.values,
        (value) => value.displayText,
        (value) => value.apiKey,
      ),
      EditProfileField.activityLevel => _from(
        RegistrationActivity.values,
        (value) => value.displayText,
        (value) => value.apiKey,
      ),
      EditProfileField.age ||
      EditProfileField.weight ||
      EditProfileField.height => const [],
    };
  }

  static num number(EditProfileField field, ProfileParams draft) {
    assert(field.isNumeric);
    return switch (field) {
      EditProfileField.age => draft.age,
      EditProfileField.weight => draft.weight,
      EditProfileField.height => draft.height,
      EditProfileField.goal || EditProfileField.activityLevel => 0,
    };
  }

  static String optionValue(EditProfileField field, ProfileParams draft) {
    assert(!field.isNumeric);
    return switch (field) {
      EditProfileField.goal => draft.goal,
      EditProfileField.activityLevel => draft.activityLevel,
      EditProfileField.age ||
      EditProfileField.weight ||
      EditProfileField.height => '',
    };
  }

  static String genderLabel(String apiKey) {
    for (final gender in RegistrationGender.values) {
      if (gender.apiKey == apiKey) return gender.displayText;
    }
    return apiKey;
  }

  static String value(EditProfileField field, ProfileParams draft) {
    if (field.isNumeric) {
      return '${formatNumber(number(field, draft))} ${field.unitKey.tr()}';
    }
    return _labelOf(options(field), optionValue(field, draft));
  }

  static String formatNumber(num value) {
    final text = value.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  static List<PickerOption> _from<X>(
    List<X> values,
    String Function(X) label,
    String Function(X) apiKey,
  ) {
    return [
      for (final value in values)
        PickerOption(label: label(value), value: apiKey(value)),
    ];
  }

  static String _labelOf(List<PickerOption> options, String apiKey) {
    for (final option in options) {
      if (option.value == apiKey) return option.label;
    }
    return apiKey;
  }
}
