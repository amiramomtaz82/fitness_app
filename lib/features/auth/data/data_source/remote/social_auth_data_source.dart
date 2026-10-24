import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/social_auth_user.dart';

@lazySingleton
class SocialAuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;


  SocialAuthService({
    required GoogleSignIn googleSignIn,
    required FirebaseAuth firebaseAuth,
  })  : _googleSignIn = googleSignIn,
        _firebaseAuth = firebaseAuth;

  // ==========================================
  // GOOGLE SIGN-IN
  // ==========================================
  Future<SocialAuthUser?> signInWithGoogle() async {
    // 1. Sign out previous session to guarantee account picker shows
    await _googleSignIn.signOut();

    // 2. Open Google Sign-In prompt
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return null;
    }

    // 3. Authenticate with Firebase (NO try-catch! If it fails, let it throw)
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);

    // 4. Parse user profile name
    final fullName = account.displayName?.trim() ?? 'User';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
    final lastName =
    nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Fitness';

    return SocialAuthUser(
      email: account.email.trim().toLowerCase(),
      firstName: firstName,
      lastName: lastName,
      photoUrl: account.photoUrl,
      provider: 'google',
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}