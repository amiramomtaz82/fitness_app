import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TranslucentCardList extends StatelessWidget {
  final List<Widget> children;

  const TranslucentCardList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16.w,
                endIndent: 16.w,
                color: colors.white.withValues(alpha: 0.08),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}
