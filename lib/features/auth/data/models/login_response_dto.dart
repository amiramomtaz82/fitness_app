import 'package:json_annotation/json_annotation.dart';
import 'user_dto.dart';

part 'login_response_dto.g.dart';

@JsonSerializable()
class LoginResponseDto {
  final String? message;
  final UserDto? user;
  final String? token;

  const LoginResponseDto({this.message, this.user, this.token});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}
