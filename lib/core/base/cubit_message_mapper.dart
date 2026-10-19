import 'package:easy_localization/easy_localization.dart';
import '../../generated/locale_keys.g.dart';
import 'cubit_message.dart';
import 'ui_events.dart';

class CubitMessageMapper {
  /// 1. Maps a CubitMessageType to a localized user-facing message string
  static String mapToMessage(CubitMessageType type) {
    return switch (type) {
      CubitMessageType.loginSuccess => LocaleKeys.auth_welcome_back.tr(),
      CubitMessageType.registerSuccess => LocaleKeys.auth_done.tr(),
      CubitMessageType.otpSent => LocaleKeys.auth_sent_otp.tr(),
      CubitMessageType.passwordChanged => LocaleKeys.auth_done.tr(),
      CubitMessageType.logoutSuccess => LocaleKeys.common_done.tr(),
      CubitMessageType.profileUpdated => LocaleKeys.common_save.tr(),
      CubitMessageType.planCreated => LocaleKeys.common_done.tr(),
      CubitMessageType.operationSuccess => LocaleKeys.common_done.tr(),
      CubitMessageType.changesSaved => LocaleKeys.common_save.tr(),
    };
  }

  /// 2. Maps a CubitMessage to a BaseUiEvent (e.g. ShowSnackBarEvent)
  static BaseUiEvent mapToUiEvent(CubitMessage message) {
    final String text =
        message.customMessage ??
        (message.type != null ? mapToMessage(message.type!) : '');

    return ShowSnackBarEvent(message: text, isError: message.isError);
  }

  /// 3. Helper to directly create a success event from a CubitMessageType
  static BaseUiEvent successEvent(CubitMessageType type) {
    return ShowSnackBarEvent(message: mapToMessage(type), isError: false);
  }
}
