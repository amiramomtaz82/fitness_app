import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class NumberPickerSheet extends StatefulWidget {
  final num initialValue;
  final String unit;
  final int min;
  final int max;
  final ValueChanged<num> onSubmit;

  const NumberPickerSheet({
    super.key,
    required this.initialValue,
    required this.unit,
    required this.min,
    required this.max,
    required this.onSubmit,
  });

  @override
  State<NumberPickerSheet> createState() => _NumberPickerSheetState();
}

class _NumberPickerSheetState extends State<NumberPickerSheet> {
  late int _index = _indexOf(widget.initialValue);
  late final PageController _controller = PageController(
    viewportFraction: 0.28,
    initialPage: _index,
  );

  int _indexOf(num value) {
    final rounded = value.round().clamp(widget.min, widget.max);
    return rounded - widget.min;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onSubmit(widget.min + _index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = widget.max - widget.min + 1;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.unit,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.primary, fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 64.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: count,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) {
                    final isSelected = index == _index;
                    return Center(
                      child: Text(
                        '${widget.min + index}',
                        style: TextStyle(
                          fontSize: isSelected ? 28.sp : 18.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? colors.primary : colors.white,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  child: Icon(
                    Icons.arrow_drop_up,
                    color: colors.primary,
                    size: 22.w,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          FilledButton(
            onPressed: _submit,
            child: Text(LocaleKeys.profile_done.tr()),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
