import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

enum EmailProviderStatus {
  notFound,
  registeredWithGoogle,
  registeredWithFacebook,
  registeredWithEmail,
}

@lazySingleton
class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'registered_users';

  /// Saves or updates the registered user in Firestore
  Future<void> saveUser({
    required String email,
    required String provider, // 'google', 'facebook', 'email'
    required String firstName,
    required String lastName,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();
    await _firestore.collection(_collectionName).doc(sanitizedEmail).set({
      'email': sanitizedEmail,
      'provider': provider,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Checks Firestore to determine how the email was registered (for Forgot Password)
  Future<EmailProviderStatus> checkEmailProvider(String email) async {
    try {
      final sanitizedEmail = email.trim().toLowerCase();
      final doc = await _firestore.collection(_collectionName).doc(sanitizedEmail).get();

      if (!doc.exists) {
        return EmailProviderStatus.notFound;
      }

      final provider = doc.data()?['provider'] as String?;
      return switch (provider) {
        'google' => EmailProviderStatus.registeredWithGoogle,
        'facebook' => EmailProviderStatus.registeredWithFacebook,
        _ => EmailProviderStatus.registeredWithEmail,
      };
    } catch (_) {
      return EmailProviderStatus.notFound;
    }
  }

  /// Gets the unified password for a provider (checking Firestore first, fallback to .env)
  Future<String> getProviderPassword(String provider) async {
    try {
      final configDoc = await _firestore.collection('app_config').doc('auth_providers').get();
      if (configDoc.exists) {
        final key = provider == 'google' ? 'google_provider_password' : 'facebook_provider_password';
        final password = configDoc.data()?[key] as String?;
        if (password != null && password.isNotEmpty) {
          return password;
        }
      }
    } catch (_) {
      // Fallback to .env on network/permission error
    }

    if (provider == 'google') {
      return dotenv.env['GOOGLE_PROVIDER_PASSWORD'] ?? 'GoogleAuth@ElevateFitness2026#';
    }
    return dotenv.env['FACEBOOK_PROVIDER_PASSWORD'] ?? 'FacebookAuth@ElevateFitness2026#';
  }
}