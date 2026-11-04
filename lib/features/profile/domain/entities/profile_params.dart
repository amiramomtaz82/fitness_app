import 'package:equatable/equatable.dart';
import 'profile_entity.dart';

class ProfileParams extends Equatable {
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final num weight;
  final num height;
  final String activityLevel;
  final String goal;

  const ProfileParams({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.goal,
  });

  factory ProfileParams.fromEntity(ProfileEntity entity) {
    return ProfileParams(
      firstName: entity.firstName,
      lastName: entity.lastName,
      gender: entity.gender,
      age: entity.age,
      weight: entity.weight,
      height: entity.height,
      activityLevel: entity.activityLevel,
      goal: entity.goal,
    );
  }

  ProfileParams copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    num? weight,
    num? height,
    String? activityLevel,
    String? goal,
  }) {
    return ProfileParams(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    gender,
    age,
    weight,
    height,
    activityLevel,
    goal,
  ];
}
