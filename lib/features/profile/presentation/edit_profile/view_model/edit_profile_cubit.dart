import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/cubit_message.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/resource/resource.dart';
import '../../../../../core/validation/form_validators.dart';
import '../../../../../core/validation/validation_errors.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/entities/profile_params.dart';
import '../../../domain/use_cases/edit_profile_use_case.dart';
import '../../profile/view_model/profile_cubit.dart';
import 'edit_profile_field.dart';
import 'edit_profile_intent.dart';
import 'edit_profile_state.dart';

@injectable
class EditProfileCubit extends BaseCubit<EditProfileState, BaseUiEvent> {
  final ProfileCubit _profileCubit;
  final EditProfileUseCase _editProfileUseCase;

  EditProfileCubit(this._profileCubit, this._editProfileUseCase)
    : super(const EditProfileState());

  void doIntent(EditProfileIntent intent) {
    switch (intent) {
      case StartEditProfileIntent():
        _start();
      case SelectOptionIntent(:final field, :final value):
        _update(field, (draft) => _withOption(draft, field, value));
      case UpdateNumberFieldIntent(:final field, :final value):
        _update(field, (draft) => _withNumber(draft, field, value));
      case SaveProfileIntent():
        _save();
    }
  }

  Future<void> _start() async {
    await _profileCubit.ensureLoaded();
    final profile = _profileCubit.profile;
    if (profile == null) return;
    _emit(
      state.copyWith(
        saved: profile,
        draft: ProfileParams(
          firstName: profile.firstName,
          lastName: profile.lastName,
          gender: profile.gender,
          age: profile.age,
          weight: profile.weight,
          height: profile.height,
          activityLevel: profile.activityLevel,
          goal: profile.goal,
        ),
        fieldErrors: const {},
      ),
    );
  }

  void _update(
    EditProfileField field,
    ProfileParams Function(ProfileParams draft) apply,
  ) {
    final draft = state.draft;
    if (draft == null) return;
    _emit(
      state.copyWith(
        draft: apply(draft),
        fieldErrors: _without(field, state.fieldErrors),
      ),
    );
  }

  Future<void> _save() async {
    final draft = state.draft;
    if (draft == null || state.isSaving) return;
    final errors = _validate(draft);
    if (errors.isNotEmpty) {
      _emit(state.copyWith(fieldErrors: errors));
      emitFailure(const ValidationFailure());
      return;
    }
    _emit(state.copyWith(saveResource: const Resource.loading()));
    final response = await _editProfileUseCase(draft);
    switch (response) {
      case SuccessResponse<ProfileEntity>(:final data):
        _profileCubit.applyProfile(data);
        _emit(
          state.copyWith(saved: data, saveResource: Resource.success(data)),
        );
        emitSuccess(CubitMessageType.profileUpdated);
        emitEvent(const PopEvent());
      case ErrorResponse<ProfileEntity>(:final failure):
        _emit(
          state.copyWith(
            saveResource: Resource.error(
              failure,
              data: state.saveResource.data,
            ),
          ),
        );
        emitFailure(failure);
    }
  }

  Map<EditProfileField, ValidationError> _validate(ProfileParams draft) {
    final checks = <EditProfileField, ValidationError?>{
      EditProfileField.gender: FormValidators.validateGender(draft.gender),
      EditProfileField.age: FormValidators.validateAge('${draft.age}'),
      EditProfileField.weight: FormValidators.validateWeight('${draft.weight}'),
      EditProfileField.height: FormValidators.validateHeight('${draft.height}'),
      EditProfileField.activityLevel: FormValidators.validateRequired(
        draft.activityLevel,
      ),
      EditProfileField.goal: FormValidators.validateRequired(draft.goal),
    };
    return Map.unmodifiable({
      for (final entry in checks.entries)
        if (entry.value != null) entry.key: entry.value!,
    });
  }

  ProfileParams _withOption(
    ProfileParams draft,
    EditProfileField field,
    String value,
  ) {
    if (field.isNumeric) return draft;
    return switch (field) {
      EditProfileField.gender => draft.copyWith(gender: value),
      EditProfileField.activityLevel => draft.copyWith(activityLevel: value),
      EditProfileField.goal => draft.copyWith(goal: value),
      EditProfileField.age ||
      EditProfileField.weight ||
      EditProfileField.height => draft,
    };
  }

  ProfileParams _withNumber(
    ProfileParams draft,
    EditProfileField field,
    num value,
  ) {
    if (!field.isNumeric) return draft;
    return switch (field) {
      EditProfileField.age => draft.copyWith(age: value.toInt()),
      EditProfileField.weight => draft.copyWith(weight: value),
      EditProfileField.height => draft.copyWith(height: value),
      EditProfileField.gender ||
      EditProfileField.goal ||
      EditProfileField.activityLevel => draft,
    };
  }

  Map<EditProfileField, ValidationError> _without(
    EditProfileField field,
    Map<EditProfileField, ValidationError> errors,
  ) {
    if (!errors.containsKey(field)) return errors;
    final copy = Map<EditProfileField, ValidationError>.of(errors)
      ..remove(field);
    return Map.unmodifiable(copy);
  }

  void _emit(EditProfileState newState) {
    if (isClosed) return;
    emit(newState);
  }
}
