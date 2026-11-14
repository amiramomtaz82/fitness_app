import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_saved_event.dart';

import '../../../profile_test_helper.dart';

void main() {
  group('ProfileSavedEvent', () {
    test('is a ui event the edit screen can forward to the profile', () {
      const event = ProfileSavedEvent(testProfileEntity);

      expect(event, isA<BaseUiEvent>());
    });

    test('carries the profile the server returned', () {
      const event = ProfileSavedEvent(testProfileEntityEdited);

      expect(event.profile, testProfileEntityEdited);
      expect(event.profile.firstName, 'Mohamed');
    });

    test('holds whatever profile it is handed', () {
      const blank = ProfileSavedEvent(ProfileEntity());

      expect(blank.profile, const ProfileEntity());
    });
  });
}
