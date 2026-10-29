import 'package:equatable/equatable.dart';

import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/meal_category_entity.dart';
import '../../../domain/entities/meal_summary_entity.dart';

class FoodBrowseState extends Equatable {
  final Resource<List<MealCategoryEntity>> categories;
  final Resource<List<MealSummaryEntity>> meals;
  final String? selectedCategory;
  final int mealsToken;

  const FoodBrowseState({
    this.categories = const Resource.initial(),
    this.meals = const Resource.initial(),
    this.selectedCategory,
    this.mealsToken = 0,
  });

  FoodBrowseState copyWith({
    Resource<List<MealCategoryEntity>>? categories,
    Resource<List<MealSummaryEntity>>? meals,
    String? selectedCategory,
    int? mealsToken,
  }) {
    return FoodBrowseState(
      categories: categories ?? this.categories,
      meals: meals ?? this.meals,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      mealsToken: mealsToken ?? this.mealsToken,
    );
  }

  @override
  List<Object?> get props => [categories, meals, selectedCategory, mealsToken];
}
