import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../features/food/data/api/food_api_client.dart';
import '../contants/endpoints/endpoints.dart';

@module
abstract class FoodDiModule {
  /// TheMealDB is a third-party API, so it gets its own Dio without the
  /// auth interceptor: the user's token must never be sent to it.
  @lazySingleton
  FoodApiClient foodApiClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.mealDbBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    dio.interceptors.add(PrettyDioLogger(responseBody: false));
    return FoodApiClient(dio);
  }
}
