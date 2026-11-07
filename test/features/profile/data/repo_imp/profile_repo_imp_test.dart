import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/data/models/profile_request_dto.dart';
import 'package:fitness_app/features/profile/data/repo_imp/profile_repo_imp.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

RequestOptions testOptions() => RequestOptions(path: '/auth/test');

void main() {
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late ProfileRepoImp repo;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repo = ProfileRepoImp(mockRemoteDataSource);
  });

  group('ProfileRepoImp.getProfile', () {
    test('returns SuccessResponse with the mapped entity', () async {
      when(
        () => mockRemoteDataSource.getProfile(),
      ).thenAnswer((_) async => testProfileResponse);

      final result = await repo.getProfile();

      expect(result, isA<SuccessResponse<ProfileEntity>>());
      expect(
        (result as SuccessResponse<ProfileEntity>).data,
        testProfileEntity,
      );
      verify(() => mockRemoteDataSource.getProfile()).called(1);
    });

    test('returns ServerFailure when the response carries no user', () async {
      when(
        () => mockRemoteDataSource.getProfile(),
      ).thenAnswer((_) async => testProfileEmptyResponse);

      final result = await repo.getProfile();

      expect(result, isA<ErrorResponse<ProfileEntity>>());
      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<ServerFailure>(),
      );
    });

    test('wraps a network error into a network failure', () async {
      when(() => mockRemoteDataSource.getProfile()).thenThrow(
        DioException.connectionError(
          requestOptions: testOptions(),
          reason: 'offline',
        ),
      );

      final result = await repo.getProfile();

      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<NetworkFailure>(),
      );
    });
  });

  group('ProfileRepoImp.editProfile', () {
    test('converts params to a dto and returns the updated entity', () async {
      when(
        () => mockRemoteDataSource.editProfile(any()),
      ).thenAnswer((_) async => testProfileResponse);

      final result = await repo.editProfile(testProfileParams);

      expect(
        (result as SuccessResponse<ProfileEntity>).data,
        testProfileEntity,
      );
      final sent =
          verify(
                () => mockRemoteDataSource.editProfile(captureAny()),
              ).captured.single
              as ProfileRequestDto;
      expect(sent.firstName, testProfileRequestDto.firstName);
      expect(sent.age, testProfileRequestDto.age);
      expect(sent.weight, testProfileRequestDto.weight);
      expect(sent.goal, testProfileRequestDto.goal);
    });

    test('returns ServerFailure when the response carries no user', () async {
      when(
        () => mockRemoteDataSource.editProfile(any()),
      ).thenAnswer((_) async => testProfileEmptyResponse);

      final result = await repo.editProfile(testProfileParams);

      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<ServerFailure>(),
      );
    });

    test('wraps a 401 into an unauthorized failure', () async {
      when(() => mockRemoteDataSource.editProfile(any())).thenThrow(
        DioException.badResponse(
          statusCode: 401,
          requestOptions: testOptions(),
          response: Response(requestOptions: testOptions(), statusCode: 401),
        ),
      );

      final result = await repo.editProfile(testProfileParams);

      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<UnauthorizedFailure>(),
      );
    });
  });

  group('ProfileRepoImp.uploadPhoto', () {
    test('returns the updated entity when the server sends the user', () async {
      when(
        () => mockRemoteDataSource.uploadPhoto(any()),
      ).thenAnswer((_) async => testProfileResponse);

      final result = await repo.uploadPhoto('/tmp/photo.jpg');

      expect(
        (result as SuccessResponse<ProfileEntity>).data,
        testProfileEntity,
      );
      verify(
        () => mockRemoteDataSource.uploadPhoto('/tmp/photo.jpg'),
      ).called(1);
      verifyNever(() => mockRemoteDataSource.getProfile());
    });

    test(
      'refreshes the profile when the upload response omits the user',
      () async {
        when(
          () => mockRemoteDataSource.uploadPhoto(any()),
        ).thenAnswer((_) async => testProfileEmptyResponse);
        when(
          () => mockRemoteDataSource.getProfile(),
        ).thenAnswer((_) async => testProfileResponse);

        final result = await repo.uploadPhoto('/tmp/photo.jpg');

        expect(
          (result as SuccessResponse<ProfileEntity>).data,
          testProfileEntity,
        );
        verify(() => mockRemoteDataSource.getProfile()).called(1);
      },
    );

    test(
      'returns ServerFailure when neither response carries a user',
      () async {
        when(
          () => mockRemoteDataSource.uploadPhoto(any()),
        ).thenAnswer((_) async => testProfileEmptyResponse);
        when(
          () => mockRemoteDataSource.getProfile(),
        ).thenAnswer((_) async => testProfileEmptyResponse);

        final result = await repo.uploadPhoto('/tmp/photo.jpg');

        expect(
          (result as ErrorResponse<ProfileEntity>).failure,
          isA<ServerFailure>(),
        );
      },
    );

    test('propagates the data source size failure', () async {
      when(
        () => mockRemoteDataSource.uploadPhoto(any()),
      ).thenThrow(const PhotoTooLargeFailure());

      final result = await repo.uploadPhoto('/tmp/huge.jpg');

      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<PhotoTooLargeFailure>(),
      );
    });
  });
}
