import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/splash_screen.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';

class DeepLinkHandler extends StatefulWidget {
  const DeepLinkHandler({super.key});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _hasReceivedDeepLink = false;

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 DeepLinkHandler: initState called - Widget is loading!");
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    debugPrint("🔧 DeepLinkHandler: _initDeepLinks started");
    _appLinks = AppLinks();
    debugPrint("🔧 DeepLinkHandler: AppLinks created");

    // برای وقتی که اپ از قبل بازه
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint("🔗 DeepLinkHandler: Stream received URI: $uri");
        _handleIncomingLink(uri);
      },
      onError: (error) {
        debugPrint("❌ DeepLinkHandler: Stream error: $error");
      },
    );

    // برای وقتی که اپ تازه از لینک لانچ شده
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      debugPrint("🔗 DeepLinkHandler: Initial link: $initialLink");
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      debugPrint("❌ DeepLinkHandler: Error getting initial link: $e");
    }
  }

  void _handleIncomingLink(Uri uri) {
    debugPrint("📌 DeepLinkHandler: Deep Link received: $uri");
    debugPrint("📌 DeepLinkHandler: URI scheme: ${uri.scheme}");
    debugPrint("📌 DeepLinkHandler: URI host: ${uri.host}");
    debugPrint(
        "📌 DeepLinkHandler: URI query parameters: ${uri.queryParameters}");

    if (uri.scheme == "return" && uri.host == "poortak") {
      final okParam = uri.queryParameters["ok"];
      if (okParam != null) {
        debugPrint(
            "📌 DeepLinkHandler: Valid deep link detected, navigating to PaymentResultScreen");
        _hasReceivedDeepLink = true;

        // Navigate directly to payment result for both success and failure
        Navigator.pushNamed(
          context,
          PaymentResultScreen.routeName,
          arguments: {
            "status": int.parse(okParam),
            "ref": uri.queryParameters["ref"],
          },
        );
      } else {
        debugPrint(
            "📌 DeepLinkHandler: Deep link missing 'ok' parameter");
      }
    } else {
      debugPrint(
          "📌 DeepLinkHandler: Deep link does not match expected format");
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "🎨 DeepLinkHandler: build() called - hasDeepLink: $_hasReceivedDeepLink");

    // If we have a deep link, show a simple loading screen
    if (_hasReceivedDeepLink) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('در حال پردازش...', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      );
    }

    // Otherwise show splash screen
    return SplashScreen();
  }
}
