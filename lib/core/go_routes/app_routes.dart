import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:go_router/go_router.dart';

import '../../features/on_boarding/on_boarding_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRoutes.onboarding,
      builder: (context, state) => const OnBoardingView(),
    ),

    ]
);