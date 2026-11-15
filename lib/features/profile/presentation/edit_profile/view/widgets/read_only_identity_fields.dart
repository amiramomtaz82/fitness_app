import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/widgets/app_text_form_field.dart';

class ReadOnlyIdentityFields extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String gender;

  const ReadOnlyIdentityFields({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFormField(
          key: const Key('firstNameField'),
          hintText: firstName,
          prefixIcon: AppAssets.person,
          enabled: false,
        ),
        SizedBox(height: 16.h),
        AppTextFormField(
          key: const Key('lastNameField'),
          hintText: lastName,
          prefixIcon: AppAssets.person,
          enabled: false,
        ),
        SizedBox(height: 16.h),
        AppTextFormField(
          key: const Key('emailField'),
          hintText: email,
          prefixIcon: AppAssets.mail,
          enabled: false,
        ),
        SizedBox(height: 16.h),
        AppTextFormField(
          key: const Key('genderField'),
          hintText: gender,
          prefixIcon: AppAssets.person,
          enabled: false,
        ),
      ],
    );
  }
}
