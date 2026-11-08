import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/local/locale_cubit.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/screens/edit_profile_screen.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_cubit.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_app.dart';
import 'profile_test_helper.dart';

export 'profile_test_helper.dart'
    show
        MockEditProfileUseCase,
        MockLocaleService,
        MockPickPhotoUseCase,
        registerProfileFallbacks,
        recordUiEvents,
        testProfileEntity,
        testProfileEntityEdited;

const avatarKey = Key('profileAvatar');

Future<ProfileCubit> startProfileCubit({
  ProfileEntity? profile,
  MockPickPhotoUseCase? pickPhoto,
}) async {
  final getProfile = MockGetProfileUseCase();
  when(() => getProfile.call()).thenAnswer(
    (_) async => profile == null
        ? ErrorResponse<ProfileEntity>(failure: const NetworkFailure())
        : SuccessResponse<ProfileEntity>(profile),
  );
  final cubit = buildProfileCubit(
    getProfile,
    MockUploadPhotoUseCase(),
    pickPhoto ?? MockPickPhotoUseCase(),
  );
  addTearDown(cubit.close);
  return cubit;
}

Future<LocaleCubit> startLocaleCubit({String? language}) async {
  final cubit = buildLocaleCubit(
    await localePreferencesWith(language: language),
  );
  addTearDown(cubit.close);
  return cubit;
}

Future<EditProfileCubit> startLoadedEditForm(
  WidgetTester tester, {
  ProfileEntity? profile = testProfileEntity,
  MockEditProfileUseCase? editProfile,
  MockPickPhotoUseCase? pickPhoto,
}) async {
  final profileCubit = await startProfileCubit(
    profile: profile,
    pickPhoto: pickPhoto,
  );
  final cubit = EditProfileCubit(editProfile ?? MockEditProfileUseCase());
  addTearDown(cubit.close);
  await pumpProfileRoute(
    tester,
    screen: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: profileCubit),
        BlocProvider.value(value: cubit),
      ],
      child: const EditProfileScreen(),
    ),
  );
  return cubit;
}

Future<void> pumpProfileRoute(
  WidgetTester tester, {
  required Widget screen,
  List<GoRoute> extraRoutes = const [],
}) async {
  await pumpLocalizedApp(
    tester,
    makeLocalizedApp(
      routes: [
        GoRoute(path: '/', builder: (_, _) => screen),
        ...extraRoutes,
      ],
    ),
  );
}

GoRoute markerRoute(String path, String marker) {
  return GoRoute(
    path: path,
    builder: (_, _) => Scaffold(body: Text(marker)),
  );
}

Image avatarImage(WidgetTester tester) {
  return tester
      .widgetList<Image>(
        find.descendant(
          of: find.byKey(avatarKey),
          matching: find.byType(Image),
        ),
      )
      .first;
}

Text textInside(WidgetTester tester, Key key) {
  return tester.widget<Text>(
    find.descendant(of: find.byKey(key), matching: find.byType(Text)),
  );
}
