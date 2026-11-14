import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBackgroundScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final String? backgroundImage;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;
  final bool safeAreaTop;

  // === Per-Feature Overlay Customization ===
  final Color overlayColor;
  final double overlayOpacity;
  final Gradient? overlayGradient;

  // === Per-Feature Layout Grid Guide (Debug Mode) ===
  final bool showLayoutGrid;
  final Color? gridColor;
  final int gridColumns;

  const AppBackgroundScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.backgroundImage,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.6,
    this.overlayGradient,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = true,
    this.safeAreaTop = true,
    this.showLayoutGrid = false,
    this.gridColor,
    this.gridColumns = 2,
    image,
  });