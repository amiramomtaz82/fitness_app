import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/core/local/locale_preferences.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_action.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_item.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_intent.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_state.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_ui_event.dart';
import 'package:mocktail/mocktail.dart';

import '../../../profile_test_helper.dart';

void main() {
  late MockGetProfileUseCase mockGetProfile;
  late MockUploadPhotoUseCase mockUploadPhoto;
  late MockPickPhotoUseCase mockPickPhoto;
  late MockLocaleService mockLocaleService;
  late LocalePreferences localePreferences;
  late ProfileCubit cubit;

  setUpAll(registerProfileFallbacks);

  setUp(() async {
    mockGetProfile = MockGetProfileUseCase();
    mockUploadPhoto = MockUploadPhotoUseCase();
    mockPickPhoto = MockPickPhotoUseCase();
    mockLocaleService = MockLocaleService();
    localePreferences = await localePreferencesWith();
    cubit = buildProfileCubit(
      mockGetProfile,
      mockUploadPhoto,
      mockPickPhoto,
      localePreferences,
      localeService: mockLocaleService,
    );
  });

  tearDown(() => cubit.close());

  ProfileMenuItem menuRow(ProfileMenuAction action) =>
      profileMenuItems.firstWhere((item) => item.action == action);

  void stubGetProfile({ProfileEntity profile = testProfileEntity}) {
    when(
      () => mockGetProfile.call(),
    ).thenAnswer((_) async => SuccessResponse<ProfileEntity>(profile));
  }

  void stubGetProfileFailure(Failure failure) {
    when(
      () => mockGetProfile.call(),
    ).thenAnswer((_) async => ErrorResponse<ProfileEntity>(failure: failure));
  }

  void stubPick({String? photoPath}) {
    when(
      () => mockPickPhoto.call(),
    ).thenAnswer((_) async => SuccessResponse<String?>(photoPath));
  }

  void stubPickFailure(Failure failure) {
    when(
      () => mockPickPhoto.call(),
    ).thenAnswer((_) async => ErrorResponse<String?>(failure: failure));
  }

  void stubUpload({ProfileEntity profile = testProfileEntityEdited}) {
    when(
      () => mockUploadPhoto.call(any()),
    ).thenAnswer((_) async => SuccessResponse<ProfileEntity>(profile));
  }

  void stubUploadFailure(Failure failure) {
    when(
      () => mockUploadPhoto.call(any()),
    ).thenAnswer((_) async => ErrorResponse<ProfileEntity>(failure: failure));
  }

  group('ProfileCubit initial state', () {
    test('holds no profile and idle resources', () {
      expect(cubit.state, const ProfileState());
      expect(cubit.profile, isNull);
      expect(cubit.state.hasProfile, isFalse);
      expect(cubit.state.isProfileLoading, isFalse);
      expect(cubit.state.isUploadingPhoto, isFalse);
    });
  });

  group('loading the profile', () {
    test('fetches and publishes the profile', () async {
      stubGetProfile();

      await cubit.ensureLoaded();

      expect(
        cubit.state.profileResource,
        const Resource<ProfileEntity>.success(testProfileEntity),
      );
      expect(cubit.profile, testProfileEntity);
      verify(() => mockGetProfile.call()).called(1);
    });

    test('serves the cached profile without a second request', () async {
      stubGetProfile();
      await cubit.ensureLoaded();

      await cubit.ensureLoaded();

      verify(() => mockGetProfile.call()).called(1);
    });

    test('shares one request between concurrent readers', () async {
      final completer = Completer<BaseResponse<ProfileEntity>>();
      when(() => mockGetProfile.call()).thenAnswer((_) => completer.future);

      final first = cubit.ensureLoaded();
      final second = cubit.ensureLoaded();
      completer.complete(
        const SuccessResponse<ProfileEntity>(testProfileEntity),
      );
      await Future.wait([first, second]);

      verify(() => mockGetProfile.call()).called(1);
      expect(cubit.profile, testProfileEntity);
    });

    test('refresh reads the server again after a cache hit', () async {
      stubGetProfile();
      await cubit.ensureLoaded();

      await cubit.refresh();

      verify(() => mockGetProfile.call()).called(2);
    });

    test('refresh joins a request that is already running', () async {
      final completer = Completer<BaseResponse<ProfileEntity>>();
      when(() => mockGetProfile.call()).thenAnswer((_) => completer.future);

      final loading = cubit.ensureLoaded();
      final refreshing = cubit.refresh();
      completer.complete(
        const SuccessResponse<ProfileEntity>(testProfileEntity),
      );
      await Future.wait([loading, refreshing]);

      verify(() => mockGetProfile.call()).called(1);
    });

    test('keeps showing the cached profile while refreshing', () async {
      stubGetProfile();
      await cubit.ensureLoaded();
      final running = cubit.refresh();

      expect(cubit.state.isProfileLoading, isTrue);
      expect(cubit.profile, testProfileEntity);

      await running;
    });

    test('reports a network failure but keeps the cached profile', () async {
      stubGetProfile();
      await cubit.ensureLoaded();
      stubGetProfileFailure(const NetworkFailure());
      final events = recordUiEvents(cubit.eventStream);

      await cubit.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.profileResource.isError, isTrue);
      expect(cubit.profile, testProfileEntity);
      expect(
        events,
        contains(
          isA<ShowErrorSnackBarEvent>().having(
            (event) => event.failure,
            'failure',
            isA<NetworkFailure>(),
          ),
        ),
      );
    });

    test('drops the cached user when the session is no longer valid', () async {
      stubGetProfile();
      await cubit.ensureLoaded();
      stubGetProfileFailure(const UnauthorizedFailure());
      final events = recordUiEvents(cubit.eventStream);

      await cubit.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, const ProfileState());
      expect(cubit.profile, isNull);
      expect(events, hasLength(1));
      final event = events.single as ShowErrorSnackBarEvent;
      expect(event.failure, isA<UnauthorizedFailure>());
    });
  });

  group('photo', () {
    test('a cancelled pick uploads nothing and stays quiet', () async {
      stubPick();
      final events = recordUiEvents(cubit.eventStream);

      await cubit.pickAndUploadPhoto();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, const ProfileState());
      verifyNever(() => mockUploadPhoto.call(any()));
      expect(events, isEmpty);
    });

    test(
      'a picked photo is previewed, uploaded and the profile is published',
      () async {
        stubGetProfile();
        stubPick(photoPath: '/tmp/a.jpg');
        final uploaded = Completer<BaseResponse<ProfileEntity>>();
        when(
          () => mockUploadPhoto.call(any()),
        ).thenAnswer((_) => uploaded.future);

        final running = cubit.pickAndUploadPhoto();
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.isUploadingPhoto, isTrue);
        expect(cubit.state.pendingPhotoPath, '/tmp/a.jpg');

        uploaded.complete(
          const SuccessResponse<ProfileEntity>(testProfileEntityEdited),
        );
        await running;

        expect(cubit.profile, testProfileEntityEdited);
        expect(cubit.state.isUploadingPhoto, isFalse);
        expect(cubit.state.pendingPhotoPath, isNull);
      },
    );

    test('a finished upload publishes the returned profile', () async {
      stubPick(photoPath: '/tmp/a.jpg');
      stubUpload();
      final events = recordUiEvents(cubit.eventStream);

      await cubit.pickAndUploadPhoto();
      await Future<void>.delayed(Duration.zero);

      verify(() => mockUploadPhoto.call('/tmp/a.jpg')).called(1);
      expect(
        events,
        contains(
          isA<ShowSuccessSnackBarEvent>().having(
            (event) => event.type,
            'type',
            CubitMessageType.profileUpdated,
          ),
        ),
      );
    });

    test(
      'an upload failure keeps the profile and clears the preview',
      () async {
        stubGetProfile();
        await cubit.ensureLoaded();
        stubPick(photoPath: '/tmp/a.jpg');
        stubUploadFailure(const ServerFailure());
        final events = recordUiEvents(cubit.eventStream);

        await cubit.pickAndUploadPhoto();
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.isUploadingPhoto, isFalse);
        expect(cubit.profile, testProfileEntity);
        expect(
          events,
          contains(
            isA<ShowErrorSnackBarEvent>().having(
              (event) => event.failure,
              'failure',
              isA<ServerFailure>(),
            ),
          ),
        );
      },
    );

    test('a picker failure is reported before any upload', () async {
      stubPickFailure(const UnknownFailure());
      final events = recordUiEvents(cubit.eventStream);

      await cubit.pickAndUploadPhoto();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isUploadingPhoto, isFalse);
      verifyNever(() => mockUploadPhoto.call(any()));
      expect(
        events,
        contains(
          isA<ShowErrorSnackBarEvent>().having(
            (event) => event.failure,
            'failure',
            isA<UnknownFailure>(),
          ),
        ),
      );
    });

    test('a too large photo is reported as its own failure', () async {
      stubPick(photoPath: '/tmp/huge.jpg');
      stubUploadFailure(const PhotoTooLargeFailure());
      final events = recordUiEvents(cubit.eventStream);

      await cubit.pickAndUploadPhoto();
      await Future<void>.delayed(Duration.zero);

      expect(
        events,
        contains(
          isA<ShowErrorSnackBarEvent>().having(
            (event) => event.failure,
            'failure',
            isA<PhotoTooLargeFailure>(),
          ),
        ),
      );
    });

    test('ignores a second upload while one is running', () async {
      final completer = Completer<BaseResponse<ProfileEntity>>();
      when(
        () => mockUploadPhoto.call(any()),
      ).thenAnswer((_) => completer.future);

      final first = cubit.uploadPhoto('/tmp/a.jpg');
      final second = cubit.uploadPhoto('/tmp/b.jpg');
      completer.complete(
        const SuccessResponse<ProfileEntity>(testProfileEntityEdited),
      );
      await Future.wait([first, second]);

      verify(() => mockUploadPhoto.call('/tmp/a.jpg')).called(1);
      verifyNever(() => mockUploadPhoto.call('/tmp/b.jpg'));
    });

    test('PickPhotoIntent runs the pick and upload flow', () async {
      stubPick(photoPath: '/tmp/a.jpg');
      stubUpload();

      cubit.doIntent(const PickPhotoIntent());
      await Future<void>.delayed(Duration.zero);

      verify(() => mockUploadPhoto.call('/tmp/a.jpg')).called(1);
    });
  });

  group('cache control', () {
    test('applyProfile publishes an already saved profile', () {
      cubit.applyProfile(testProfileEntityEdited);

      expect(cubit.profile, testProfileEntityEdited);
      expect(
        cubit.state.profileResource,
        const Resource<ProfileEntity>.success(testProfileEntityEdited),
      );
      verifyNever(() => mockGetProfile.call());
    });

    test('clearCache forgets the user', () async {
      stubGetProfile();
      await cubit.ensureLoaded();

      cubit.clearCache();

      expect(cubit.state, const ProfileState());
      expect(cubit.profile, isNull);
    });

    test('the edit row asks the UI to open the edit route', () async {
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(MenuTapIntent(menuRow(ProfileMenuAction.editProfile)));
      await Future<void>.delayed(Duration.zero);

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
  });

  group('menu links', () {
    test('security, privacy and help open their web page', () async {
      for (final action in [
        ProfileMenuAction.security,
        ProfileMenuAction.privacyPolicy,
        ProfileMenuAction.help,
      ]) {
        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(MenuTapIntent(menuRow(action)));
        await Future<void>.delayed(Duration.zero);

        final event = events.last as NavigateEvent;
        expect(event.route, AppRoutes.webView);
        expect(event.arguments, isA<WebPage>());
      }
    });

    test('rows without a destination stay quiet', () async {
      for (final action in [
        ProfileMenuAction.changePassword,
        ProfileMenuAction.logout,
      ]) {
        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(MenuTapIntent(menuRow(action)));
        await Future<void>.delayed(Duration.zero);

        expect(events, isEmpty);
      }
    });
  });

  group('language', () {
    test('starts with the saved language', () async {
      final arabicCubit = buildProfileCubit(
        mockGetProfile,
        mockUploadPhoto,
        mockPickPhoto,
        await localePreferencesWith(language: 'ar'),
      );

      expect(arabicCubit.state.language, AppLanguage.arabic);
      await arabicCubit.close();
    });

    test('applySavedLanguage syncs the request language', () async {
      await cubit.applySavedLanguage();

      expect(cubit.state.language, AppLanguage.english);
      verify(() => mockLocaleService.setLanguageCode('en')).called(1);
    });

    test(
      'tapping the language row flips, saves and notifies the screen',
      () async {
        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(
          MenuTapIntent(menuRow(ProfileMenuAction.selectLanguage)),
        );
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.language, AppLanguage.arabic);
        expect(
          cubit.state.profileResource,
          const Resource<ProfileEntity>.initial(),
        );
        verify(() => mockLocaleService.setLanguageCode('ar')).called(1);
        expect(localePreferences.readLanguage(), AppLanguage.arabic);
        expect(events, contains(isA<ProfileUiEvent>()));
      },
    );

    test('a second tap returns to English', () async {
      await cubit.toggleLanguage();

      await cubit.toggleLanguage();

      expect(cubit.state.language, AppLanguage.english);
      expect(localePreferences.readLanguage(), AppLanguage.english);
    });
  });
}
