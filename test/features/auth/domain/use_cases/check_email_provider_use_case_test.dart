import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/email_provider_status.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:fitness_app/features/auth/domain/use_cases/check_email_provider_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'check_email_provider_use_case_test.mocks.dart';

@GenerateMocks([AuthRepo])
void main() {
  late MockAuthRepo repo;
  late CheckEmailProviderUseCase useCase;

  setUp(() {
    provideDummy<BaseResponse<EmailProviderStatus>>(
      const SuccessResponse<EmailProviderStatus>(
        EmailProviderStatus.notFound,
      ),
    );
    repo = MockAuthRepo();
    useCase = CheckEmailProviderUseCase(repo);
  });

  test('delegates the email to AuthRepo.checkEmailProvider', () async {
    const result = EmailProviderStatus.registeredWithGoogle;
    when(repo.checkEmailProvider('a@b.com')).thenAnswer(
      (_) async => const SuccessResponse<EmailProviderStatus>(result),
    );

    final response = await useCase('a@b.com');

    expect(response, isA<SuccessResponse<EmailProviderStatus>>());
    expect((response as SuccessResponse<EmailProviderStatus>).data,
        same(result));
    verify(repo.checkEmailProvider('a@b.com')).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('passes the failure response through unchanged', () async {
    final response = ErrorResponse<EmailProviderStatus>(errMessage: 'boom');
    when(repo.checkEmailProvider('a@b.com')).thenAnswer((_) async => response);

    final actual = await useCase('a@b.com');

    expect(actual, same(response));
    verify(repo.checkEmailProvider('a@b.com')).called(1);
    verifyNoMoreInteractions(repo);
  });
}
