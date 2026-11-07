import 'package:json_annotation/json_annotation.dart';

part 'ollama_generate_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class OllamaGenerateRequestDto {
  final String model;
  final String prompt;
  final String? system;
  final bool? stream;
  final dynamic format; // Can be 'json' String or a Map<String, dynamic> schema
  final Map<String, dynamic>? options;

  const OllamaGenerateRequestDto({
    required this.model,
    required this.prompt,
    this.system,
    this.stream = false,
    this.format,
    this.options,
  });

  factory OllamaGenerateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaGenerateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaGenerateRequestDtoToJson(this);
}