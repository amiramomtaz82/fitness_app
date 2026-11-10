import 'package:fitness_app/app/bottom_bar/bottom_navigation_bar.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/forget_password_view.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_cubit.dart';
import 'package:fitness_app/features/auth/presentation/login/view/login_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import 'package:fitness_app/features/chat/presentation/view/screens/smart_coach_screen.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/exercise_view.dart';
import 'package:fitness_app/features/exercise/presentation/exercise_video/view/exercise_video_view.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_screen.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_intent.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/popular_training_exercise_view.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/popular_training_group_view.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view/work_out_view.dart';
import 'package:fitness_app/features/on_bording/views/onboarding_view.dart';
import 'package:fitness_app/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:fitness_app/features/splash/presentation/views/splash_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
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
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ForgetPasswordCubit>(),
        child: const ForgetPasswordView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.exercise,
      name: AppRoutes.exercise,
      builder: (context, state) {
        final muscleId = state.extra as String? ?? '';
        return ExerciseView(muscleId: muscleId);
      },
    ),
    GoRoute(
      path: AppRoutes.popularTrainingGroup,
      name: AppRoutes.popularTrainingGroup,
      builder: (context, state) => PopularTrainingGroupView(
        training: state.extra as PopularTrainingEntity,
      ),
    ),
    GoRoute(
      path: AppRoutes.popularTrainingExercise,
      name: AppRoutes.popularTrainingExercise,
      builder: (context, state) =>
          PopularTrainingExerciseView(exercise: state.extra as ExerciseEntity),
    ),
    GoRoute(
      path: AppRoutes.exerciseVideo,
      name: AppRoutes.exerciseVideo,
      builder: (context, state) =>
          ExerciseVideoView(videoUrl: state.extra as String),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.home,
              builder: (context, state) => BlocProvider(
                create: (context) =>
                    getIt<HomeViewModel>()..doIntent(const InitHomeIntent()),
                child: const HomeScreen(),
              ),
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
              builder: (context, state) => const WorkOutView(),
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
