import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/chat/data/client/chat_api_client.dart';
import '../../features/chat/data/local/exercises_database.dart';
import '../../features/chat/data/local/meals_database.dart';
import 'dio_module.dart';

@module
abstract class ChatDiModule {
  @lazySingleton
  ChatApiClient chatApiClient(@Named(DioNames.ollama) Dio dio) =>
      ChatApiClient(dio);

  @lazySingleton
  ExercisesDatabase get exercisesDatabase => ExercisesDatabase(
    getDatabasesPath: getDatabasesPath,
    openDb: _openReadOnly,
  );

  @lazySingleton
  MealsDatabase get mealsDatabase =>
      MealsDatabase(getDatabasesPath: getDatabasesPath, openDb: _openReadOnly);
}

Future<Database> _openReadOnly(String path, {bool readOnly = true}) =>
    openDatabase(path, readOnly: readOnly);
