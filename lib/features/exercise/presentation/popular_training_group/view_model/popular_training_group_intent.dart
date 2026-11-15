import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';

sealed class PopularTrainingGroupIntent {
  const PopularTrainingGroupIntent();
}

final class InitPopularTrainingGroupIntent extends PopularTrainingGroupIntent {
  final PopularTrainingEntity training;

  const InitPopularTrainingGroupIntent(this.training);
}

final class RetryPopularTrainingGroupIntent extends PopularTrainingGroupIntent {
  const RetryPopularTrainingGroupIntent();
}
