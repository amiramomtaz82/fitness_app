import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared shell for widget tests.
///
/// MaterialApp is kept on purpose: screens need its Navigator,
/// ScaffoldMessenger, MaterialLocalizations and the app theme.
Widget makeTestableWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => MaterialApp(theme: AppTheme.darkTheme, home: child),
  );
}

/// Same as [makeTestableWidget] for small widgets that need a Material
/// ancestor (e.g. text fields) but no full screen.
Widget makeTestableComponent(Widget child) {
  return makeTestableWidget(Scaffold(body: child));
}
