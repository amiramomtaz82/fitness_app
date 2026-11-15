import 'package:fitness_app/features/profile/presentation/profile/view/widgets/avatar_local_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  const fallbackKey = Key('fallback');

  Future<void> pumpLocal(WidgetTester tester) {
    return pumpLocalizedWidget(
      tester,
      const AvatarLocalPhoto(
        localPath: 'uploads/123/picked.jpg',
        fallback: SizedBox(key: fallbackKey),
      ),
    );
  }

  testWidgets('reads the photo the user just picked from disk', (tester) async {
    await pumpLocal(tester);

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<FileImage>());
    expect((image.image as FileImage).file.path, 'uploads/123/picked.jpg');
  });

  testWidgets('holds the file photo to the avatar crop', (tester) async {
    await pumpLocal(tester);

    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
  });

  testWidgets('keeps a fallback ready for a file it cannot read', (
    tester,
  ) async {
    await pumpLocal(tester);

    expect(find.byKey(fallbackKey), findsOneWidget);
  });
}
