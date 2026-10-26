import '../../domain/entities/email_provider_status.dart';

extension StringToEmailProviderStatus on String? {
  EmailProviderStatus toEmailProviderStatus() {
    return switch (this?.trim().toLowerCase()) {
      'google' => EmailProviderStatus.registeredWithGoogle,
      'facebook' => EmailProviderStatus.registeredWithFacebook,
      'email' => EmailProviderStatus.registeredWithEmail,
      _ => EmailProviderStatus.notFound,
    };
  }
}

extension EmailProviderStatusExtension on EmailProviderStatus {
  String get providerName => switch (this) {
    EmailProviderStatus.registeredWithGoogle => 'google',
    EmailProviderStatus.registeredWithFacebook => 'facebook',
    EmailProviderStatus.registeredWithEmail => 'email',
    EmailProviderStatus.notFound => '',
  };

  String toProviderString() => providerName;
}
