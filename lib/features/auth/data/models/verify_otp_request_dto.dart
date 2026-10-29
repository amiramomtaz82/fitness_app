import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_request_dto.g.dart';

@JsonSerializable()
class VerifyOtpRequestDto {
  @JsonKey(name: "resetCode")
  final String resetCode;

  const VerifyOtpRequestDto({required this.resetCode});

  factory VerifyOtpRequestDto.fromJson(Map<String, dynamic> json) {
    return _$VerifyOtpRequestDtoFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$VerifyOtpRequestDtoToJson(this);
  }
}
