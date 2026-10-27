import 'package:fitness_app/features/exercise/data/data_source/exercise_remote_data_source.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repo/exercise_repo.dart';

@Injectable(as: ExerciseRepo)
class ExerciseRepoImp implements ExerciseRepo {
  final ExerciseRemoteDataSource _exerciseRemoteDataSource;

  const ExerciseRepoImp(this._exerciseRemoteDataSource);

}