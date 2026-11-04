import 'package:equatable/equatable.dart';
import '../../../../../core/resource/resource.dart';
import '../../../../../core/validation/validation_errors.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/entities/profile_params.dart';
import 'edit_profile_field.dart';

class EditProfileState extends Equatable {
  final ProfileEntity? saved;
  final ProfileParams? draft;
  final Map<EditProfileField, ValidationError> fieldErrors;
  final Resource<ProfileEntity> saveResource;

  const EditProfileState({
    this.saved,
    this.draft,
    this.fieldErrors = const {},
    this.saveResource = const Resource.initial(),
  });

  bool get isDraftReady => draft != null;

  bool get isSaving => saveResource.isLoading;

  bool get hasChanges {
    final current = draft;
    final original = saved;
    if (current == null || original == null) return false;
    return current != ProfileParams.fromEntity(original);
  }

  String get firstName => saved?.firstName ?? '';

  String get lastName => saved?.lastName ?? '';

  String get email => saved?.email ?? '';

  ValidationError? errorOf(EditProfileField field) => fieldErrors[field];

  EditProfileState copyWith({
    ProfileEntity? saved,
    ProfileParams? draft,
    Map<EditProfileField, ValidationError>? fieldErrors,
    Resource<ProfileEntity>? saveResource,
  }) {
    return EditProfileState(
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      saveResource: saveResource ?? this.saveResource,
    );
  }

  @override
  List<Object?> get props => [saved, draft, fieldErrors, saveResource];
}
