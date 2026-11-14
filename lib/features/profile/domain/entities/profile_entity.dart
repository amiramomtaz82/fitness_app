import 'package:equatable/equatable.dart';

import '../../../../core/contants/endpoints/endpoints.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final int age;
  final num weight;
  final num height;
  final String activityLevel;
  final String goal;
  final String photo;

  const ProfileEntity({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.gender = '',
    this.age = 0,
    this.weight = 0,
    this.height = 0,
    this.activityLevel = '',
    this.goal = '',
    this.photo = '',
  });

  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    return '$first $last'.trim();
  }

  bool get hasPhoto => photo.trim().isNotEmpty;

  String? get photoUrl =>
      hasPhoto ? Uri.parse(Endpoints.domain).resolve(photo).toString() : null;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    gender,
    age,
    weight,
    height,
    activityLevel,
    goal,
    photo,
  ];
}
