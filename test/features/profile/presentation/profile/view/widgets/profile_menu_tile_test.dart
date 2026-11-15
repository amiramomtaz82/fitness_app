import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_action.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_item.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_trailing.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_menu_tile.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../profile_widget_test_helper.dart';

void main() {
  const tileKey = Key('menuTile');

  const navigationRow = ProfileMenuItem(
    icon: Icons.person_outline,
    action: ProfileMenuAction.editProfile,
  );
  const languageRow = ProfileMenuItem(
    icon: Icons.language,
    action: ProfileMenuAction.selectLanguage,
    trailing: ProfileMenuTrailing.languageSwitch,
  );
  const destructiveRow = ProfileMenuItem(
    icon: Icons.logout,
    action: ProfileMenuAction.logout,
    isDestructive: true,
  );

  Future<void> pumpTile(
    WidgetTester tester, {
    required ProfileMenuItem item,
    required String titleKey,
    bool languageSwitchOn = false,
    VoidCallback? onTap,
  }) async {
    await pumpLocalizedWidget(
      tester,
      ProfileMenuTile(
        key: tileKey,
        item: item,
        titleKey: titleKey,
        languageSwitchOn: languageSwitchOn,
        onTap: onTap,
      ),
    );
  }

  testWidgets('shows the title the list handed to it', (tester) async {
    await pumpTile(
      tester,
      item: navigationRow,
      titleKey: LocaleKeys.profile_edit_profile,
    );

    expect(find.text('Edit Profile'), findsOneWidget);
  });

  testWidgets('calls back when the row is tapped', (tester) async {
    var taps = 0;
    await pumpTile(
      tester,
      item: navigationRow,
      titleKey: LocaleKeys.profile_edit_profile,
      onTap: () => taps++,
    );

    await tester.tap(find.byKey(tileKey));
    await settleUi(tester);

    expect(taps, 1);
  });

  testWidgets('ends a row that opens a page with a chevron', (tester) async {
    await pumpTile(
      tester,
      item: navigationRow,
      titleKey: LocaleKeys.profile_edit_profile,
    );

    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
  });

  testWidgets('ends the language row with a switch reflecting the language', (
    tester,
  ) async {
    await pumpTile(
      tester,
      item: languageRow,
      titleKey: LocaleKeys.profile_select_language,
    );

    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await pumpTile(
      tester,
      item: languageRow,
      titleKey: LocaleKeys.profile_select_language,
      languageSwitchOn: true,
    );

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('reports a switch tap as a tap on the row', (tester) async {
    var taps = 0;
    await pumpTile(
      tester,
      item: languageRow,
      titleKey: LocaleKeys.profile_select_language,
      onTap: () => taps++,
    );

    await tester.tap(find.byType(Switch));
    await settleUi(tester);

    expect(taps, 1);
  });

  testWidgets('shows the icon of the row in the accent colour', (tester) async {
    await pumpTile(
      tester,
      item: navigationRow,
      titleKey: LocaleKeys.profile_edit_profile,
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.person_outline));
    expect(icon.color, CustomColors.dark.primary);
  });

  testWidgets('paints a destructive title with the accent colour', (
    tester,
  ) async {
    await pumpTile(
      tester,
      item: destructiveRow,
      titleKey: LocaleKeys.profile_logout,
    );

    expect(textInside(tester, tileKey).style!.color, CustomColors.dark.primary);

    await pumpTile(
      tester,
      item: navigationRow,
      titleKey: LocaleKeys.profile_edit_profile,
    );

    expect(textInside(tester, tileKey).style!.color, CustomColors.dark.white);
  });
}
