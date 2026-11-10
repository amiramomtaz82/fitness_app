import 'package:fitness_app/core/widgets/app_image_placeholder.dart';
import 'package:fitness_app/core/widgets/app_source_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> pumpImage(
    WidgetTester tester, {
    String? source,
    BoxFit fit = BoxFit.cover,
  }) {
    return tester.pumpWidget(
      makeTestableComponent(AppSourceImage(source: source, fit: fit)),
    );
  }

  group('AppSourceImage', () {
    testWidgets('shows an image placeholder when there is no source', (
      tester,
    ) async {
      await pumpImage(tester);

      expect(find.byType(Image), findsNothing);
      expect(
        find.descendant(
          of: find.byType(AppSourceImage),
          matching: find.byType(AppImagePlaceholder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses an asset provider when the source starts with assets/', (
      tester,
    ) async {
      await pumpImage(tester, source: 'assets/images/logo.png');

      final image = tester.widget<Image>(find.byType(Image));

      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, 'assets/images/logo.png');
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('uses a network provider when the source is a url', (
      tester,
    ) async {
      await pumpImage(
        tester,
        source: 'https://cdn.test/chest.png',
        fit: BoxFit.contain,
      );

      final image = tester.widget<Image>(find.byType(Image));

      expect(image.image, isA<NetworkImage>());
      expect((image.image as NetworkImage).url, 'https://cdn.test/chest.png');
      expect(image.fit, BoxFit.contain);
    });
  });
}
