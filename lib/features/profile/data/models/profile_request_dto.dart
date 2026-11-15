import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile_params.dart';

part 'profile_request_dto.g.dart';

@JsonSerializable()
class ProfileRequestDto {
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final num weight;
  final num height;
  final String activityLevel;
  final String goal;

  const ProfileRequestDto({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.goal,
  });

  ProfileRequestDto.fromParams(ProfileParams params)
    : firstName = params.firstName,
      lastName = params.lastName,
      gender = params.gender,
      age = params.age,
      weight = params.weight,
      height = params.height,
      activityLevel = params.activityLevel,
      goal = params.goal;

  Map<String, dynamic> toJson() => _$ProfileRequestDtoToJson(this);
}

extension ProfileParamsToDto on ProfileParams {
  ProfileRequestDto toDto() => ProfileRequestDto.fromParams(this);
}
