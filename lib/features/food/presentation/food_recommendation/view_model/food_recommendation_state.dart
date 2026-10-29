import 'package:equatable/equatable.dart';

import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/meal_category_entity.dart';
import '../../../domain/entities/meal_summary_entity.dart';

class FoodRecommendationState extends Equatable {
  final Resource<List<MealCategoryEntity>> categories;
  final int selectedIndex;
  final Resource<List<MealSummaryEntity>> meals;

  const FoodRecommendationState({
    this.categories = const Resource.initial(),
    this.selectedIndex = 0,
    this.meals = const Resource.initial(),
  });

  MealCategoryEntity? get selectedCategory {
    final list = categories.data ?? const [];
    return selectedIndex < list.length ? list[selectedIndex] : null;
  }

  FoodRecommendationState copyWith({
    Resource<List<MealCategoryEntity>>? categories,
    int? selectedIndex,
    Resource<List<MealSummaryEntity>>? meals,
  }) {
    return FoodRecommendationState(
      categories: categories ?? this.categories,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      meals: meals ?? this.meals,
    );
  }

  @override
  List<Object?> get props => [categories, selectedIndex, meals];
}
