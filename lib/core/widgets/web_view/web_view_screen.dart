import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/widgets/app_title_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final WebPage page;

  const WebViewScreen({super.key, required this.page});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setBackgroundColor(AppColors.black)
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: _updateProgress,
          onPageFinished: _dismissProgress,
          onWebResourceError: _dismissProgress,
        ),
      )
      ..loadRequest(Uri.parse(widget.page.url));
  }

  void _updateProgress(int progress) {
    if (!mounted) return;
    setState(() => _loadingProgress = progress);
  }

  void _dismissProgress(Object? _) {
    _updateProgress(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: AppTitleBar(
                titleKey: widget.page.titleKey,
                showBackButton: true,
              ),
            ),
            if (_loadingProgress > 0 && _loadingProgress < 100)
              LinearProgressIndicator(
                minHeight: 2,
                value: _loadingProgress / 100,
                backgroundColor: AppColors.surface,
                color: colors.primary,
              ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
