import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_avatar.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../profile_widget_test_helper.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    ProfileEntity? profile,
    String? pickedPhotoPath,
    VoidCallback? onPickPhoto,
  }) async {
    await pumpLocalizedWidget(
      tester,
      ProfileHeader(
        profile: profile,
        pickedPhotoPath: pickedPhotoPath,
        onPickPhoto: onPickPhoto,
      ),
    );
  }

  testWidgets('shows the name the profile carries', (tester) async {
    await pumpHeader(tester, profile: testProfileEntity);

    expect(find.text('Ahmed Sukkary'), findsOneWidget);
  });

  testWidgets('keeps the name line empty before a profile arrives', (
    tester,
  ) async {
    await pumpHeader(tester);

    expect(find.text('Ahmed Sukkary'), findsNothing);
    expect(find.byType(ProfileAvatar), findsOneWidget);
  });

  testWidgets('shows the stored photo of the profile', (tester) async {
    await pumpHeader(tester, profile: testProfileEntity);

    expect(avatarImage(tester).image, isA<NetworkImage>());
  });

  testWidgets('hands the picked photo down to the avatar', (tester) async {
    await pumpHeader(
      tester,
      profile: testProfileEntity,
      pickedPhotoPath: 'uploads/123/picked.jpg',
    );

    expect(avatarImage(tester).image, isA<FileImage>());
  });

  testWidgets('forwards a tap on the avatar to the photo picker', (
    tester,
  ) async {
    var taps = 0;
    await pumpHeader(
      tester,
      profile: testProfileEntity,
      onPickPhoto: () => taps++,
    );

    await tester.tap(find.byKey(avatarKey));
    await settleUi(tester);

    expect(taps, 1);
  });
}
