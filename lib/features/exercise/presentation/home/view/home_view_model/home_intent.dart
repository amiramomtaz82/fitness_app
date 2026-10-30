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
