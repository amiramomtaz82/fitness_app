import 'package:easy_localization/easy_localization.dart';

import '../../generated/locale_keys.g.dart';
import 'failures.dart';

extension FailureMessageMapper on Failure {
  String toMessage() {
    final message = serverMessage;
    if (message != null && message.isNotEmpty) return message;

    return switch (this) {
      NetworkFailure() => LocaleKeys.errors_no_internet_connection.tr(),
      UnauthorizedFailure() => LocaleKeys.errors_session_expired.tr(),
      ForbiddenFailure() => LocaleKeys.errors_no_permission.tr(),
      NotFoundFailure() => LocaleKeys.errors_data_not_found.tr(),
      ValidationFailure() => LocaleKeys.errors_invalid_fields.tr(),
      PhotoTooLargeFailure() => LocaleKeys.errors_photo_too_large.tr(),
      ServerFailure() => LocaleKeys.errors_internal_server_error.tr(),
      SocialAccountFailure(:final provider) => switch (provider) {
        SocialProvider.google => LocaleKeys.auth_forgot_password_google.tr(),
        SocialProvider.facebook =>
          LocaleKeys.auth_forgot_password_facebook.tr(),
      },
      ChatTokenLimitFailure() => LocaleKeys.chat_token_limit_reached.tr(),
      UnknownFailure() => LocaleKeys.errors_something_went_wrong.tr(),
    };
  }
}
