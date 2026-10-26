import 'package:json_annotation/json_annotation.dart';

part 'auth_action_response_dto.g.dart';

@JsonSerializable()
class AuthActionResponseDto {
  @JsonKey(name: 'success')
  final bool? success;

  @JsonKey(name: 'message')
  final String? message;

  const AuthActionResponseDto({this.success, this.message});

  factory AuthActionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthActionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthActionResponseDtoToJson(this);
}
