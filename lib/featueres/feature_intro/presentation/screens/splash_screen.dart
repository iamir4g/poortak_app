import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/featueres/feature_intro/presentation/bloc/splash_bloc/splash_cubit.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/intro_main_wrapper.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';
import 'package:poortak/locator.dart';

class SplashScreen extends StatefulWidget {
  // final bool hasDeepLink;

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AppLinks _appLinks;
  StreamSubscription<Uri?>? _linkSub;
  bool _hasHandledDeepLink = false;
  static const MethodChannel _channel =
      MethodChannel('poortak.deeplink.flutter.dev/channel');

  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  // Uri? _latestLink;

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 SplashScreen: initState called");

    // Initialize background animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4500), // 4.5 seconds
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start background animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _backgroundAnimationController.forward();
      }
    });

    BlocProvider.of<SplashCubit>(context).checkConnectionEvent();

    // Initialize deep links after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
          "🚀 SplashScreen: Post frame callback - initializing deep links");
      _initDeepLinks();
      _initMethodChannel();
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel(); // ✅ مهم
    _channel.setMethodCallHandler(null);
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return SizedBox(
            width: width,
            child: Stack(
              children: [
                // Second background image (splash2.png) - slides down from top
                Positioned(
                  top: -MediaQuery.of(context).size.height +
                      (_backgroundAnimation.value *
                          MediaQuery.of(context).size.height),
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash/splash2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // First background image (splash1.png) - moves down
                Positioned(
                  top: _backgroundAnimation.value *
                      MediaQuery.of(context).size.height,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/splash/splash1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Content overlay
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo section without animation
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                'assets/images/poortakLogo.png',
                                width: width * 0.7,
                                height:
                                    width * 0.7 * 0.5, // Maintain aspect ratio
                              ),
                              const SizedBox(height: 30),
                              // Persian text
                              const Text(
                                'ایده ای جدید از انتشارات تاجیک',
                                style: TextStyle(
                                  fontFamily: 'IranSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Loading section
                      Expanded(
                        flex: 1,
                        child: BlocConsumer<SplashCubit, SplashState>(
                            builder: (context, state) {
                          /// if user is online
                          if (state.connectionStatus is ConnectionInitial ||
                              state.connectionStatus is ConnectionOn) {
                            return Directionality(
                              textDirection: TextDirection.ltr,
                              child: LoadingAnimationWidget.progressiveDots(
                                color: Colors.white,
                                size: 50,
                              ),
                            );
                          }

                          /// if user is offline
                          if (state.connectionStatus is ConnectionOff) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'به اینترنت متصل نیستید!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "vazir"),
                                ),
                                IconButton(
                                    splashColor: Colors.white,
                                    onPressed: () {
                                      /// check that we are online or not
                                      BlocProvider.of<SplashCubit>(context)
                                          .checkConnectionEvent();
                                    },
                                    icon: const Icon(
                                      Icons.autorenew,
                                      color: Colors.white,
                                    ))
                              ],
                            );
                          }

                          /// default value
                          return Container();
                        }, listener: (context, state) {
                          if (state.connectionStatus is ConnectionOn) {
                            gotoHome();
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> gotoHome() async {
    debugPrint("SplashScreen: Starting auto-navigation after 3 seconds...");

    PrefsOperator prefsOperator = locator<PrefsOperator>();
    var shouldShowIntro = await prefsOperator.getIntroState();

    return Future.delayed(const Duration(seconds: 3), () {
      // Don't auto-navigate if deep link was handled
      if (_hasHandledDeepLink) {
        debugPrint(
            "SplashScreen: Deep link was handled, skipping auto-navigation");
        return;
      }

      debugPrint("SplashScreen: Proceeding with auto-navigation");
      final navigatorContext = context;
      if (shouldShowIntro) {
        Navigator.pushNamedAndRemoveUntil(
          navigatorContext,
          IntroMainWrapper.routeName,
          ModalRoute.withName("intro_main_wrapper"),
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          navigatorContext,
          MainWrapper.routeName,
          ModalRoute.withName("main_wrapper"),
        );
      }
    });
  }

  Future<void> _initDeepLinks() async {
    debugPrint("🔧 SplashScreen: _initDeepLinks started");
    _appLinks = AppLinks();
    debugPrint("🔧 SplashScreen: AppLinks created");

    // وقتی اپ بازه
    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      debugPrint("🔗 SplashScreen: Stream received URI: $uri");
      if (uri != null) {
        _handleIncomingLink(uri);
      }
    }, onError: (error) {
      debugPrint("❌ SplashScreen: Stream error: $error");
    });

    // وقتی اپ تازه از لینک لانچ شده
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      debugPrint("🔗 SplashScreen: Initial link: $initialLink");
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      debugPrint("❌ SplashScreen: Error getting initial link: $e");
    }
  }

  void _handleIncomingLink(Uri uri) {
    debugPrint("📌 Deep Link received: $uri");
    debugPrint("📌 URI scheme: ${uri.scheme}");
    debugPrint("📌 URI host: ${uri.host}");
    debugPrint("📌 URI query parameters: ${uri.queryParameters}");
    debugPrint("📌 Full URI string: ${uri.toString()}");

    // More flexible matching
    if (uri.scheme == "return" && uri.host == "poortak") {
      debugPrint("📌 Scheme and host match!");
      final okParam = uri.queryParameters["ok"];
      if (okParam != null) {
        debugPrint(
            "📌 Valid deep link detected, navigating to PaymentResultScreen");
        _hasHandledDeepLink = true;

        // Add delay to ensure navigation works properly
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushNamed(
            context,
            PaymentResultScreen.routeName,
            arguments: {
              "status": int.parse(okParam),
              "ref": uri.queryParameters["ref"],
            },
          );
        });
      } else {
        debugPrint("📌 Deep link missing 'ok' parameter");
      }
    } else {
      debugPrint("📌 Deep link does not match expected format");
      debugPrint("📌 Expected: scheme='return', host='poortak'");
      debugPrint("📌 Got: scheme='${uri.scheme}', host='${uri.host}'");
    }
  }

  Future<void> _initMethodChannel() async {
    debugPrint("🔧 SplashScreen: Initializing method channel");

    // Get initial link from method channel
    try {
      final String? initialLink = await _channel.invokeMethod('initialLink');
      if (initialLink != null) {
        debugPrint(
            "🔧 SplashScreen: Method channel initial link: $initialLink");
        final Uri uri = Uri.parse(initialLink);
        _handleIncomingLink(uri);
      }
    } catch (e) {
      debugPrint(
          "❌ SplashScreen: Error getting initial link from method channel: $e");
    }

    // Set up method call handler for future deep links
    _channel.setMethodCallHandler((MethodCall call) async {
      debugPrint("🔧 SplashScreen: Method channel received: ${call.method}");
      if (call.method == 'onDeepLink') {
        final String? link = call.arguments as String?;
        if (link != null) {
          debugPrint("🔧 SplashScreen: Method channel deep link: $link");
          final Uri uri = Uri.parse(link);
          _handleIncomingLink(uri);
        }
      }
    });
  }
}
