import 'package:json_annotation/json_annotation.dart';
import '../../../../core/contants/ollama_constants.dart';

import 'ollama_message_dto.dart';

part 'ollama_chat_request_dto.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class OllamaChatRequestDto {
  final String model;
  final List<OllamaMessageDto> messages;
  final List<Map<String, dynamic>>? tools;
  final Map<String, dynamic>? format;
  final bool? stream;
  final bool? think;
  final Map<String, dynamic>? options;

  const OllamaChatRequestDto({
    this.model = OllamaConstants.defaultModel, // ✅ Centralized constant
    required this.messages,
    this.tools,
    this.format,
    this.stream = OllamaConstants.defaultStream,
    this.think = OllamaConstants.defaultThink,
    this.options = OllamaConstants.defaultOptions, // ✅ Centralized constant
  });

  factory OllamaChatRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OllamaChatRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaChatRequestDtoToJson(this);
}