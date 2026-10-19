/// Predefined message types emitted by Cubits
enum CubitMessageType {
  // Auth
  loginSuccess,
  registerSuccess,
  otpSent,
  passwordChanged,
  logoutSuccess,

  // Profile / Setup
  profileUpdated,
  planCreated,

  // General
  operationSuccess,
  changesSaved,
}

/// Represents user-facing messages emitted by Cubits
class CubitMessage {
  final CubitMessageType? type;
  final String? customMessage;
  final bool isError;

  const CubitMessage.success(this.type)
      : customMessage = null,
        isError = false;

  const CubitMessage.custom(this.customMessage, {this.isError = false})
      : type = null;
}
