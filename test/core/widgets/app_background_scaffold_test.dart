import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

const kChildKey = Key('scaffold-child');
const kTopInset = 40.0;
const kBottomInset = 30.0;

void main() {
  Widget withInsets(EdgeInsets padding, Widget child) {
    return Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: padding),
        child: child,
      ),
    );
  }

  Future<void> pumpScaffold(
    WidgetTester tester, {
    bool safeAreaTop = true,
    String? backgroundImage,
    Gradient? overlayGradient,
  }) {
    usePhoneScreenSize(tester);

    return tester.pumpWidget(
      makeTestableWidget(
        withInsets(
          const EdgeInsets.only(top: kTopInset, bottom: kBottomInset),
          AppBackgroundScaffold(
            safeAreaTop: safeAreaTop,
            backgroundImage: backgroundImage,
            overlayGradient: overlayGradient,
            child: const SizedBox.expand(key: kChildKey),
          ),
        ),
      ),
    );
  }

  group('AppBackgroundScaffold', () {
    testWidgets('paints the screen over the default background', (
      tester,
    ) async {
      await pumpScaffold(tester);

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(AppBackgroundScaffold),
          matching: find.byType(Image),
        ),
      );

      expect((image.image as AssetImage).assetName, AppAssets.authProfileBG);
      expect(image.fit, BoxFit.cover);
      expect(find.byKey(kChildKey), findsOneWidget);
    });

    testWidgets('uses the background the screen asked for', (tester) async {
      await pumpScaffold(tester, backgroundImage: AppAssets.foodBG);

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(AppBackgroundScaffold),
          matching: find.byType(Image),
        ),
      );

      expect((image.image as AssetImage).assetName, AppAssets.foodBG);
    });

    testWidgets('dims the background with the default tint', (tester) async {
      await pumpScaffold(tester);

      final tint = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppBackgroundScaffold),
          matching: find.byType(Container),
        ),
      );
      final decoration = tint.decoration! as BoxDecoration;

      expect(decoration.color, Colors.black.withValues(alpha: 0.6));
      expect(decoration.gradient, isNull);
    });

    testWidgets('lets the screen trade the tint for a gradient', (
      tester,
    ) async {
      const gradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      await pumpScaffold(tester, overlayGradient: gradient);

      final tint = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppBackgroundScaffold),
          matching: find.byType(Container),
        ),
      );
      final decoration = tint.decoration! as BoxDecoration;

      expect(decoration.gradient, gradient);
      expect(decoration.color, isNull);
    });

    testWidgets('keeps the content under the top inset by default', (
      tester,
    ) async {
      await pumpScaffold(tester);

      expect(
        tester.getTopLeft(find.byKey(kChildKey)),
        const Offset(0, kTopInset),
      );
    });

    testWidgets('lets a full bleed screen run under the top inset', (
      tester,
    ) async {
      await pumpScaffold(tester, safeAreaTop: false);

      expect(tester.getTopLeft(find.byKey(kChildKey)), Offset.zero);
    });

    testWidgets('always clears the bottom inset', (tester) async {
      await pumpScaffold(tester, safeAreaTop: false);

      expect(
        tester.getBottomLeft(find.byKey(kChildKey)),
        const Offset(0, 812 - kBottomInset),
      );
    });
  });
}
