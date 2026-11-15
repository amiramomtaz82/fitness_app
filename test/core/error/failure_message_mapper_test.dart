import 'package:fitness_app/core/error/failure_message_mapper.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailureMessageMapper —', () {
    test('returns the server message when there is one', () {
      expect(
        const ServerFailure(serverMessage: 'Meals failed').toMessage(),
        'Meals failed',
      );
    });

    test('ignores an empty server message', () {
      expect(
        const NetworkFailure(serverMessage: '').toMessage(),
        LocaleKeys.errors_no_internet_connection,
      );
    });

    test('maps each failure type to its localized key', () {
      expect(
        const NetworkFailure().toMessage(),
        LocaleKeys.errors_no_internet_connection,
      );
      expect(
        const UnauthorizedFailure().toMessage(),
        LocaleKeys.errors_session_expired,
      );
      expect(
        const ForbiddenFailure().toMessage(),
        LocaleKeys.errors_no_permission,
      );
      expect(
        const NotFoundFailure().toMessage(),
        LocaleKeys.errors_data_not_found,
      );
      expect(
        const ValidationFailure().toMessage(),
        LocaleKeys.errors_invalid_fields,
      );
      expect(
        const ServerFailure().toMessage(),
        LocaleKeys.errors_internal_server_error,
      );
      expect(
        const UnknownFailure().toMessage(),
        LocaleKeys.errors_something_went_wrong,
      );
    });
  });
}
