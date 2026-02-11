import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/bottom_nav.dart';
import 'package:poortak/common/widgets/custom_drawer.dart';
import 'package:poortak/common/widgets/logout_confirmation_modal.dart';
import 'package:poortak/common/widgets/exit_confirmation_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/kavoosh_main_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_main_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
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

  late int currentPageIndex;

  // Deep link handling
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Define screens as getters to ensure they're created when needed
  List<Widget> get topLevelScreens => [
        const SayarehScreen(),
        const KavooshMainScreen(),
        const ShoppingCartScreen(),
        LitnerMainScreen(),
        const ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    // Initialize currentPageIndex from widget.initialIndex or default to 0
    currentPageIndex = widget.initialIndex ?? 0;
    // Initialize PageController with initial page
    controller = PageController(initialPage: currentPageIndex);

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
    });

    // Initialize deep link handling for when app is already running
    _initDeepLinks();
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

  void _handleIncomingLink(Uri uri) {
    log("📌 MainWrapper: Deep Link received: $uri");
    log("📌 MainWrapper: URI scheme: ${uri.scheme}");
    log("📌 MainWrapper: URI host: ${uri.host}");
    log("📌 MainWrapper: URI query parameters: ${uri.queryParameters}");

    if (uri.scheme == "return" && uri.host == "poortak") {
      final okParam = uri.queryParameters["ok"];
      if (okParam != null) {
        log("📌 MainWrapper: Valid deep link detected, navigating to PaymentResultScreen");

        // Navigate to payment result screen for both success and failure
        Navigator.pushNamed(
          context,
          PaymentResultScreen.routeName,
          arguments: {
            "status": int.parse(okParam),
            "ref": uri.queryParameters["ref"],
          },
        );
      } else {
        log("📌 MainWrapper: Deep link missing 'ok' parameter");
      }
    } else {
      log("📌 MainWrapper: Deep link does not match expected format");
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    controller.dispose();
    super.dispose();
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

  void _logout() async {
    // Clear user data from preferences
    await prefsOperator.logout();

    // Clear shopping cart (both local and remote)
    try {
      context.read<ShoppingCartBloc>().add(ClearLocalCartEvent());
    } catch (e) {
      log("⚠️ Failed to clear shopping cart: $e");
    }

    // Navigate to Sayareh screen (index 0) instead of login screen
    controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Update the current page index
    setState(() {
      currentPageIndex = 0;
    });
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
      controller.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
              ),
            );
          } else if (state is PermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'برای استفاده از برنامه نیاز به دسترسی به حافظه دارید'),
                backgroundColor: Colors.red,
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
                // Update BottomNavCubit if initialIndex is provided (only once)
                if (widget.initialIndex != null &&
                    currentPageIndex == widget.initialIndex) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    try {
                      context
                          .read<BottomNavCubit>()
                          .changeSelectedIndex(widget.initialIndex!);
                    } catch (e) {
                      // BottomNavCubit might not be available yet, ignore
                    }
                  });
                }

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
                    extendBodyBehindAppBar: false,
                    drawerScrimColor: Colors.black54,
                    // onDrawerChanged: (isOpened) async {
                    //   // تنظیم status bar وقتی drawer باز یا بسته می‌شود
                    //   final backgroundColor = themeState.isDark
                    //       ? MyColors.darkBackground
                    //       : Colors.white;
                    //   final statusBarIconBrightness = themeState.isDark
                    //       ? Brightness.light
                    //       : Brightness.dark;

                    //   if (isOpened) {
                    //     // وقتی drawer باز است، status bar را کاملاً شفاف می‌کنیم
                    //     await SystemChrome.setEnabledSystemUIMode(
                    //       SystemUiMode.edgeToEdge,
                    //     );
                    //     SystemChrome.setSystemUIOverlayStyle(
                    //       SystemUiOverlayStyle(
                    //         statusBarColor: MyColors.primary,
                    //         statusBarIconBrightness: statusBarIconBrightness,
                    //         statusBarBrightness: themeState.isDark
                    //             ? Brightness.dark
                    //             : Brightness.light,
                    //         systemNavigationBarColor: MyColors.primary,
                    //         systemNavigationBarIconBrightness:
                    //             statusBarIconBrightness,
                    //       ),
                    //     );
                    //   } else {
                    //     // وقتی drawer بسته است، status bar را به MyColors.statusBarColor برمی‌گردانیم
                    //     SystemChrome.setSystemUIOverlayStyle(
                    //       SystemUiOverlayStyle(
                    //         statusBarColor: MyColors.primary,
                    //         statusBarIconBrightness: statusBarIconBrightness,
                    //         statusBarBrightness: themeState.isDark
                    //             ? Brightness.dark
                    //             : Brightness.light,
                    //         systemNavigationBarColor: backgroundColor,
                    //         systemNavigationBarIconBrightness:
                    //             statusBarIconBrightness,
                    //       ),
                    //     );
                    //   }
                    // },
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
                                      'خروج از ناحیه کاربری',
                                      style: TextStyle(
                                        color: themeState.isDark
                                            ? MyColors.darkTextPrimary
                                            : MyColors.textMatn1,
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
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(33.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeState.isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : const Color.fromRGBO(0, 0, 0, 0.05),
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(33.5),
                        ),
                      ),
                    ),
                    drawer: const CustomDrawer(),
                    bottomNavigationBar: BottomNav(controller: controller),
                    body: SafeArea(
                      child: state is PermissionLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PageView(
                              controller: controller,
                              onPageChanged: (index) {
                                setState(() {
                                  currentPageIndex = index;
                                });
                              },
                              children: topLevelScreens,
                            ),
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
