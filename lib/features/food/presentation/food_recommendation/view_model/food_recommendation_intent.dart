sealed class FoodRecommendationIntent {
  const FoodRecommendationIntent();
}

class LoadFoodRecommendationIntent extends FoodRecommendationIntent {
  const LoadFoodRecommendationIntent();
}

class SelectCategoryIntent extends FoodRecommendationIntent {
  final int index;

  const SelectCategoryIntent(this.index);
}

class RetryIntent extends FoodRecommendationIntent {
  const RetryIntent();
}
