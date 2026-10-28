abstract final class ForgetPasswordConfig {
  ForgetPasswordConfig._();
  static const int otpLength = 4;
  static const Duration resendCooldown = Duration(seconds: 30);
}
