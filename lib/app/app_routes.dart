import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/di.dart';
import '../features/auth/presentation/forget_password/view/forget_password_view.dart';
import '../features/auth/presentation/forget_password/view_model/forget_password_cubit.dart';
import '../features/auth/presentation/login/view/login_view.dart';
import '../features/auth/presentation/register/view/register_view.dart';
import '../features/home/presentation/view/home_view.dart';
import 'routes_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.forgotPassword,
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
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPassword,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<ForgetPasswordCubit>(),
        child: const ForgetPasswordView(),
      ),
    ),
  ],
);
