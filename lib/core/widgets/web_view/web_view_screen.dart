import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/widgets/app_title_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'web_view_error_view.dart';

class WebViewScreen extends StatefulWidget {
  final WebPage page;

  const WebViewScreen({super.key, required this.page});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  final ValueNotifier<int> _progress = ValueNotifier<int>(0);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setBackgroundColor(AppColors.black)
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: _onProgress,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onResourceError,
        ),
      )
      ..loadRequest(Uri.parse(widget.page.url));
  }

  void _onProgress(int progress) {
    if (progress < 100) _progress.value = progress;
  }

  void _onPageFinished(String _) {
    _progress.value = 0;
    _failed.value = false;
  }

  void _onResourceError(WebResourceError error) {
    if (error.isForMainFrame ?? false) {
      _progress.value = 0;
      _failed.value = true;
    }
  }

  void _retry() {
    _failed.value = false;
    _progress.value = 0;
    _controller.loadRequest(Uri.parse(widget.page.url));
  }

  @override
  void dispose() {
    _progress.dispose();
    _failed.dispose();
    super.dispose();
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
            ValueListenableBuilder<int>(
              valueListenable: _progress,
              builder: (context, progress, _) {
                if (progress <= 0 || progress >= 100) {
                  return const SizedBox.shrink();
                }
                return LinearProgressIndicator(
                  minHeight: 2,
                  value: progress / 100,
                  backgroundColor: AppColors.surface,
                  color: colors.primary,
                );
              },
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _failed,
                builder: (context, failed, _) {
                  if (failed) return WebViewErrorView(onRetry: _retry);
                  return WebViewWidget(controller: _controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
