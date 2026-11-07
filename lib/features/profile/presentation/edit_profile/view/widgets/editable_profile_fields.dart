import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_params.dart';
import '../../view_model/edit_profile_field.dart';
import '../../view_model/edit_profile_value_formatter.dart';
import 'edit_tap_field.dart';

class EditableProfileFields extends StatelessWidget {
  final ProfileParams draft;
  final ValueChanged<EditProfileField> onFieldTap;

  const EditableProfileFields({
    super.key,
    required this.draft,
    required this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in EditProfileField.values) ...[
          EditTapField(
            key: Key('field_${field.name}'),
            labelKey: field.labelKey,
            value: EditProfileValueFormatter.value(field, draft),
            onTap: () => onFieldTap(field),
          ),
          SizedBox(height: 20.h),
        ],
      ],
    );
  }
}
