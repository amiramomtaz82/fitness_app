import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_action.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_item.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_intent.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_state.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/show_logout_dialog_event.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/toggle_locale_event.dart';
import 'package:mocktail/mocktail.dart';

import '../../../profile_test_helper.dart';

void main() {
  late MockGetProfileUseCase mockGetProfile;
  late MockUploadPhotoUseCase mockUploadPhoto;
  late MockPickPhotoUseCase mockPickPhoto;
  late MockLogoutUseCase mockLogout;
  late ProfileCubit cubit;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
    mockUploadPhoto = MockUploadPhotoUseCase();
    mockPickPhoto = MockPickPhotoUseCase();
    mockLogout = MockLogoutUseCase();
    cubit = buildProfileCubit(
      mockGetProfile,
      mockUploadPhoto,
      mockPickPhoto,
      logout: mockLogout,
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
      expect(cubit.state.profile, isNull);
      expect(cubit.state.hasProfile, isFalse);
      expect(cubit.state.isProfileLoading, isFalse);
      expect(cubit.state.isUploadingPhoto, isFalse);
    });
  });

  group('LoadProfileIntent', () {
    test('fetches and publishes the profile', () async {
      stubGetProfile();

      cubit.doIntent(const LoadProfileIntent());
      await Future<void>.delayed(Duration.zero);

      expect(
        cubit.state.profileResource,
        const Resource<ProfileEntity>.success(testProfileEntity),
      );
      expect(cubit.state.profile, testProfileEntity);
      verify(() => mockGetProfile.call()).called(1);
    });

    test('serves the cached profile without a second request', () async {
      stubGetProfile();
      cubit.doIntent(const LoadProfileIntent());
      await Future<void>.delayed(Duration.zero);

      cubit.doIntent(const LoadProfileIntent());
      await Future<void>.delayed(Duration.zero);

      verify(() => mockGetProfile.call()).called(1);
    });

    test('shares one request between concurrent readers', () async {
      final completer = Completer<BaseResponse<ProfileEntity>>();
      when(() => mockGetProfile.call()).thenAnswer((_) => completer.future);

      cubit.doIntent(const LoadProfileIntent());
      cubit.doIntent(const LoadProfileIntent());
      completer.complete(
        const SuccessResponse<ProfileEntity>(testProfileEntity),
      );
      await Future<void>.delayed(Duration.zero);

      verify(() => mockGetProfile.call()).called(1);
      expect(cubit.state.profile, testProfileEntity);
    });

    test('reports a network failure on the loaded resource', () async {
      stubGetProfileFailure(const NetworkFailure());
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(const LoadProfileIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.profileResource.isError, isTrue);
      expect(cubit.state.profile, isNull);
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

    test(
      'an expired session is reported and leaves the profile empty',
      () async {
        stubGetProfileFailure(const UnauthorizedFailure());
        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(const LoadProfileIntent());
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, const ProfileState());
        expect(cubit.state.profile, isNull);
        expect(events, hasLength(1));
        final event = events.single as ShowErrorSnackBarEvent;
        expect(event.failure, isA<UnauthorizedFailure>());
      },
    );
  });

  group('SyncProfileIntent', () {
    test('publishes an already saved profile without a request', () {
      cubit.doIntent(const SyncProfileIntent(testProfileEntityEdited));

      expect(cubit.state.profile, testProfileEntityEdited);
      expect(
        cubit.state.profileResource,
        const Resource<ProfileEntity>.success(testProfileEntityEdited),
      );
      verifyNever(() => mockGetProfile.call());
    });
  });

  group('PickPhotoIntent', () {
    test('a cancelled pick uploads nothing and stays quiet', () async {
      stubPick();
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(const PickPhotoIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, const ProfileState());
      verifyNever(() => mockUploadPhoto.call(any()));
      expect(events, isEmpty);
    });

    test(
      'a picked photo is previewed, uploaded and the profile is published',
      () async {
        stubPick(photoPath: '/tmp/a.jpg');
        final uploaded = Completer<BaseResponse<ProfileEntity>>();
        when(
          () => mockUploadPhoto.call(any()),
        ).thenAnswer((_) => uploaded.future);

        cubit.doIntent(const PickPhotoIntent());
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.isUploadingPhoto, isTrue);
        expect(cubit.state.pendingPhotoPath, '/tmp/a.jpg');

        uploaded.complete(
          const SuccessResponse<ProfileEntity>(testProfileEntityEdited),
        );
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.profile, testProfileEntityEdited);
        expect(cubit.state.isUploadingPhoto, isFalse);
        expect(cubit.state.pendingPhotoPath, isNull);
      },
    );

    test('a finished upload publishes the returned profile', () async {
      stubPick(photoPath: '/tmp/a.jpg');
      stubUpload();
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(const PickPhotoIntent());
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
        cubit.doIntent(const LoadProfileIntent());
        await Future<void>.delayed(Duration.zero);
        stubPick(photoPath: '/tmp/a.jpg');
        stubUploadFailure(const ServerFailure());
        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(const PickPhotoIntent());
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.isUploadingPhoto, isFalse);
        expect(cubit.state.profile, testProfileEntity);
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

      cubit.doIntent(const PickPhotoIntent());
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

      cubit.doIntent(const PickPhotoIntent());
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
      stubPick(photoPath: '/tmp/a.jpg');

      cubit.doIntent(const PickPhotoIntent());
      await Future<void>.delayed(Duration.zero);
      cubit.doIntent(const PickPhotoIntent());
      await Future<void>.delayed(Duration.zero);
      completer.complete(
        const SuccessResponse<ProfileEntity>(testProfileEntityEdited),
      );
      await Future<void>.delayed(Duration.zero);

      verify(() => mockUploadPhoto.call('/tmp/a.jpg')).called(1);
    });
  });

  group('MenuTapIntent', () {
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

    test('the language row hands the toggle to the UI', () async {
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(MenuTapIntent(menuRow(ProfileMenuAction.selectLanguage)));
      await Future<void>.delayed(Duration.zero);

      expect(events, contains(isA<ToggleLocaleEvent>()));
    });

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
      for (final action in [ProfileMenuAction.changePassword]) {
        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(MenuTapIntent(menuRow(action)));
        await Future<void>.delayed(Duration.zero);

        expect(events, isEmpty);
      }
    });

    test('tapping logout menu row emits ShowLogoutConfirmationEvent', () async {
      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(MenuTapIntent(menuRow(ProfileMenuAction.logout)));
      await Future<void>.delayed(Duration.zero);

      expect(events, contains(isA<ShowLogoutConfirmationEvent>()));
    });

    test(
      'ConfirmLogoutIntent clears cache, emits success message and redirects to login',
      () async {
        when(
          () => mockLogout.call(),
        ).thenAnswer((_) async => const SuccessResponse<void>(null));

        final events = recordUiEvents(cubit.eventStream);

        cubit.doIntent(const ConfirmLogoutIntent());
        await Future<void>.delayed(Duration.zero);

        expect(
          events,
          contains(
            isA<ShowSuccessSnackBarEvent>().having(
              (e) => e.type,
              'type',
              CubitMessageType.logoutSuccess,
            ),
          ),
        );
        expect(
          events,
          contains(
            isA<NavigateReplacementEvent>().having(
              (e) => e.route,
              'route',
              AppRoutes.login,
            ),
          ),
        );
      },
    );

    test('ConfirmLogoutIntent failure emits failure event', () async {
      when(() => mockLogout.call()).thenAnswer(
        (_) async => ErrorResponse<void>(failure: const ServerFailure()),
      );

      final events = recordUiEvents(cubit.eventStream);

      cubit.doIntent(const ConfirmLogoutIntent());
      await Future<void>.delayed(Duration.zero);

      expect(events, contains(isA<ShowErrorSnackBarEvent>()));
    });
  });
}
