import 'package:equatable/equatable.dart';

class MealCardEntity extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final double? kcal;
  final double? proteinG;
  final String? thumb;

  const MealCardEntity({
    required this.id,
    required this.name,
    this.nameAr,
    this.kcal,
    this.proteinG,
    this.thumb,
  });

  @override
  List<Object?> get props => [id, name, nameAr, kcal, proteinG, thumb];
}
