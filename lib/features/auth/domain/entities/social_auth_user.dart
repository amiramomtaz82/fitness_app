class SocialAuthUser {
  final String email;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String provider; // 'google' | 'facebook'

  const SocialAuthUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.provider,
  });
}
