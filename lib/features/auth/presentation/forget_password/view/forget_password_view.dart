import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_model/forget_password_cubit.dart';
import 'forget_password_screen.dart';

class ForgetPasswordView extends StatelessWidget {
  final ForgetPasswordCubit? cubit;

  const ForgetPasswordView({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    final injected = cubit;
    if (injected != null) {
      return BlocProvider.value(
        value: injected,
        child: const ForgetPasswordScreen(),
      );
    }
    return const ForgetPasswordScreen();
  }
}
