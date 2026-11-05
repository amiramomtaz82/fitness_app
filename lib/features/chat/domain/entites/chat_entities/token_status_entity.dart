import 'package:equatable/equatable.dart';

enum TokenLimitLevel { normal, warning7k, locked8k }

class TokenStatusEntity extends Equatable {
  final int totalTokens;
  final TokenLimitLevel level;

  const TokenStatusEntity({required this.totalTokens, required this.level});

  bool get isWarning => level == TokenLimitLevel.warning7k;
  bool get isLocked => level == TokenLimitLevel.locked8k;

  @override
  List<Object?> get props => [totalTokens, level];
}
