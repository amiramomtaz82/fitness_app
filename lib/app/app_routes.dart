import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_app/app/bottom_bar/bottom_navigation_bar.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/forget_pasword_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view/login_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import 'package:fitness_app/features/chat/presentation/view/screens/smart_coach_screen.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_screen.dart';
import 'package:fitness_app/features/on_bording/views/onboarding_view.dart';
import 'package:fitness_app/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:fitness_app/features/splash/presentation/views/splash_view.dart';
import '../core/di/di.dart';
import '../features/auth/presentation/forget_password/view/forget_password_view.dart';
import '../features/auth/presentation/forget_password/view_model/forget_password_cubit.dart';
import '../features/auth/presentation/login/view/login_view.dart';
import '../features/auth/presentation/login/view_model/login_cubit.dart';
import '../features/auth/presentation/register/manager/cubit/register_cubit.dart';
import '../features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import '../features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import '../features/chat/presentation/view/screens/smart_coach_screen.dart';
import '../features/home/presentation/view/screens/home_screen.dart';
import '../features/home/presentation/view/screens/workouts_screen.dart';
import '../features/on_bording/views/onboarding_view.dart';
import '../features/profile/presentation/view/screens/profile_screen.dart';
import '../features/splash/presentation/views/splash_view.dart';
import 'bottom_bar/bottom_navigation_bar.dart';
import 'routes_names.dart';

import '../features/exercise/presentation/work_out/view/work_out_view.dart';

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

    // Login
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<LoginCubit>(),
        child: const LoginView(),
      ),
    ),

    // Register
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.register,
      builder: (context, state) => const RegisterView(),
    ),

    // Multi-step Registration
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

    // Forgot Password
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPassword,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ForgetPasswordCubit>(),
        child: const ForgetPasswordView(),
      ),
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        // Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Smart Coach
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.smartCoach,
              name: AppRoutes.smartCoach,
              builder: (context, state) => const SmartCoachScreen(),
            ),
          ],
        ),

        // Workouts
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.workouts,
              name: AppRoutes.workouts,
              builder: (context, state) => const WorkOutView(),
            ),
          ],
        ),

        // Profile
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