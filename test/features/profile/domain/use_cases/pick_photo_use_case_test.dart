import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/use_cases/pick_photo_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

void main() {
  late MockPhotoPicker mockPhotoPicker;
  late PickPhotoUseCase useCase;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockPhotoPicker = MockPhotoPicker();
    useCase = PickPhotoUseCase(mockPhotoPicker);
  });

  void stubPick(Future<String?> Function() answer) {
    when(() => mockPhotoPicker.pickPhoto()).thenAnswer((_) => answer());
  }

  group('PickPhotoUseCase', () {
    test('wraps the picked photo path in a success response', () async {
      stubPick(() async => '/tmp/a.jpg');

      final result = await useCase();

      expect(result, isA<SuccessResponse<String?>>());
      expect((result as SuccessResponse<String?>).data, '/tmp/a.jpg');
      verify(() => mockPhotoPicker.pickPhoto()).called(1);
      verifyNoMoreInteractions(mockPhotoPicker);
    });

    test('passes the cancellation signal through as a null path', () async {
      stubPick(() async => null);

      final result = await useCase();

      expect(result, isA<SuccessResponse<String?>>());
      expect((result as SuccessResponse<String?>).data, isNull);
    });

    test('maps a picker error to a failure response', () async {
      stubPick(() => throw Exception('gallery unavailable'));

      final result = await useCase();

      expect(result, isA<ErrorResponse<String?>>());
      expect((result as ErrorResponse<String?>).failure, isA<UnknownFailure>());
    });
  });
}
