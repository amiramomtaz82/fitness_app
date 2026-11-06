import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/mixin/ui_event_handler_mixin.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/core/widgets/app_bottom_sheet.dart';
import 'package:fitness_app/core/widgets/app_title_bar.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_params.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_header.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_intent.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import '../models/picker_option.dart';
import '../widgets/edit_save_button.dart';
import '../widgets/editable_profile_fields.dart';
import '../widgets/number_picker_sheet.dart';
import '../widgets/option_picker_sheet.dart';
import '../widgets/read_only_identity_fields.dart';
import '../../view_model/edit_profile_cubit.dart';
import '../../view_model/edit_profile_field.dart';
import '../../view_model/edit_profile_intent.dart';
import '../../view_model/edit_profile_saved_event.dart';
import '../../view_model/edit_profile_state.dart';
import '../../view_model/edit_profile_value_formatter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with UiEventMixin<EditProfileScreen, EditProfileState, BaseUiEvent> {
  @override
  EditProfileCubit get cubit => context.read<EditProfileCubit>();

  ProfileCubit get _profileCubit => context.read<ProfileCubit>();

  @override
  void initState() {
    super.initState();
    _profileCubit.doIntent(const LoadProfileIntent());
    final profile = _profileCubit.state.profile;
    if (profile != null) {
      cubit.doIntent(StartEditProfileIntent(profile));
    }
  }

  @override
  void handleCustomEvents(BaseUiEvent event) {
    if (event case ProfileSavedEvent(:final profile)) {
      _profileCubit.doIntent(SyncProfileIntent(profile));
    }
  }

  void _openSheet(EditProfileField field, ProfileParams draft) {
    AppBottomSheet.show(
      context: context,
      title: field.sheetTitleKey.tr(),
      child: field.isNumeric
          ? NumberPickerSheet(
              initialValue: EditProfileValueFormatter.number(field, draft),
              unit: field.unitKey.tr(),
              min: field.min,
              max: field.max,
              onSubmit: (value) {
                cubit.doIntent(UpdateNumberFieldIntent(field, value));
                Navigator.pop(context);
              },
            )
          : OptionPickerSheet(
              options: EditProfileValueFormatter.options(field),
              selectedValue: EditProfileValueFormatter.optionValue(
                field,
                draft,
              ),
              onSelected: (PickerOption option) {
                cubit.doIntent(SelectOptionIntent(field, option.value));
                Navigator.pop(context);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      overlayOpacity: 0.5,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: BlocBuilder<EditProfileCubit, EditProfileState>(
          builder: (context, state) {
            final draft = state.draft;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppTitleBar(
                  titleKey: LocaleKeys.profile_edit_profile,
                  showBackButton: true,
                ),
                SizedBox(height: 24.h),
                BlocListener<ProfileCubit, ProfileState>(
                  listenWhen: (previous, current) =>
                      current.profile != null && state.saved == null,
                  listener: (context, profileState) {
                    final profile = profileState.profile;
                    if (profile != null) {
                      cubit.doIntent(StartEditProfileIntent(profile));
                    }
                  },
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    buildWhen: (previous, current) =>
                        previous.profile != current.profile ||
                        previous.pendingPhotoPath != current.pendingPhotoPath,
                    builder: (context, profileState) => ProfileHeader(
                      profile: profileState.profile,
                      pickedPhotoPath: profileState.pendingPhotoPath,
                      onPickPhoto: () =>
                          _profileCubit.doIntent(const PickPhotoIntent()),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                ReadOnlyIdentityFields(
                  firstName: state.firstName,
                  lastName: state.lastName,
                  email: state.email,
                  gender: EditProfileValueFormatter.genderLabel(state.gender),
                ),
                if (draft != null) ...[
                  SizedBox(height: 24.h),
                  EditableProfileFields(
                    draft: draft,
                    onFieldTap: (field) => _openSheet(field, draft),
                  ),
                ],
                EditSaveButton(
                  isLoading: state.isSaving,
                  enabled: state.hasChanges,
                  onPressed: () => cubit.doIntent(const SaveProfileIntent()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
