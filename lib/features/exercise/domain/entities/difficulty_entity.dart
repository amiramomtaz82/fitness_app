import 'package:equatable/equatable.dart';

class DifficultyLevelEntity extends Equatable {
  final String id;
  final String name;

  const DifficultyLevelEntity({required this.id, required this.name});

  @override
  List<Object> get props => [name, id];
}
