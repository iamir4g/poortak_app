import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/services/payment_deep_link_service.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_intro/presentation/bloc/splash_bloc/splash_cubit.dart';
import 'package:poortak/featueres/feature_intro/presentation/screens/intro_main_wrapper.dart';
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
  bool _didPrecacheLogo = false;
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
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Start background animation after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        _backgroundAnimationController.forward();
      });
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheLogo) return;
    _didPrecacheLogo = true;
    precacheEmbeddedRasterFromSvg(context, 'assets/images/poortak_logo.svg');
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
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage(
                            'assets/images/splash/splash_full.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment(
                          0,
                          1 - (_backgroundAnimation.value * 2),
                        ),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo
                              buildImageFromAssetOrEmbeddedSvg(
                                'assets/images/poortak_logo.svg',
                                width: width * 0.68,
                                height: width * 0.68 * 0.65,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 30.h),
                              // Persian text
                              Text(
                                'ایده ای جدید از انتشارات تاجیک',
                                style: TextStyle(
                                  fontFamily: 'IranSans',
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w900,
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
                                size: 50.r,
                              ),
                            );
                          }

                          /// if user is offline
                          if (state.connectionStatus is ConnectionOff) {
                            return Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'به اینترنت متصل نیستید!',
                                      style: TextStyle(
                                        color: MyColors.primary,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'vazir',
                                        fontSize: 14.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                    ),
                                    SizedBox(width: 4.w),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      splashColor:
                                          MyColors.primary.withValues(alpha: 0.2),
                                      onPressed: () {
                                        /// check that we are online or not
                                        BlocProvider.of<SplashCubit>(context)
                                            .checkConnectionEvent();
                                      },
                                      icon: Icon(
                                        Icons.autorenew,
                                        color: MyColors.primary,
                                        size: 22.r,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      if (!mounted) return;

      debugPrint("SplashScreen: Proceeding with auto-navigation");
      final navigatorContext = context;

      if (_hasHandledDeepLink) {
        Navigator.pushNamedAndRemoveUntil(
          navigatorContext,
          MainWrapper.routeName,
          (route) => false,
        );
        return;
      }

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
    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) async {
      debugPrint("🔗 SplashScreen: Stream received URI: $uri");
      if (uri != null) {
        await _handleIncomingLink(uri);
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

  Future<void> _handleIncomingLink(Uri uri) async {
    debugPrint("📌 Deep Link received: $uri");

    final paymentLink = locator<PaymentDeepLinkService>();
    final paymentData = await paymentLink.tryConsume(uri, defer: true);
    if (paymentData == null) {
      debugPrint("📌 Deep link ignored (already handled or invalid)");
      return;
    }

    debugPrint(
        "📌 Valid payment deep link, will show PaymentResultScreen after home");
    _hasHandledDeepLink = true;

    try {
      await _channel.invokeMethod('clearInitialLink');
    } catch (e) {
      debugPrint("❌ SplashScreen: Error clearing native initial link: $e");
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
          await _handleIncomingLink(Uri.parse(link));
        }
      }
    });
  }
}
