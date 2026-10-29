sealed class FoodBrowseIntent {
  const FoodBrowseIntent();
}

class LoadFoodBrowseIntent extends FoodBrowseIntent {
  const LoadFoodBrowseIntent();
}

class SelectFoodCategoryIntent extends FoodBrowseIntent {
  final String category;

  const SelectFoodCategoryIntent(this.category);
}
