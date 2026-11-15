sealed class HomeIntent {
  const HomeIntent();
}

class InitHomeIntent extends HomeIntent {
  const InitHomeIntent();
}

class SelectMuscleGroupIntent extends HomeIntent {
  final int index;

  const SelectMuscleGroupIntent(this.index);
}

class OpenMealCategoryIntent extends HomeIntent {
  final String categoryId;

  const OpenMealCategoryIntent(this.categoryId);
}

class SeeAllMealCategoriesIntent extends HomeIntent {
  const SeeAllMealCategoriesIntent();
}
