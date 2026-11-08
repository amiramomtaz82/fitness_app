sealed class FoodRecommendationIntent {
  const FoodRecommendationIntent();
}

class LoadFoodRecommendationIntent extends FoodRecommendationIntent {
  final String? initialCategoryId;

  const LoadFoodRecommendationIntent({this.initialCategoryId});
}

class SelectCategoryIntent extends FoodRecommendationIntent {
  final int index;

  const SelectCategoryIntent(this.index);
}

class RetryIntent extends FoodRecommendationIntent {
  const RetryIntent();
}

class OpenMealDetailsIntent extends FoodRecommendationIntent {
  final String mealId;

  const OpenMealDetailsIntent(this.mealId);
}
