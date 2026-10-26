import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_card.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/contants/app_assets.dart';
import '../../../../../../core/di/di.dart';
import '../../../../../../core/mixin/ui_event_handler_mixin.dart';
import '../../../../../../core/widgets/app_background_scaffold.dart';
import '../../manager/cubit/register_cubit.dart';
import '../../manager/cubit/register_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with UiEventMixin<RegisterView, RegisterState, BaseUiEvent> {
  late final RegisterCubit _cubit;

  @override
  RegisterCubit get cubit => _cubit;

  @override
  void initState() {
    _cubit = getIt<RegisterCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: AppBackgroundScaffold(
        overlayColor: AppColors.black,
        overlayOpacity: 0.1,

        backgroundImage: AppAssets.authProfileBG,

        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 24.w,
            vertical: 16.h,
          ),
          child: Column(
            children: [
              const RegisterHeader(),
              SizedBox(height: 20.h),
              const RegisterCard(),
            ],
          ),
        ),
      ),
    );
  }
}
