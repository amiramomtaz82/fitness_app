import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/contants/upload_constraints.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/data/data_source/profile_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

late MockProfileClient mockClient;
late ProfileRemoteDataSourceImp dataSource;
late Directory tempDir;

void main() {
  setUpAll(() {
    registerProfileFallbacks();
    tempDir = Directory.systemTemp.createTempSync('profile_upload_test');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() {
    mockClient = MockProfileClient();
    dataSource = ProfileRemoteDataSourceImp(mockClient);
  });

  group('ProfileRemoteDataSourceImp.getProfile', () {
    test('returns the client response and calls the client once', () async {
      when(
        () => mockClient.getProfile(),
      ).thenAnswer((_) async => testProfileResponse);

      final result = await dataSource.getProfile();

      expect(result, equals(testProfileResponse));

      verify(() => mockClient.getProfile()).called(1);
      verifyNoMoreInteractions(mockClient);
    });

    test('rethrows the client failure', () async {
      final exception = Exception('Network error');

      when(() => mockClient.getProfile()).thenThrow(exception);

      expect(() => dataSource.getProfile(), throwsA(equals(exception)));

      verify(() => mockClient.getProfile()).called(1);
    });
  });

  group('ProfileRemoteDataSourceImp.editProfile', () {
    test(
      'passes the request dto to the client and returns its response',
      () async {
        when(
          () => mockClient.editProfile(any()),
        ).thenAnswer((_) async => testProfileResponse);

        final result = await dataSource.editProfile(testProfileRequestDto);

        expect(result, equals(testProfileResponse));

        verify(() => mockClient.editProfile(testProfileRequestDto)).called(1);
      },
    );

    test('rethrows the client failure', () async {
      final exception = Exception('Server error');

      when(() => mockClient.editProfile(any())).thenThrow(exception);

      expect(
        () => dataSource.editProfile(testProfileRequestDto),
        throwsA(equals(exception)),
      );
    });
  });

  group('ProfileRemoteDataSourceImp.changePassword', () {
    test(
      'passes the request dto to the client and returns its response',
      () async {
        when(
          () => mockClient.changePassword(any()),
        ).thenAnswer((_) async => testChangePasswordResponse);

        final result = await dataSource.changePassword(
          testChangePasswordRequestDto,
        );

        expect(result, equals(testChangePasswordResponse));

        verify(
          () => mockClient.changePassword(testChangePasswordRequestDto),
        ).called(1);

        verifyNoMoreInteractions(mockClient);
      },
    );

    test('rethrows the client failure', () async {
      final exception = Exception('Server error');

      when(() => mockClient.changePassword(any())).thenThrow(exception);

      expect(
        () => dataSource.changePassword(testChangePasswordRequestDto),
        throwsA(equals(exception)),
      );

      verify(
        () => mockClient.changePassword(testChangePasswordRequestDto),
      ).called(1);
    });
  });

  group('ProfileRemoteDataSourceImp.uploadPhoto', () {
    test('uploads the file with its byte length and file name', () async {
      when(
        () => mockClient.uploadPhoto(any()),
      ).thenAnswer((_) async => testProfileResponse);

      final file = File('${tempDir.path}/photo.jpg')..writeAsStringSync('data');

      final result = await dataSource.uploadPhoto(file.path);

      expect(result, equals(testProfileResponse));

      final uploaded =
          verify(() => mockClient.uploadPhoto(captureAny())).captured.single
              as MultipartFile;

      expect(uploaded.length, equals(4));
      expect(uploaded.filename, equals('photo.jpg'));
    });

    test('throws a validation failure when the file does not exist', () async {
      expect(
        () => dataSource.uploadPhoto('${tempDir.path}/missing.jpg'),
        throwsA(isA<ValidationFailure>()),
      );

      verifyNever(() => mockClient.uploadPhoto(any()));
    });

    test('throws a photo size failure when the file is too large', () async {
      final file = File('${tempDir.path}/huge.jpg');

      final raf = file.openSync(mode: FileMode.write);
      raf.truncateSync(UploadConstraints.maxProfilePhotoBytes + 1);
      raf.closeSync();

      await expectLater(
        dataSource.uploadPhoto(file.path),
        throwsA(isA<PhotoTooLargeFailure>()),
      );

      verifyNever(() => mockClient.uploadPhoto(any()));
    });
  });
}
