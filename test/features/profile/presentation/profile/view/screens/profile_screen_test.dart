import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_item.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/screens/profile_screen.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_header.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_menu_list.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../profile_widget_test_helper.dart';

void main() {
  Future<ProfileCubit> openProfileScreen(
    WidgetTester tester, {
    ProfileEntity? profile,
    MockPickPhotoUseCase? pickPhoto,
    List<GoRoute> extraRoutes = const [],
  }) async {
    final cubit = await startProfileCubit(
      profile: profile,
      pickPhoto: pickPhoto,
    );
    await cubit.refresh();
    await pumpProfileRoute(
      tester,
      extraRoutes: extraRoutes,
      screen: BlocProvider.value(value: cubit, child: const ProfileScreen()),
    );
    return cubit;
  }

  GoRoute webMarkerRoute() {
    return GoRoute(
      path: AppRoutes.webView,
      builder: (_, state) =>
          Scaffold(body: Text('WEB:${(state.extra as WebPage).name}')),
    );
  }

  testWidgets('shows the loaded profile above the menu', (tester) async {
    await openProfileScreen(tester, profile: testProfileEntity);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Ahmed Sukkary'), findsOneWidget);
    expect(find.byType(ProfileMenuList), findsOneWidget);
  });

  testWidgets('renders a row for every entry the menu offers', (tester) async {
    await openProfileScreen(tester, profile: testProfileEntity);

    for (final item in profileMenuItems) {
      expect(find.byKey(Key('menu_${item.action.name}')), findsOneWidget);
    }
  });

  testWidgets('keeps the page usable when the profile cannot be read', (
    tester,
  ) async {
    await openProfileScreen(tester);

    expect(find.byType(ProfileHeader), findsOneWidget);
    expect(find.text('Ahmed Sukkary'), findsNothing);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('a tap on the photo row sends the user to the edit page', (
    tester,
  ) async {
    await openProfileScreen(
      tester,
      profile: testProfileEntity,
      extraRoutes: [markerRoute(AppRoutes.editProfile, 'EDIT_MARKER')],
    );

    await tester.tap(find.byKey(const Key('menu_editProfile')));
    await settleUi(tester);

    expect(find.text('EDIT_MARKER'), findsOneWidget);
  });

  testWidgets('a tap on a web row opens that exact page', (tester) async {
    await openProfileScreen(
      tester,
      profile: testProfileEntity,
      extraRoutes: [webMarkerRoute()],
    );

    await tester.tap(find.byKey(const Key('menu_privacyPolicy')));
    await settleUi(tester);

    expect(find.text('WEB:privacyPolicy'), findsOneWidget);
  });

  testWidgets('a tap on the photo hands the picker to the cubit', (
    tester,
  ) async {
    final pickPhoto = MockPickPhotoUseCase();
    when(
      () => pickPhoto.call(),
    ).thenAnswer((_) async => const SuccessResponse<String?>(null));
    await openProfileScreen(
      tester,
      profile: testProfileEntity,
      pickPhoto: pickPhoto,
    );

    await tester.tap(find.byKey(avatarKey));
    await settleUi(tester);

    verify(() => pickPhoto.call()).called(1);
  });

  testWidgets('the language switch moves the whole page to arabic', (
    tester,
  ) async {
    final cubit = await openProfileScreen(tester, profile: testProfileEntity);

    await tester.tap(find.byType(Switch));
    await tester.runAsync(() => settleUi(tester, steps: 12));

    expect(cubit.state.language, AppLanguage.arabic);
    expect(
      tester.element(find.byType(ProfileScreen)).locale,
      const Locale('ar'),
    );
    expect(find.text('Profile'), findsNothing);
  });
}
