import 'package:fitness_app/core/widgets/app_content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable data model for any content item (Workout, Meal, etc.)
class ContentCardItem {
  final String id;
  final String title;
  final String imageUrl;

  const ContentCardItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

class AppContentGridView extends StatelessWidget {
  final List<ContentCardItem> items;
  final ValueChanged<ContentCardItem>? onItemTap;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const AppContentGridView({
    super.key,
    required this.items,
    this.onItemTap,
    this.physics,
    this.shrinkWrap = false,
    this.childAspectRatio = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding:
          padding ??
          EdgeInsetsDirectional.symmetric(horizontal: 16.w, vertical: 12.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return AppContentCard(
          title: item.title,
          imageUrl: item.imageUrl,
          onTap: () => onItemTap?.call(item),
        );
      },
    );
  }
}
