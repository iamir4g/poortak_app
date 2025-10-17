import 'dart:developer';

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
import 'package:poortak/locator.dart';
import 'package:poortak/common/bloc/permission/permission_bloc.dart';
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';

class MainWrapper extends StatefulWidget {
  static const routeName = "/main_wrapper";
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Using late init to ensure PageController is created only once
  final PageController controller = PageController();
  final PrefsOperator prefsOperator = locator<PrefsOperator>();

  int currentPageIndex = 0;

  // Define screens as getters to ensure they're created when needed
  List<Widget> get topLevelScreens => [
        const SayarehScreen(),
        const KavooshMainScreen(),
        const ShoppingCartScreen(),
        LitnerMainScreen(),
        const ProfileScreen(),
      ];

  @override
  void dispose() {
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
                return PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) async {
                    if (!didPop) {
                      await _onWillPop();
                    }
                  },
                  child: Scaffold(
                    backgroundColor: themeState.isDark
                        ? MyColors.darkBackground
                        : Colors.white,
                    appBar: AppBar(
                      backgroundColor: themeState.isDark
                          ? MyColors.darkBackground
                          : Colors.white,
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
                                  if (value == 'logout')
                                    _showLogoutConfirmation();
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
                    body: state is PermissionLoading
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
