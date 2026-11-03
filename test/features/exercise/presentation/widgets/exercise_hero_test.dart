import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/widgets/app_back_button.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  const backgroundKey = Key('background');

  Widget hero({String? subtitle, double height = 200}) {
    return ExerciseHero(
      height: height,
      title: 'Chest Exercise',
      subtitle: subtitle,
      background: const ColoredBox(key: backgroundKey, color: Colors.blue),
    );
  }

  Future<void> pumpHero(
    WidgetTester tester, {
    String? subtitle,
    double height = 200,
  }) {
    return tester.pumpWidget(
      makeTestableComponent(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 375,
            child: hero(subtitle: subtitle, height: height),
          ),
        ),
      ),
    );
  }

  group('ExerciseHero', () {
    testWidgets('paints the given background and the requested height', (
      tester,
    ) async {
      await pumpHero(tester, height: 240);

      expect(find.byKey(backgroundKey), findsOneWidget);
      expect(tester.getSize(find.byType(ExerciseHero)), const Size(375, 240));
    });

    testWidgets('clips only the bottom corners', (tester) async {
      await pumpHero(tester);

      final clip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(ExerciseHero),
          matching: find.byType(ClipRRect),
        ),
      );
      final radius = clip.borderRadius as BorderRadius;

      expect(radius.topLeft, Radius.zero);
      expect(radius.bottomLeft, Radius.circular(24.r));
      expect(radius.bottomRight, Radius.circular(24.r));
    });

    testWidgets('fades the screen background over the image', (tester) async {
      await pumpHero(tester);

      final context = tester.element(find.byType(ExerciseHero));
      final layers = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(ExerciseHero),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient = layers
          .map((layer) => (layer.decoration as BoxDecoration).gradient)
          .whereType<LinearGradient>()
          .single;

      expect(gradient.colors.first, Colors.transparent);
      expect(
        gradient.colors[1],
        context.colors.background.withValues(alpha: 0.45),
      );
      expect(
        gradient.colors.last,
        context.colors.background.withValues(alpha: 0.9),
      );
      expect(gradient.stops, [0.3, 0.65, 1.0]);
    });

    testWidgets('shows the title in the hero text style', (tester) async {
      await pumpHero(tester);

      final title = tester.widget<Text>(find.text('Chest Exercise'));

      expect(title.textAlign, TextAlign.center);
      expect(title.style!.fontSize, 22.sp);
      expect(title.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('shows the subtitle in the accent color when it exists', (
      tester,
    ) async {
      await pumpHero(tester, subtitle: 'Beginner');

      final context = tester.element(find.byType(ExerciseHero));
      final subtitle = tester.widget<Text>(find.text('Beginner'));

      expect(subtitle.style!.color, context.colors.secondary);
    });

    testWidgets('leaves the subtitle out when it is missing', (tester) async {
      await pumpHero(tester);

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('places the back button over the top left of the image', (
      tester,
    ) async {
      await pumpHero(tester);

      final backButtonFinder = find.descendant(
        of: find.byType(ExerciseHero),
        matching: find.byType(AppBackButton),
      );

      expect(backButtonFinder, findsOneWidget);
      expect(tester.getTopLeft(backButtonFinder), Offset(16.w, 16.h));
    });
  });
}
