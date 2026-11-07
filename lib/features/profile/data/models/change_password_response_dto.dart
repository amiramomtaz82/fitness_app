import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/change_password_entity.dart';

part 'change_password_response_dto.g.dart';

@JsonSerializable()
class ChangePasswordResponseDto {
  final String message;
  final String token;

  const ChangePasswordResponseDto({required this.message, required this.token});

  factory ChangePasswordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordResponseDtoFromJson(json);

  ChangePasswordEntity toEntity() {
    return ChangePasswordEntity(message: message, token: token);
  }
}

