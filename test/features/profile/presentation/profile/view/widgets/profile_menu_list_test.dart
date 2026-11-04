import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_action.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_item.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_menu_list.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_menu_tile.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../profile_widget_test_helper.dart';

void main() {
  late ProfileCubit cubit;

  setUp(() async {
    cubit = await startProfileCubit(profile: testProfileEntity);
  });

  Future<void> pumpMenuList(WidgetTester tester) async {
    await pumpProfileRoute(
      tester,
      screen: BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: Center(child: ProfileMenuList())),
      ),
    );
  }

  List<ProfileMenuAction> renderedActions(WidgetTester tester) {
    return tester
        .widgetList<ProfileMenuTile>(find.byType(ProfileMenuTile))
        .map((tile) => tile.item.action)
        .toList();
  }

  testWidgets('shows one row for every menu entry, in order', (tester) async {
    await pumpMenuList(tester);

    expect(
      renderedActions(tester),
      profileMenuItems.map((item) => item.action).toList(),
    );
    for (final item in profileMenuItems) {
      expect(find.byKey(Key('menu_${item.action.name}')), findsOneWidget);
    }
  });

  testWidgets('draws a line between rows only', (tester) async {
    await pumpMenuList(tester);

    expect(find.byType(Divider), findsNWidgets(profileMenuItems.length - 1));
  });

  testWidgets('titles every row in the language of the state', (tester) async {
    await pumpMenuList(tester);

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Select Language (English)'), findsOneWidget);
  });

  testWidgets('a tap on a row asks the cubit to open its page', (tester) async {
    final events = recordUiEvents(cubit.eventStream);
    await pumpMenuList(tester);

    await tester.tap(find.byKey(const Key('menu_editProfile')));
    await settleUi(tester);

    expect(
      events,
      contains(
        isA<NavigateEvent>().having(
          (event) => event.route,
          'route',
          AppRoutes.editProfile,
        ),
      ),
    );
  });

  testWidgets('a tap on a web row asks for the page it carries', (
    tester,
  ) async {
    final events = recordUiEvents(cubit.eventStream);
    await pumpMenuList(tester);

    await tester.tap(find.byKey(const Key('menu_security')));
    await settleUi(tester);

    expect(
      events,
      contains(
        isA<NavigateEvent>().having(
          (event) => event.route,
          'route',
          AppRoutes.webView,
        ),
      ),
    );
    expect(
      (events.whereType<NavigateEvent>().single).arguments,
      WebPage.security,
    );
  });

  testWidgets('the language row shows and applies the saved language', (
    tester,
  ) async {
    await pumpMenuList(tester);

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await settleUi(tester);

    expect(cubit.state.language, AppLanguage.arabic);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(find.text('Select Language (Arabic)'), findsOneWidget);
  });

  testWidgets('a tap on the language row is the same as the switch', (
    tester,
  ) async {
    await pumpMenuList(tester);

    await tester.tap(find.byKey(const Key('menu_selectLanguage')));
    await settleUi(tester);

    expect(cubit.state.language, AppLanguage.arabic);
  });

  testWidgets('rows without an action stay inert', (tester) async {
    final events = recordUiEvents(cubit.eventStream);
    await pumpMenuList(tester);

    await tester.tap(find.byKey(const Key('menu_changePassword')));
    await settleUi(tester);

    expect(cubit.state.language, AppLanguage.english);
    expect(events, isEmpty);
  });
}
