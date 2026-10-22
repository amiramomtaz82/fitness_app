import 'package:firebase_auth/firebase_auth.dart'; // 👈 1. ADD THIS IMPORT
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/social_auth_user.dart';

@lazySingleton
class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // 👈 2. FIREBASE AUTH INSTANCE

  /// Signs in with Google and registers in Firebase Auth + returns parsed user details
  Future<SocialAuthUser?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // User cancelled
      }

      // 👇 3. ADD THIS BLOCK HERE (Registers user in Firebase Authentication table)
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);

      // Split displayName into firstName and lastName
      final fullName = account.displayName?.trim() ?? 'User';
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Fitness';

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