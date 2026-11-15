import 'package:json_annotation/json_annotation.dart';
import 'profile_user_dto.dart';

part 'profile_response_dto.g.dart';

@JsonSerializable()
class ProfileResponseDto {
  final ProfileUserDto? user;

  const ProfileResponseDto({this.user});

  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseDtoFromJson(json);
}
