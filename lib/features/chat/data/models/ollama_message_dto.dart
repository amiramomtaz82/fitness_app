import 'package:json_annotation/json_annotation.dart';

part 'ollama_message_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class OllamaFunctionCallDto {
  final String? name;
  final Map<String, dynamic>? arguments;

  const OllamaFunctionCallDto({this.name, this.arguments});

  factory OllamaFunctionCallDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaFunctionCallDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaFunctionCallDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OllamaToolCallDto {
  final OllamaFunctionCallDto? function;

  const OllamaToolCallDto({this.function});

  factory OllamaToolCallDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaToolCallDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaToolCallDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OllamaMessageDto {
  final String role;
  final String content;
  @JsonKey(name: 'tool_calls')
  final List<OllamaToolCallDto>? toolCalls;

  const OllamaMessageDto({
    required this.role,
    this.content = '',
    this.toolCalls,
  });

  factory OllamaMessageDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaMessageDtoToJson(this);
}
