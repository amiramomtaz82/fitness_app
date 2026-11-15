import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_user_dto.g.dart';

@JsonSerializable()
class ProfileUserDto {
  @JsonKey(name: '_id')
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final int? age;
  final num? weight;
  final num? height;
  final String? activityLevel;
  final String? goal;
  final String? photo;

  const ProfileUserDto({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.activityLevel,
    this.goal,
    this.photo,
  });

  factory ProfileUserDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileUserDtoFromJson(json);

  ProfileEntity toEntity() => ProfileEntity(
    id: id ?? '',
    firstName: firstName ?? '',
    lastName: lastName ?? '',
    email: email ?? '',
    gender: gender ?? '',
    age: age ?? 0,
    weight: weight ?? 0,
    height: height ?? 0,
    activityLevel: activityLevel ?? '',
    goal: goal ?? '',
    photo: photo ?? '',
  );
}
