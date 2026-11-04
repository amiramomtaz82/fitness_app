import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class NumberPickerSheet extends StatefulWidget {
  final String initialValue;
  final String unit;
  final ValueChanged<num> onSubmit;

  const NumberPickerSheet({
    super.key,
    required this.initialValue,
    required this.unit,
    required this.onSubmit,
  });

  @override
  State<NumberPickerSheet> createState() => _NumberPickerSheetState();
}

class _NumberPickerSheetState extends State<NumberPickerSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  num? get _value => num.tryParse(_controller.text.trim().replaceAll(',', '.'));

  void _submit() {
    final value = _value;
    if (value == null) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: AppTextStyles.white14regular,
                  cursorColor: colors.primary,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide(color: colors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(widget.unit, style: AppTextStyles.white14bold),
            ],
          ),
          SizedBox(height: 20.h),
          FilledButton(
            onPressed: _value == null ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text(LocaleKeys.profile_done.tr()),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
