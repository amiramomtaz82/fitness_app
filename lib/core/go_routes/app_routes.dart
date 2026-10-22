import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forget_password/view/forget_pasword_view.dart';
import '../../features/auth/presentation/login/view/login_view.dart';
import '../../features/auth/presentation/register/manager/cubit/register_cubit.dart';
import '../../features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import '../../features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import '../../features/home/presentation/view/home_view.dart';
import 'routes_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.multiStepRegistration,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.register,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: AppRoutes.multiStepRegistration,
      name: AppRoutes.multiStepRegistration,
      builder: (context, state) => BlocProvider(
        create: (_) => GetIt.instance<RegisterCubit>(),
        child: const MultiStepsRegistrationView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgetPaswordView(),
    ),
  ],
);
