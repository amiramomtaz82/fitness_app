import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/features/on_bording/views/onboarding_view.dart';
import 'package:fitness_app/features/splash/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/view/home_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
  ],
);
