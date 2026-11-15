import 'package:fitness_app/features/profile/presentation/profile/view/widgets/avatar_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Image shownImage(WidgetTester tester) {
    return tester.widgetList<Image>(find.byType(Image)).first;
  }

  Future<void> pumpAvatarPhoto(
    WidgetTester tester, {
    String? localPath,
    String? url,
  }) {
    return pumpLocalizedWidget(
      tester,
      AvatarPhoto(localPath: localPath, url: url),
    );
  }

  testWidgets('prefers the photo just picked over the stored one', (
    tester,
  ) async {
    await pumpAvatarPhoto(
      tester,
      localPath: 'uploads/123/picked.jpg',
      url: 'https://cdn.test/uploads/123/photo.jpg',
    );

    expect(shownImage(tester).image, isA<FileImage>());
  });

  testWidgets('loads the stored photo when nothing new was picked', (
    tester,
  ) async {
    await pumpAvatarPhoto(
      tester,
      url: 'https://cdn.test/uploads/123/photo.jpg',
    );

    expect(shownImage(tester).image, isA<NetworkImage>());
  });

  testWidgets('falls back to the placeholder while there is no photo', (
    tester,
  ) async {
    await pumpAvatarPhoto(tester);

    expect(shownImage(tester).image, isA<AssetImage>());
  });
}
