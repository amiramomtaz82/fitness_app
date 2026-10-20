import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/register_parameters.dart';

part 'register_request_dto.g.dart';

@JsonSerializable()
class RegisterRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String rePassword;
  final String gender;
  final num height;
  final num weight;
  final int age;
  final String goal;
  final String activityLevel;

  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.rePassword,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.goal,
    required this.activityLevel,
  });

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);

  factory RegisterRequestDto.fromParameters(RegisterParameters params) =>
      RegisterRequestDto(
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        password: params.password,
        rePassword: params.password,
        gender: params.gender,
        height: params.height,
        weight: params.weight,
        age: params.age,
        goal: params.goal,
        activityLevel: params.activityLevel,
      );

  RegisterParameters toParameters() => RegisterParameters(
    firstName: firstName,
    lastName: lastName,
    email: email,
    password: password,
    gender: gender,
    height: height,
    weight: weight,
    age: age,
    goal: goal,
    activityLevel: activityLevel,
  );
}

extension RegisterParametersToDto on RegisterParameters {
  RegisterRequestDto toDto() => RegisterRequestDto.fromParameters(this);
}
