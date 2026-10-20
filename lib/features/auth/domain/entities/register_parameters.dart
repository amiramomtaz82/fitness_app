import 'package:equatable/equatable.dart';

class RegisterParameters extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String gender;
  final int age;
  final num weight;
  final num height;
  final String goal;
  final String activityLevel;

  const RegisterParameters({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.gender = '',
    this.age = 0,
    this.weight = 0,
    this.height = 0,
    this.goal = '',
    this.activityLevel = '',
  });

  RegisterParameters copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? gender,
    int? age,
    num? weight,
    num? height,
    String? goal,
    String? activityLevel,
  }) {
    return RegisterParameters(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    gender,
    age,
    weight,
    height,
    goal,
    activityLevel,
  ];
}
