import '../../../domain/entities/profile_entity.dart';
import '../view/models/profile_menu_item.dart';

sealed class ProfileIntent {
  const ProfileIntent();
}

final class LoadProfileIntent extends ProfileIntent {
  const LoadProfileIntent();
}

final class SyncProfileIntent extends ProfileIntent {
  final ProfileEntity profile;

  const SyncProfileIntent(this.profile);
}

final class PickPhotoIntent extends ProfileIntent {
  const PickPhotoIntent();
}

final class MenuTapIntent extends ProfileIntent {
  final ProfileMenuItem item;

  const MenuTapIntent(this.item);
}
final class ConfirmLogoutIntent extends ProfileIntent {
  const ConfirmLogoutIntent();
}