sealed class FoodDetailsIntent {
  const FoodDetailsIntent();
}

class LoadMealDetailsIntent extends FoodDetailsIntent {
  final String mealId;

  const LoadMealDetailsIntent(this.mealId);
}
