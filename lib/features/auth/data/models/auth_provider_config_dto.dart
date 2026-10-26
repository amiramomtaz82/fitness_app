class AuthProviderConfigDto {
  final String? googleProviderPassword;
  final String? facebookProviderPassword;

  const AuthProviderConfigDto({
    this.googleProviderPassword,
    this.facebookProviderPassword,
  });

  factory AuthProviderConfigDto.fromJson(Map<String, dynamic> json) {
    return AuthProviderConfigDto(
      googleProviderPassword: json['google_provider_password'] as String?,
      facebookProviderPassword: json['facebook_provider_password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'google_provider_password': googleProviderPassword,
      'facebook_provider_password': facebookProviderPassword,
    };
  }

  String? getPassword(String provider) {
    if (provider == 'google') return googleProviderPassword;
    if (provider == 'facebook') return facebookProviderPassword;
    return null;
  }
}
