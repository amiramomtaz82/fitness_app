import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/social_auth_user.dart';

@lazySingleton
class SocialAuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  // Constructor with optional dependencies for 100% testability
  // Defaults to production platform SDK singletons
  SocialAuthService({GoogleSignIn? googleSignIn, FirebaseAuth? firebaseAuth})
    : _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']),
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ==========================================
  // GOOGLE SIGN-IN
  // ==========================================
  Future<SocialAuthUser?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);

      final fullName = account.displayName?.trim() ?? 'User';
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : 'Fitness';

      return SocialAuthUser(
        email: account.email.trim().toLowerCase(),
        firstName: firstName,
        lastName: lastName,
        photoUrl: account.photoUrl,
        provider: 'google',
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
