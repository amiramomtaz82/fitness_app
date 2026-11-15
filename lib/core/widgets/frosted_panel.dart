import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/context.extension.dart';

class FrostedPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blurSigma;

  const FrostedPanel({
    super.key,
    required this.child,
    this.padding,
    this.radius = 50,
    this.blurSigma = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(radius.r);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.white.withValues(alpha: 0.06),
            borderRadius: borderRadius,
            border: Border.all(color: colors.white.withValues(alpha: 0.10)),
          ),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: child,
        ),
      ),
    );
  }
}
