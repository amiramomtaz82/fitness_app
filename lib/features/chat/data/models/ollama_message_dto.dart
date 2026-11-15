import 'package:json_annotation/json_annotation.dart';

part 'ollama_message_dto.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OllamaFunctionCallDto {
  final String? name;
  final Map<String, dynamic>? arguments;

  const OllamaFunctionCallDto({this.name, this.arguments});

  factory OllamaFunctionCallDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaFunctionCallDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaFunctionCallDtoToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OllamaToolCallDto {
  final String? id;
  final OllamaFunctionCallDto? function;

  const OllamaToolCallDto({this.id, this.function});

  factory OllamaToolCallDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaToolCallDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaToolCallDtoToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OllamaMessageDto {
  final String role;
  final String content;
  @JsonKey(name: 'tool_calls')
  final List<OllamaToolCallDto>? toolCalls;
  @JsonKey(name: 'tool_name')
  final String? toolName;
  @JsonKey(name: 'tool_call_id')
  final String? toolCallId;

  const OllamaMessageDto({
    required this.role,
    this.content = '',
    this.toolCalls,
    this.toolName,
    this.toolCallId,
  });

  factory OllamaMessageDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaMessageDtoToJson(this);
}
