import '../../../../../core/base/ui_events.dart';
import '../../../domain/entities/profile_entity.dart';

class ProfileSavedEvent extends BaseUiEvent {
  final ProfileEntity profile;

  const ProfileSavedEvent(this.profile);
}
