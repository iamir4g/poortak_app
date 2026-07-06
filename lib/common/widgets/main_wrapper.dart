import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/bottom_nav.dart';
import 'package:poortak/common/widgets/custom_drawer.dart';
import 'package:poortak/common/widgets/logout_confirmation_modal.dart';
import 'package:poortak/common/widgets/exit_confirmation_modal.dart';
import 'package:poortak/common/services/payment_deep_link_service.dart';
import 'package:poortak/common/services/auth_navigation_manager.dart';
import 'package:poortak/common/services/otp_login_session_manager.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/kavoosh_main_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_main_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/sayareh_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/screens/shopping_cart_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/bloc/permission/permission_bloc.dart';
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';
import 'package:poortak/common/blocs/bottom_nav_cubit/bottom_nav_cubit.dart';

class MainWrapper extends StatefulWidget {
  static const routeName = "/main_wrapper";
  final int? initialIndex;
  const MainWrapper({super.key, this.initialIndex});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Using late init to ensure PageController is created only once
  late final PageController controller;
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthNavigationManager _authNavigationManager = AuthNavigationManager();
  late final VoidCallback _authNavigationListener;

  late int currentPageIndex;
  bool _isProgrammaticNavigation = false;
  int? _targetPageIndex;

  static const _tabAnimationDuration = Duration(milliseconds: 350);
  static const _tabAnimationCurve = Curves.easeOutCubic;

  // Deep link handling
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Define screens as getters to ensure they're created when needed
  List<Widget> get topLevelScreens => [
        const SayarehScreen(),
        const KavooshMainScreen(),
        const ShoppingCartScreen(),
        const LitnerMainScreen(),
        const ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    // Initialize currentPageIndex from widget.initialIndex or default to 0
    currentPageIndex = widget.initialIndex ?? 0;
    // Initialize PageController with initial page
    controller = PageController(initialPage: currentPageIndex);
    _authNavigationListener = _handleAuthNavigation;
    _authNavigationManager.addListener(_authNavigationListener);

    // تنظیم status bar برای MainWrapper
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: MyColors.primary,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );

