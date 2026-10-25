import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_app/app/app_routes.dart';
import 'package:fitness_app/app/bottom_bar/bottom_navigation_bar.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/forget_pasword_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view/login_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import 'package:fitness_app/features/chat/presentation/view/screens/smart_coach_screen.dart';
import 'package:fitness_app/features/home/presentation/view/screens/home_screen.dart';
import 'package:fitness_app/features/home/presentation/view/screens/workouts_screen.dart';
import 'package:fitness_app/features/on_bording/views/onboarding_view.dart';
import 'package:fitness_app/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:fitness_app/features/splash/presentation/views/splash_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),

    // Onboarding
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),

    // Auth Routes
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<LoginCubit>(),
        child: const LoginView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.register,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: AppRoutes.multiStepRegistration,
      name: AppRoutes.multiStepRegistration,
      builder: (context, state) {
        final cubit = state.extra is RegisterCubit
            ? state.extra! as RegisterCubit
            : GetIt.instance<RegisterCubit>();
        return BlocProvider.value(
          value: cubit,
          child: const MultiStepsRegistrationView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgetPaswordView(),
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNavigationBar(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.smartCoach,
              name: AppRoutes.smartCoach,
              builder: (context, state) => const SmartCoachScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.workouts,
              name: AppRoutes.workouts,
              builder: (context, state) => const WorkOutsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
