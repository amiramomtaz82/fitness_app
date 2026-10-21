import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/app/bottom_bar/items.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingBottomBar extends StatelessWidget {
  final List<BottomItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const FloatingBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      maintainBottomViewPadding: true,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          32.w,
          0,
          32.w,
          MediaQuery.paddingOf(context).bottom > 0 ? 8.h : 16.h,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (index) => Items(
              item: items[index],
              isSelected: selectedIndex == index,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }
}
