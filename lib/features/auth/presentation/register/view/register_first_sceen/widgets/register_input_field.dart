import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/text_styles.dart';

class RegisterInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String iconAsset;
  final bool isPassword;
  final bool isObscured;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const RegisterInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.iconAsset,
    this.isPassword = false,
    this.isObscured = false,
    this.onToggleObscure,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && isObscured,
      validator: validator,
      keyboardType: keyboardType,
      style: AppTextStyles.white14regular,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.grey12regular,
        filled: true,
        fillColor: AppColors.inputFill.withValues(alpha: 0.6),
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.all(12.r),
          child: Image.asset(
            iconAsset,
            width: 20.r,
            height: 20.r,
            color: AppColors.hintGrey,
          ),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.hintGrey,
                  size: 20.r,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: AppColors.darkGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: AppColors.darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
      ),
    );
  }
}
