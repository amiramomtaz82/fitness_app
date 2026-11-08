import '../../../domain/entities/profile_entity.dart';
import 'edit_profile_field.dart';

sealed class EditProfileIntent {
  const EditProfileIntent();
}

final class StartEditProfileIntent extends EditProfileIntent {
  final ProfileEntity profile;

  const StartEditProfileIntent(this.profile);
}

final class SelectOptionIntent extends EditProfileIntent {
  final EditProfileField field;
  final String value;

  const SelectOptionIntent(this.field, this.value);
}

final class UpdateNumberFieldIntent extends EditProfileIntent {
  final EditProfileField field;
  final num value;

  const UpdateNumberFieldIntent(this.field, this.value);
}

final class SaveProfileIntent extends EditProfileIntent {
  const SaveProfileIntent();
}
