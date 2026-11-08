import 'package:fitness_app/features/profile/presentation/profile/view/widgets/avatar_remote_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  const fallbackKey = Key('fallback');
  const url = 'https://cdn.test/uploads/123/photo.jpg';

  Future<void> pumpRemote(WidgetTester tester) {
    return pumpLocalizedWidget(
      tester,
      const AvatarRemotePhoto(
        url: url,
        fallback: SizedBox(key: fallbackKey),
      ),
    );
  }

  testWidgets('loads the photo the server stored', (tester) async {
    await pumpRemote(tester);

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, url);
  });

  testWidgets('holds the remote photo to the avatar crop', (tester) async {
    await pumpRemote(tester);

    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
  });

  testWidgets('keeps a fallback ready for a url it cannot reach', (
    tester,
  ) async {
    await pumpRemote(tester);

    expect(find.byKey(fallbackKey), findsOneWidget);
  });
}
