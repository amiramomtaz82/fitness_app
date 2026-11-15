import 'package:json_annotation/json_annotation.dart';

part 'change_password_request_dto.g.dart';

@JsonSerializable()
class ChangePasswordRequestDto {
  final String password;
  final String newPassword;

  const ChangePasswordRequestDto({
    required this.password,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => _$ChangePasswordRequestDtoToJson(this);
}
