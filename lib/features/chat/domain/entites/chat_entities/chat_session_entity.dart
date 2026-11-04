import 'package:equatable/equatable.dart';

class ChatSessionEntity extends Equatable {
  final String id;
  final String title;
  final DateTime updatedAt;
  final int totalTokens;

  const ChatSessionEntity({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.totalTokens,
  });

  @override
  List<Object?> get props => [id, title, updatedAt, totalTokens];
}