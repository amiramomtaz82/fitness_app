import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/social_auth_user.dart';

@lazySingleton
class SocialAuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;
  final FacebookAuth _facebookAuth;

  // Constructor with optional dependencies for 100% testability
  // Defaults to production platform SDK singletons
  SocialAuthService({
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
    FacebookAuth? facebookAuth,
  })  : _googleSignIn =
      googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

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
      final lastName =
      nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Fitness';

      return SocialAuthUser(
        email: account.email.trim().toLowerCase(),
        firstName: firstName,
        lastName: lastName,
        photoUrl: account.photoUrl,
        provider: 'google',
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  // ==========================================
  // FACEBOOK SIGN-IN
  // ==========================================
  Future<SocialAuthUser?> signInWithFacebook() async {
    try {
      // 1. Force account selection sheet by clearing previous session
      await _facebookAuth.logOut();

      // 2. Request Facebook Login Dialog with permissions
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success || result.accessToken == null) {
        return null; // User cancelled or failed
      }

      // 3. Register user in Firebase Authentication
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );
      await _firebaseAuth.signInWithCredential(credential);

      // 4. Retrieve user profile information from Graph API
      final Map<String, dynamic> userData = await _facebookAuth.getUserData(
        fields: 'name,email,picture.width(200)',
      );

      final email = (userData['email'] as String?)?.trim().toLowerCase();
      if (email == null || email.isEmpty) {
        debugPrint('Facebook account has no email attached');
        return null;
      }

      final fullName = (userData['name'] as String?)?.trim() ?? 'Facebook User';
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName =
      nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Fitness';
      final pictureUrl = userData['picture']?['data']?['url'] as String?;

      return SocialAuthUser(
        email: email,
        firstName: firstName,
        lastName: lastName,
        photoUrl: pictureUrl,
        provider: 'facebook',
      );
    } catch (e) {
      debugPrint('Facebook Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
    await _firebaseAuth.signOut();
  }
}