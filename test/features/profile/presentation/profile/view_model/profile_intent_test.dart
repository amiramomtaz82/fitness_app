import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_item.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_intent.dart';

void main() {
  group('ProfileIntent', () {
    test('picking a photo is its own intent', () {
      const intent = PickPhotoIntent();

      expect(intent, isA<ProfileIntent>());
    });

    test('every menu row travels in one tap intent', () {
      final intents = profileMenuItems.map(MenuTapIntent.new).toList();

      expect(intents, hasLength(profileMenuItems.length));
      expect(intents, everyElement(isA<ProfileIntent>()));
      expect(intents.first.item, profileMenuItems.first);
    });
  });
}
