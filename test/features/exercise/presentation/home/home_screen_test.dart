import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_screen.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_header.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/test_localization.dart';

/// The home layout is designed for a 375x812 screen. Matching the test
/// surface keeps the ScreenUtil-scaled category cards inside their box.
void useDesignSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(loadTestLocalization);

  group('HomeScreen —', () {
    testWidgets('renders the app bar and the home body', (tester) async {
      useDesignSurface(tester);
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(
        find.text(LocaleKeys.home_hi_user.tr(args: ['Ahmed'])),
        findsOneWidget,
      );
      expect(
        find.text(LocaleKeys.home_lets_start_your_day.tr()),
        findsOneWidget,
      );
    });

    testWidgets('renders every home category', (tester) async {
      useDesignSurface(tester);
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

      expect(find.text(LocaleKeys.home_category.tr()), findsOneWidget);

      for (final key in [
        LocaleKeys.home_gym,
        LocaleKeys.home_fitness,
        LocaleKeys.home_yoga,
        LocaleKeys.home_aerobics,
        LocaleKeys.home_trainer,
      ]) {
        expect(find.text(key.tr()), findsOneWidget);
      }

      expect(find.byType(Image), findsNWidgets(6));
    });
  });

  group('HomeHeader —', () {
    testWidgets('greets the user and shows the avatar', (tester) async {
      useDesignSurface(tester);
      await tester.pumpWidget(makeTestableWidget(const HomeHeader()));

      expect(
        find.text(LocaleKeys.home_hi_user.tr(args: ['Ahmed'])),
        findsOneWidget,
      );
      expect(
        find.text(LocaleKeys.home_lets_start_your_day.tr()),
        findsOneWidget,
      );
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
