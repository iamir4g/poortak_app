import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/splash_screen.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';
import 'package:poortak/common/services/deep_link_manager.dart';

class DeepLinkHandler extends StatefulWidget {
  const DeepLinkHandler({super.key});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late final AppLinks _appLinks;
  final DeepLinkManager _deepLinkManager = DeepLinkManager();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _deepLinkManager.addListener(_onDeepLinkUpdate);
  }

  @override
  void dispose() {
    _deepLinkManager.removeListener(_onDeepLinkUpdate);
    super.dispose();
  }

  void _onDeepLinkUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    debugPrint("DeepLinkHandler: Initializing deep links...");

    // هندل لینک اولیه (وقتی اپ با لینک باز میشه)
    final initialLink = await _appLinks.getInitialLink();
    debugPrint("DeepLinkHandler: Initial link: $initialLink");
    if (initialLink != null) {
      _handleUri(initialLink);
    }

    // هندل لینک‌های بعدی (وقتی اپ بازه و لینک جدید میاد)
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint("DeepLinkHandler: Received new link: $uri");
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    debugPrint("DeepLinkHandler: Handling URI: $uri");
    debugPrint("DeepLinkHandler: URI scheme: ${uri.scheme}");
    debugPrint("DeepLinkHandler: URI host: ${uri.host}");
    debugPrint("DeepLinkHandler: URI path: ${uri.path}");
    debugPrint("DeepLinkHandler: URI query: ${uri.query}");

    // اینجا مقادیر رو بخون
    final status = uri.queryParameters['status'];
    final ref = uri.queryParameters['ref'];
    debugPrint("DeepLink => status: $status, ref: $ref");

    // Check if this is a payment deep link
    debugPrint("DeepLinkHandler: Checking conditions...");
    debugPrint("DeepLinkHandler: scheme='${uri.scheme}' (expected: 'return')");
    debugPrint("DeepLinkHandler: host='${uri.host}' (expected: 'poortak')");
    debugPrint("DeepLinkHandler: status='$status' (expected: not null)");
    debugPrint(
        "DeepLinkHandler: hasHandled='${_deepLinkManager.hasDeepLink}' (expected: false)");

    if (uri.scheme == 'return' &&
        uri.host == 'poortak' &&
        status != null &&
        !_deepLinkManager.hasDeepLink) {
      debugPrint(
          "DeepLinkHandler: ✅ Payment deep link detected - Status: $status, Ref: $ref");
      debugPrint("DeepLinkHandler: Storing pending navigation data...");

      // Use the global manager to store the data
      _deepLinkManager.setDeepLinkData(status, ref);
    } else {
      debugPrint("DeepLinkHandler: ❌ Conditions not met for payment deep link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Show navigation button if there's pending deep link data
          // if (_deepLinkManager.hasDeepLink)
          //   Container(
          //     padding: const EdgeInsets.all(20),
          //     child: Column(
          //       children: [
          //         ElevatedButton(
          //           onPressed: () {
          //             debugPrint(
          //                 "DeepLinkHandler: Navigating to PaymentResultScreen with pending data...");
          //             _deepLinkManager.navigateToPaymentResult(context);
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.green,
          //             foregroundColor: Colors.white,
          //           ),
          //           child: Text(
          //               "Go to Payment Result (${_deepLinkManager.pendingStatus})"),
          //         ),
          //         const SizedBox(height: 10),
          //         Text("Deep Link Handled: ${_deepLinkManager.hasDeepLink}"),
          //       ],
          //     ),
          //   ),
          // Test buttons
          // Container(
          //   padding: const EdgeInsets.all(20),
          //   child: Column(
          //     children: [
          //       ElevatedButton(
          //         onPressed: () {
          //           debugPrint(
          //               "TEST: Manually navigating to PaymentResultScreen...");
          //           Navigator.of(context).pushAndRemoveUntil(
          //             MaterialPageRoute(
          //               builder: (context) => PaymentResultScreen(
          //                 status: "OK",
          //                 ref: "test123",
          //               ),
          //             ),
          //             (route) => false,
          //           );
          //         },
          //         child: const Text("TEST: Go to Payment Result"),
          //       ),
          //       const SizedBox(height: 10),
          //       ElevatedButton(
          //         onPressed: () {
          //           debugPrint("RESET: Resetting deep link handler...");
          //           _deepLinkManager.clearDeepLinkData();
          //         },
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.orange,
          //           foregroundColor: Colors.white,
          //         ),
          //         child: const Text("RESET Deep Link Handler"),
          //       ),
          //     ],
          //   ),
          // ),
          // Original splash screen
          Expanded(
            child: SplashScreen(
              hasDeepLink: _deepLinkManager.hasDeepLink,
            ),
          ),
        ],
      ),
    );
  }
}
