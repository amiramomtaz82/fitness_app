import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredUserDto {
  final String email;
  final String provider; // 'google', 'facebook', 'email'
  final String firstName;
  final String lastName;
  final DateTime? createdAt;

  const RegisteredUserDto({
    required this.email,
    required this.provider,
    required this.firstName,
    required this.lastName,
    this.createdAt,
  });

  /// Factory constructor to deserialize Firestore DocumentSnapshot data
  factory RegisteredUserDto.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] is Timestamp) {
      parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'] as String);
    }

    return RegisteredUserDto(
      email: (json['email'] as String? ?? '').trim().toLowerCase(),
      provider: json['provider'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  /// Serializes DTO into Firestore JSON map
  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'provider': provider,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
