import 'package:fitness_app/core/widgets/app_back_button.dart';
import 'package:fitness_app/core/widgets/app_title_bar.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows the page title in the language of the app', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const AppTitleBar(titleKey: LocaleKeys.profile_profile),
    );

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('centres the title when nothing is shown on the left', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const AppTitleBar(titleKey: LocaleKeys.profile_profile),
    );

    expect(find.byType(AppBackButton), findsNothing);
    expect(
      tester.getRect(find.text('Profile')).center.dx,
      closeTo(tester.getRect(find.byType(Scaffold)).center.dx, 1),
    );
  });

  testWidgets('puts the back button where the reserved space was', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const AppTitleBar(
        titleKey: LocaleKeys.profile_edit_profile,
        showBackButton: true,
      ),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(
      tester.getRect(find.byType(AppBackButton)).left,
      lessThanOrEqualTo(tester.getRect(find.text('Edit Profile')).left),
    );
  });

  testWidgets('keeps the alignment centred when the title is long', (
    tester,
  ) async {
    await pumpLocalizedWidget(
      tester,
      const AppTitleBar(
        titleKey: LocaleKeys.profile_setup_activity_level_title,
      ),
    );

    final title = tester.widget<Text>(find.textContaining('ACTIVITY'));
    expect(title.textAlign, TextAlign.center);
  });
}
