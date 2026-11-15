import 'package:equatable/equatable.dart';

class MealSummaryEntity extends Equatable {
  final String id;
  final String name;
  final String thumbnail;

  const MealSummaryEntity({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  @override
  List<Object?> get props => [id, name, thumbnail];
}
