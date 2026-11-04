import '../view/models/profile_menu_item.dart';

sealed class ProfileIntent {
  const ProfileIntent();
}

final class PickPhotoIntent extends ProfileIntent {
  const PickPhotoIntent();
}

final class MenuTapIntent extends ProfileIntent {
  final ProfileMenuItem item;

  const MenuTapIntent(this.item);
}
