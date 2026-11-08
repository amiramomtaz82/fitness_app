import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../profile_widget_test_helper.dart';

void main() {
  testWidgets('taps the avatar to ask for a new photo', (tester) async {
    var taps = 0;
    await pumpLocalizedWidget(tester, ProfileAvatar(onTap: () => taps++));

    await tester.tap(find.byKey(avatarKey));
    await settleUi(tester);

    expect(taps, 1);
  });

  testWidgets('falls back to the placeholder while there is no photo', (
    tester,
  ) async {
    await pumpLocalizedWidget(tester, const ProfileAvatar());

    expect(avatarImage(tester).image, isA<AssetImage>());
  });

  testWidgets('shows the photo the server sent', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const ProfileAvatar(photoUrl: 'https://cdn.test/uploads/123/photo.jpg'),
    );

    expect(avatarImage(tester).image, isA<NetworkImage>());
  });

  testWidgets('prefers the photo the user just picked over the stored one', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const ProfileAvatar(
        photoUrl: 'https://cdn.test/uploads/123/photo.jpg',
        pickedPhotoPath: 'uploads/123/picked.jpg',
      ),
    );

    expect(avatarImage(tester).image, isA<FileImage>());
  });

  testWidgets('spins only while a picked photo is being uploaded', (
    tester,
  ) async {
    await pumpLocalizedWidget(tester, const ProfileAvatar());
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await pumpLocalizedWidget(
      tester,
      const ProfileAvatar(pickedPhotoPath: 'uploads/123/picked.jpg'),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('always offers the edit badge on the photo', (tester) async {
    await pumpLocalizedWidget(tester, const ProfileAvatar());

    expect(find.byIcon(Icons.edit), findsOneWidget);
  });
}
