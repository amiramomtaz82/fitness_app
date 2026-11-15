import 'package:equatable/equatable.dart';

enum TokenLimitLevel { normal, warning7k, locked8k }

class TokenStatusEntity extends Equatable {
  static const int warningThreshold = 7000;
  static const int lockThreshold = 8000;

  final int totalTokens;
  final TokenLimitLevel level;

  const TokenStatusEntity({required this.totalTokens, required this.level});

  const TokenStatusEntity.initial()
    : totalTokens = 0,
      level = TokenLimitLevel.normal;

  factory TokenStatusEntity.fromTotalTokens(int totalTokens) {
    final level = totalTokens >= lockThreshold
        ? TokenLimitLevel.locked8k
        : totalTokens >= warningThreshold
        ? TokenLimitLevel.warning7k
        : TokenLimitLevel.normal;
    return TokenStatusEntity(totalTokens: totalTokens, level: level);
  }

  bool get isWarning => level == TokenLimitLevel.warning7k;
  bool get isLocked => level == TokenLimitLevel.locked8k;

  @override
  List<Object?> get props => [totalTokens, level];
}
