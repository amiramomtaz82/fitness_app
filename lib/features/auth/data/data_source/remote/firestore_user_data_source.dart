import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../domain/entities/email_provider_status.dart';
import '../../mapper/email_provider_status_mapper.dart';
import '../../models/auth_provider_config_dto.dart';
import '../../models/registered_user_dto.dart';

@lazySingleton
class FirestoreUserService {
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'registered_users';
  static const String _configCollection = 'app_config';
  static const String _providersDoc = 'auth_providers';

  FirestoreUserService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<RegisteredUserDto> get _usersRef => _firestore
      .collection(_usersCollection)
      .withConverter<RegisteredUserDto>(
        fromFirestore: (snapshot, _) =>
            RegisteredUserDto.fromJson(snapshot.data() ?? {}),
        toFirestore: (user, _) => user.toJson(),
      );

  DocumentReference<AuthProviderConfigDto> get _providerConfigRef => _firestore
      .collection(_configCollection)
      .doc(_providersDoc)
      .withConverter<AuthProviderConfigDto>(
        fromFirestore: (snapshot, _) =>
            AuthProviderConfigDto.fromJson(snapshot.data() ?? {}),
        toFirestore: (config, _) => config.toJson(),
      );

  Future<void> saveUser(RegisteredUserDto user) async {
    final sanitizedEmail = user.email.trim().toLowerCase();
    await _usersRef.doc(sanitizedEmail).set(user, SetOptions(merge: true));
  }

  Future<EmailProviderStatus> checkEmailProvider(String email) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final docSnapshot = await _usersRef.doc(sanitizedEmail).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return EmailProviderStatus.notFound;
    }

    // Type-safe property access directly on RegisteredUserDto!
    final userDto = docSnapshot.data()!;
    return userDto.provider.toEmailProviderStatus();
  }

  Future<String> getProviderPassword(String provider) async {
    final configDoc = await _providerConfigRef.get();

    if (!configDoc.exists || configDoc.data() == null) {
      throw const ServerException(
        message: 'Auth provider configuration does not exist in Firestore',
      );
    }

    final password = configDoc.data()!.getPassword(provider);
    if (password == null || password.isEmpty) {
      throw ServerException(
        message: 'Password for provider "$provider" is not configured',
      );
    }

    return password;
  }
}
