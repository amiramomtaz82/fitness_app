import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/context.extension.dart';
import '../theme/text_styles.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const AppTextFormField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: AppTextStyles.white14regular,
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.white14regular.copyWith(
          color: colors.grey,
          fontSize: 14.sp,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
        prefixIcon: _FieldIcon(asset: prefixIcon),
        suffixIcon: suffix,
        border: _border(colors.border),
        enabledBorder: _border(colors.border),
        focusedBorder: _border(colors.primary),
        errorBorder: _border(colors.error),
        focusedErrorBorder: _border(colors.error),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.r),
      borderSide: BorderSide(color: color),
    );
  }
}

class _FieldIcon extends StatelessWidget {
  final String asset;

  const _FieldIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 8.w),
      child: Image.asset(
        asset,
        width: 20.w,
        height: 20.w,
        color: context.colors.white,
      ),
    );
  }
}
