import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_back_button.dart';
import 'package:fitness_app/core/widgets/web_view/web_view_error_view.dart';
import 'package:fitness_app/core/widgets/web_view/web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../../helpers/test_app.dart';

void main() {
  late FakeWebViewPlatform platform;

  setUp(() {
    platform = FakeWebViewPlatform();
    WebViewPlatform.instance = platform;
  });

  Future<void> pumpPage(WidgetTester tester, WebPage page) async {
    await pumpLocalizedScreen(tester, WebViewScreen(page: page));
    await settleUi(tester);
  }

  FakePlatformNavigationDelegate delegate() => platform.delegates.single;

  testWidgets('shows the page under its own title', (tester) async {
    await pumpPage(tester, WebPage.security);

    expect(find.text('Security'), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(WebViewWidget), findsOneWidget);
  });

  testWidgets('loads the address the menu asked for', (tester) async {
    await pumpPage(tester, WebPage.privacyPolicy);

    expect(platform.controllers.single.loadedUrls, [WebPage.privacyPolicy.url]);
  });

  testWidgets('opens content without scripts over a black canvas', (
    tester,
  ) async {
    await pumpPage(tester, WebPage.help);

    final controller = platform.controllers.single;
    expect(controller.javaScriptMode, JavaScriptMode.disabled);
    expect(controller.backgroundColor, AppColors.black);
    expect(controller.navigationDelegate, same(delegate()));
  });

  testWidgets('shows the bar only while the page is loading', (tester) async {
    await pumpPage(tester, WebPage.security);

    expect(find.byType(LinearProgressIndicator), findsNothing);

    delegate().onProgress!(40);
    await settleUi(tester, steps: 2);

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.4,
    );

    delegate().onPageFinished!(WebPage.security.url);
    await settleUi(tester, steps: 2);

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('hides the bar once the page is fully loaded', (tester) async {
    await pumpPage(tester, WebPage.security);

    delegate().onProgress!(100);
    await settleUi(tester, steps: 2);

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('ignores a sub-resource error and keeps the page loading', (
    tester,
  ) async {
    await pumpPage(tester, WebPage.security);

    delegate().onProgress!(20);
    await settleUi(tester, steps: 2);
    delegate().onWebResourceError!(
      const WebResourceError(
        errorCode: -1,
        description: 'image failed',
        isForMainFrame: false,
      ),
    );
    await settleUi(tester, steps: 2);

    expect(find.byType(WebViewErrorView), findsNothing);
    expect(find.byType(WebViewWidget), findsOneWidget);
  });

  testWidgets('a main-frame failure swaps the page for a retry view', (
    tester,
  ) async {
    await pumpPage(tester, WebPage.security);

    delegate().onProgress!(20);
    await settleUi(tester, steps: 2);
    delegate().onWebResourceError!(
      const WebResourceError(
        errorCode: -1,
        description: 'offline',
        isForMainFrame: true,
      ),
    );
    await settleUi(tester, steps: 2);

    expect(find.byType(WebViewErrorView), findsOneWidget);
    expect(find.byType(WebViewWidget), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('retry loads the same address again', (tester) async {
    await pumpPage(tester, WebPage.security);
    delegate().onWebResourceError!(
      const WebResourceError(
        errorCode: -1,
        description: 'offline',
        isForMainFrame: true,
      ),
    );
    await settleUi(tester, steps: 2);

    await tester.tap(
      find.descendant(
        of: find.byType(WebViewErrorView),
        matching: find.byType(FilledButton),
      ),
    );
    await settleUi(tester, steps: 2);

    expect(platform.controllers.single.loadedUrls.length, 2);
    expect(find.byType(WebViewWidget), findsOneWidget);
  });
}

class FakeWebViewPlatform extends WebViewPlatform {
  final controllers = <FakePlatformWebViewController>[];
  final delegates = <FakePlatformNavigationDelegate>[];

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = FakePlatformWebViewController(params);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    final delegate = FakePlatformNavigationDelegate(params);
    delegates.add(delegate);
    return delegate;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakePlatformWebViewWidget(params);
  }
}

class FakePlatformWebViewController extends PlatformWebViewController {
  FakePlatformWebViewController(super.params) : super.implementation();

  final loadedUrls = <String>[];
  Color? backgroundColor;
  JavaScriptMode? javaScriptMode;
  PlatformNavigationDelegate? navigationDelegate;

  @override
  Future<void> setBackgroundColor(Color color) async {
    backgroundColor = color;
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {
    javaScriptMode = mode;
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate delegate,
  ) async {
    navigationDelegate = delegate;
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    loadedUrls.add(params.uri.toString());
  }
}

class FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  FakePlatformNavigationDelegate(super.params) : super.implementation();

  ProgressCallback? onProgress;
  PageEventCallback? onPageFinished;
  WebResourceErrorCallback? onWebResourceError;

  @override
  Future<void> setOnProgress(ProgressCallback callback) async {
    onProgress = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    onPageFinished = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    onWebResourceError = callback;
  }
}

class FakePlatformWebViewWidget extends PlatformWebViewWidget {
  FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.white,
      child: SizedBox(key: Key('fakeWebView'), width: 100, height: 100),
    );
  }
}