      // Update BottomNavCubit if initialIndex is provided
      if (widget.initialIndex != null) {
        try {
          context
              .read<BottomNavCubit>()
              .changeSelectedIndex(widget.initialIndex!);
        } catch (e) {
          // BottomNavCubit might not be available yet, ignore
        }
      }
      _handleAuthNavigation();
      _showPendingPaymentResultIfNeeded();
    });

    // Initialize deep link handling for when app is already running
    _initDeepLinks();
  }

  void _showPendingPaymentResultIfNeeded() {
    final pending = locator<PaymentDeepLinkService>().takePendingResult();
    if (pending == null) return;
    _openPaymentResultScreen(pending);
  }

  void _openPaymentResultScreen(PaymentDeepLinkData data) {
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      PaymentResultScreen.routeName,
      arguments: {
        "status": data.ok,
        "ref": data.ref,
      },
    ).then((_) async {
      if (!mounted || data.ok != 1) return;
      try {
        await locator<ShoppingCartBloc>().clearAfterSuccessfulPayment();
      } catch (e) {
        log("⚠️ MainWrapper: Failed to refresh cart after payment: $e");
      }
    });
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Listen for deep links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        log("🔗 MainWrapper: Deep link received: $uri");
        _handleIncomingLink(uri);
      },
      onError: (error) {
        log("❌ MainWrapper: Deep link stream error: $error");
      },
    );
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    log("📌 MainWrapper: Deep Link received: $uri");

    final paymentData = await locator<PaymentDeepLinkService>().tryConsume(uri);
    if (paymentData == null) {
      log("📌 MainWrapper: Deep link ignored (already handled or invalid)");
      return;
    }

    log("📌 MainWrapper: Navigating to PaymentResultScreen");
    if (!mounted) return;

    _openPaymentResultScreen(paymentData);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _authNavigationManager.removeListener(_authNavigationListener);
    controller.dispose();
    super.dispose();
  }

  void _handleAuthNavigation() {
    final pending = _authNavigationManager.pendingRequest;
    if (pending == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!prefsOperator.isLoggedIn()) {
        _animateToTab(4);
        return;
      }

      _animateToTab(pending.returnTabIndex);
      final returnRouteName = pending.returnRouteName;
      if (returnRouteName != null && returnRouteName.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 320), () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            returnRouteName,
            arguments: pending.returnRouteArguments,
          );
        });
      }
      _authNavigationManager.clearPendingRequest();
    });
  }

  String getTitle(int index) {
    switch (index) {
      case 0:
        return 'کتاب های سیاره آی نو';
      case 1:
        return 'کاووش';
      case 2:
        return 'سبد خرید';
      case 3:
        return 'لایتنر';
      case 4:
        return 'پروفایل';
    }

    return '';
  }

  void _refreshShoppingCartIfNeeded(int index) {
    if (index != 2) return;

    try {
      final cartBloc = locator<ShoppingCartBloc>();
      if (prefsOperator.isLoggedIn()) {
        cartBloc.add(GetCartEvent());
      } else {
        cartBloc.add(GetLocalCartEvent());
      }
    } catch (e) {
      log("⚠️ Failed to refresh shopping cart: $e");
    }
  }

  void _animateToTab(int index) {
    if (!mounted || index == currentPageIndex) return;

    _isProgrammaticNavigation = true;
    _targetPageIndex = index;

    context.read<BottomNavCubit>().changeSelectedIndex(index);
    setState(() {
      currentPageIndex = index;
    });
    _refreshShoppingCartIfNeeded(index);

    controller
        .animateToPage(
      index,
      duration: _tabAnimationDuration,
      curve: _tabAnimationCurve,
    )
        .whenComplete(() {
      if (!mounted) return;
      _isProgrammaticNavigation = false;
      _targetPageIndex = null;
    });
  }

  void _onPageChanged(int index) {
    if (_isProgrammaticNavigation && index != _targetPageIndex) {
      return;
    }

    context.read<BottomNavCubit>().changeSelectedIndex(index);
    if (currentPageIndex != index) {
      setState(() {
        currentPageIndex = index;
      });
    }
    _refreshShoppingCartIfNeeded(index);
  }

  void _logout() async {
    // Clear user data from preferences
    OtpLoginSessionManager().clearSession();
    await prefsOperator.logout();
    final accessBloc = locator<IknowAccessBloc>();
    accessBloc.add(ClearIknowAccessEvent());
    accessBloc.add(FetchIknowAccessEvent(forceRefresh: true));

    // Clear shopping cart (both local and remote)
    try {
      context.read<ShoppingCartBloc>().add(ClearLocalCartEvent());
    } catch (e) {
      log("⚠️ Failed to clear shopping cart: $e");
    }

    // Navigate to Sayareh screen (index 0) instead of login screen
    _animateToTab(0);
  }

  void _showLogoutConfirmation() {
    LogoutConfirmationModal.show(
      context: context,
      onLogout: _logout,
      onStay: () {
        // Do nothing, just close the modal
      },
    );
  }

  void _showExitConfirmation() {
    ExitConfirmationModal.show(
      context: context,
      onExit: () {
        // Exit the app
        SystemNavigator.pop();
      },
      onStay: () {
        // Do nothing, just close the modal
      },
    );
  }

  Future<bool> _onWillPop() async {
    // First, check if drawer is open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      // Close the drawer first
      Navigator.of(context).pop();
      return false; // Prevent default back behavior
    }

    // If not on Sayareh screen (index 0), navigate to Sayareh
    if (currentPageIndex != 0) {
      _animateToTab(0);
      return false; // Prevent default back behavior
    }

    // If on Sayareh screen, show exit confirmation
    _showExitConfirmation();
    return false; // Prevent default back behavior
  }

  @override
  Widget build(BuildContext context) {
    // تنظیم مرکزی status bar برای تمام صفحات
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   SystemChrome.setSystemUIOverlayStyle(
    //     const SystemUiOverlayStyle(
    //       statusBarColor: MyColors.primary,
    //       statusBarIconBrightness: Brightness.dark,
    //       statusBarBrightness: Brightness.light,
    //     ),
    //   );
    // });

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BlocStorageBloc(
            sayarehRepository: locator<SayarehRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => locator<PermissionBloc>(),
        ),
        // BlocProvider(
        //   create: (context) => locator<LitnerBloc>(),
        // ),
      ],
      child: BlocListener<PermissionBloc, PermissionState>(
        listener: (context, state) {
          if (state is PermissionError) {
            log(state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطا در دسترسی به حافظه: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is PermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'برای استفاده از برنامه نیاز به دسترسی به حافظه دارید'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: BlocBuilder<PermissionBloc, PermissionState>(
          builder: (context, state) {
            if (state is PermissionInitial) {
              // Check permissions when the app starts
              context.read<PermissionBloc>().add(CheckStoragePermissionEvent());
            }

            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) async {
                    if (!didPop) {
                      await _onWillPop();
                    }
                  },
                  child: Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: themeState.isDark
                        ? MyColors.darkBackground
                        : Colors.white,
                    resizeToAvoidBottomInset: false,
                    extendBodyBehindAppBar: false,
                    drawerScrimColor: Colors.black54,
                    appBar: AppBar(
                      backgroundColor: themeState.isDark
                          ? MyColors.darkBackground
                          : MyColors.background,
                      foregroundColor: themeState.isDark
                          ? MyColors.darkTextPrimary
                          : MyColors.textMatn1,
                      elevation: 0,
                      actions: [
                        (currentPageIndex == 4 && prefsOperator.isLoggedIn())
                            ? PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert,
                                    color: themeState.isDark
                                        ? MyColors.darkTextPrimary
                                        : const Color(0xFF3D495C)),
                                onSelected: (value) {
                                  if (value == 'logout') {
                                    _showLogoutConfirmation();
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'logout',
                                    child: Text(
                                      'خروج از حساب کاربری',
                                      style: MyTextStyle.textMatn13.copyWith(
                                        color: themeState.isDark
                                            ? MyColors.darkTextPrimary
                                            : MyColors.textMatn1,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ],
                      flexibleSpace: Container(
                        decoration: BoxDecoration(
                          color: themeState.isDark
                              ? MyColors.darkBackground
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(33.5.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeState.isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : const Color.fromRGBO(0, 0, 0, 0.05),
                              offset: Offset(0, 1.h),
                              blurRadius: 1.r,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(33.5.r),
                        ),
                      ),
                    ),
                    drawer: const CustomDrawer(),
                    bottomNavigationBar: BottomNav(
                      controller: controller,
                      onTabSelected: _animateToTab,
                    ),
                    body: state is PermissionLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PageView(
                            controller: controller,
                            physics: const ClampingScrollPhysics(),
                            onPageChanged: _onPageChanged,
                            children: topLevelScreens,
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
