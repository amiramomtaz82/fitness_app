import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/local/locale_cubit.dart';
import 'package:fitness_app/core/local/locale_intent.dart';
import 'package:fitness_app/core/mixin/ui_event_handler_mixin.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/core/widgets/app_title_bar.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import '../../view_model/profile_cubit.dart';
import '../../view_model/profile_intent.dart';
import '../../view_model/profile_state.dart';
import '../../view_model/show_logout_dialog_event.dart';
import '../../view_model/toggle_locale_event.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with UiEventMixin<ProfileScreen, ProfileState, BaseUiEvent> {
  @override
  ProfileCubit get cubit => context.read<ProfileCubit>();

  @override
  void handleCustomEvents(BaseUiEvent event) {
    if (event is ToggleLocaleEvent) {
      context.read<LocaleCubit>().doIntent(const ToggleLanguageIntent());
    } else if (event is ShowLogoutConfirmationEvent) {
      _showLogoutDialog(context);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => LogoutConfirmationDialog(
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          cubit.doIntent(const ConfirmLogoutIntent());
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      overlayOpacity: 0.5,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTitleBar(titleKey: LocaleKeys.profile_profile),
            SizedBox(height: 24.h),
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (previous, current) =>
              previous.profile != current.profile ||
                  previous.pendingPhotoPath != current.pendingPhotoPath,
              builder: (context, state) => ProfileHeader(
                profile: state.profile,
                pickedPhotoPath: state.pendingPhotoPath,
                onPickPhoto: () => cubit.doIntent(const PickPhotoIntent()),
              ),
            ),
            SizedBox(height: 28.h),
            const ProfileMenuList(),
          ],
        ),
      ),
    );
  }
}