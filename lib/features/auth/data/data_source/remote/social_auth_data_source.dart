import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/email_provider_status.dart';
import '../../../domain/entities/social_auth_user.dart';
import '../../mapper/email_provider_status_mapper.dart';

@lazySingleton
class SocialAuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;
  final FacebookAuth _facebookAuth;

  // Facebook Graph API Constants (No inline magic strings)
  static const List<String> _facebookPermissions = ['email', 'public_profile'];
  static const String _facebookFields = 'name,email,picture.width(200)';

  SocialAuthService(this._googleSignIn, this._firebaseAuth, this._facebookAuth);

  // ==========================================
  // GOOGLE SIGN-IN
  // ==========================================
  Future<SocialAuthUser?> signInWithGoogle() async {
    await _googleSignIn.signOut();

    final account = await _googleSignIn.signIn();
    if (account == null) {
      return null; // Intentional user cancellation
    }

    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);

    // Clean name parsing without fake dummy names
    final fullName = account.displayName?.trim() ?? '';
    final nameParts = fullName.isNotEmpty ? fullName.split(' ') : <String>[];
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return SocialAuthUser(
      email: account.email.trim().toLowerCase(),
      firstName: firstName,
      lastName: lastName,
      photoUrl: account.photoUrl,

      provider: EmailProviderStatus.registeredWithGoogle.providerName,
    );
  }

  // ==========================================
  // FACEBOOK SIGN-IN
  // ==========================================
  Future<SocialAuthUser?> signInWithFacebook() async {
    final LoginResult result = await _facebookAuth.login(
      permissions: _facebookPermissions,
    );

    if (result.status == LoginStatus.cancelled) {
      return null; // Intentional user cancellation
    }

    if (result.status == LoginStatus.failed) {
      throw FirebaseAuthException(
        code: 'facebook-sign-in-failed',
        message: result.message ?? 'Facebook login failed',
      );
    }

    final AccessToken accessToken = result.accessToken!;
    final OAuthCredential credential = FacebookAuthProvider.credential(
      accessToken.tokenString,
    );
    await _firebaseAuth.signInWithCredential(credential);

    final userData = await _facebookAuth.getUserData(fields: _facebookFields);

    // Clean name parsing without fake dummy names
    final fullName = (userData['name'] as String?)?.trim() ?? '';
    final nameParts = fullName.isNotEmpty ? fullName.split(' ') : <String>[];
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final email = (userData['email'] as String? ?? '').trim().toLowerCase();

    return SocialAuthUser(
      email: email,
      firstName: firstName,
      lastName: lastName,
      photoUrl: userData['picture']?['data']?['url'] as String?,

      provider: EmailProviderStatus.registeredWithFacebook.providerName,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
    await _firebaseAuth.signOut();
  }
}
