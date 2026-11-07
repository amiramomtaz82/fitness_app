import 'package:json_annotation/json_annotation.dart';

part 'ollama_generate_response_dto.g.dart';

@JsonSerializable()
class OllamaGenerateResponseDto {
  final String? model;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? response;
  final bool? done;
  @JsonKey(name: 'prompt_eval_count')
  final int? promptEvalCount;
  @JsonKey(name: 'eval_count')
  final int? evalCount;

  const OllamaGenerateResponseDto({
    this.model,
    this.createdAt,
    this.response,
    this.done,
    this.promptEvalCount,
    this.evalCount,
  });

  factory OllamaGenerateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaGenerateResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaGenerateResponseDtoToJson(this);
}