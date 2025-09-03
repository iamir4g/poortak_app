import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/bottom_nav.dart';
import 'package:poortak/common/widgets/custom_drawer.dart';
import 'package:poortak/common/widgets/logout_confirmation_modal.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/kavoosh_main_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_main_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/sayareh_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/screens/shopping_cart_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/bloc/permission/permission_bloc.dart';

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
    await prefsOperator.logout();
    // if (mounted) {
    //   setState(() {
    //     isLoggedIn = false;
    //   });
    // }
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

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                actions: [
                  currentPageIndex == 4
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: Color(0xFF3D495C)),
                          onSelected: (value) {
                            if (value == 'logout') _showLogoutConfirmation();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'logout',
                              child: Text('خروج از ناحیه کاربری'),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(33.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        offset: Offset(0, 1),
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
            );
          },
        ),
      ),
    );
  }
}
