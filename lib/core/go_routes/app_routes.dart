import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/view/home_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),

    ]
);