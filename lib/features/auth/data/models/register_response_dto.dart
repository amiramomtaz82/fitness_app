import 'package:json_annotation/json_annotation.dart';
import 'user_dto.dart';

part 'register_response_dto.g.dart';

@JsonSerializable()
class RegisterResponseDto {
  final String? message;
  final UserDto? user;
  final String? token;

  const RegisterResponseDto({this.message, this.user, this.token});

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseDtoToJson(this);
}
