import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/food/data/api/food_api_client.dart';
import 'dio_module.dart';

@module
abstract class FoodDiModule {
  @lazySingleton
  FoodApiClient foodApiClient(@Named(DioNames.mealDb) Dio dio) =>
      FoodApiClient(dio);
}
