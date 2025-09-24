import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_state.dart';
import 'package:poortak/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';

import '../blocs/bottom_nav_cubit/bottom_nav_cubit.dart';

// import '../../features/feature_auth/presentation/screens/mobile_signup_screen.dart';

class BottomNav extends StatelessWidget {
  final PageController controller;

  const BottomNav({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Container(
          decoration: BoxDecoration(
            color: themeState.isDark ? MyColors.darkBackground : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: themeState.isDark
                    ? Colors.black.withOpacity(0.3)
                    : const Color(0xFF92A2BE).withOpacity(0.12),
                offset: const Offset(0, -7),
                blurRadius: 13,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            height: 70,
            padding: const EdgeInsets.only(bottom: 8),
            child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => BottomNavCubit(),
                  ),
                  BlocProvider(
                    create: (context) {
                      final bloc = ShoppingCartBloc(repository: locator());
                      bloc.add(GetCartEvent());
                      return bloc;
                    },
                  )
                ],
                child: Builder(builder: (context) {
                  return BlocBuilder<BottomNavCubit, int>(
                      builder: (context, state) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildNavItem(
                            context: context,
                            state: state,
                            index: 0,
                            icon: "mage:video-player",
                            label: 'سیاره آینو',
                            controller: controller,
                          ),
                          _buildNavItem(
                            context: context,
                            state: state,
                            index: 1,
                            icon: "mage:search", //mdi:text-box-search-outline
                            label: 'کاوش',
                            controller: controller,
                            // useCustomIcon: false,
                          ),
                          _buildNavItem(
                            context: context,
                            state: state,
                            index: 2,
                            label: 'سبد خرید',
                            icon:
                                "hugeicons:shopping-cart-02", //"mage:shopping-cart",
                            controller: controller,
                            // useCustomIcon: false,
                            // materialIcon: Icons.shopping_cart_outlined,
                          ),
                          _buildNavItem(
                            context: context,
                            state: state,
                            index: 3,
                            label: 'لایتنر',
                            icon: "hugeicons:book-open-02", //"mage:book",
                            controller: controller,
                            // useCustomIcon: false,
                            // materialIcon: Icons.folder_outlined,
                          ),
                          _buildNavItem(
                            context: context,
                            state: state,
                            index: 4,
                            label: 'پروفایل',
                            controller: controller,
                            icon: "mynaui:user-square", //"mage:user",
                            // useCustomIcon: false,
                            // materialIcon: Icons.account_box_outlined,
                          ),
                        ]);
                  });
                })),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int state,
    required int index,
    required String label,
    required PageController controller,
    String icon = "",
  }) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Expanded(
          child: InkWell(
            onTap: () {
              BlocProvider.of<BottomNavCubit>(context)
                  .changeSelectedIndex(index);
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: SizedBox(
              height: 70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (state == index
                      ? state == 2 && index == 2
                          ? BlocConsumer<ShoppingCartBloc, ShoppingCartState>(
                              listener: (context, state) {
                                if (state is ShoppingCartLoaded) {
                                  // You can add any side effects here when cart changes
                                  // For example, showing a snackbar or updating other UI elements
                                }
                              },
                              builder: (context, cartState) {
                                if (cartState is ShoppingCartInitial) {
                                  return IconifyIcon(
                                      icon: icon, color: MyColors.primary);
                                }

                                if (cartState is ShoppingCartLoading) {
                                  return IconifyIcon(
                                      icon: icon, color: MyColors.primary);
                                }

                                if (cartState is ShoppingCartLoaded) {
                                  final cart = cartState.cart;
                                  if (cart.items.isNotEmpty) {
                                    return badges.Badge(
                                      badgeContent:
                                          Text(cart.items.length.toString()),
                                      child: IconifyIcon(
                                          icon: icon, color: MyColors.primary),
                                    );
                                  }
                                  return IconifyIcon(
                                      icon: icon, color: MyColors.primary);
                                }

                                return IconifyIcon(
                                    icon: icon, color: MyColors.primary);
                              },
                            )
                          : IconifyIcon(
                              icon: icon,
                              color: index == 1
                                  ? MyColors.primary
                                  : MyColors.primary)
                      : index == 2
                          ? BlocConsumer<ShoppingCartBloc, ShoppingCartState>(
                              listener: (context, state) {
                                if (state is ShoppingCartLoaded) {
                                  // You can add any side effects here when cart changes
                                  // For example, showing a snackbar or updating other UI elements
                                }
                              },
                              builder: (context, cartState) {
                                if (cartState is ShoppingCartInitial) {
                                  return IconifyIcon(
                                      icon: icon,
                                      color: themeState.isDark
                                          ? MyColors.darkTextSecondary
                                          : Colors.grey);
                                }

                                if (cartState is ShoppingCartLoading) {
                                  return IconifyIcon(
                                      icon: icon,
                                      color: themeState.isDark
                                          ? MyColors.darkTextSecondary
                                          : Colors.grey);
                                }

                                if (cartState is ShoppingCartLoaded) {
                                  final cart = cartState.cart;
                                  if (cart.items.isNotEmpty) {
                                    return badges.Badge(
                                      badgeContent:
                                          Text(cart.items.length.toString()),
                                      child: IconifyIcon(
                                          icon: icon,
                                          color: themeState.isDark
                                              ? MyColors.darkTextSecondary
                                              : Colors.grey),
                                    );
                                  }
                                  return IconifyIcon(
                                      icon: icon,
                                      color: themeState.isDark
                                          ? MyColors.darkTextSecondary
                                          : Colors.grey);
                                }

                                return IconifyIcon(
                                    icon: icon,
                                    color: themeState.isDark
                                        ? MyColors.darkTextSecondary
                                        : Colors.grey);
                              },
                            )
                          : IconifyIcon(
                              icon: icon,
                              color: themeState.isDark
                                  ? MyColors.darkTextSecondary
                                  : Colors.grey)),
                  if (state == index)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          color: MyColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> getDataFromPrefs() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool('user_loggedIn') ?? false;

    return loggedIn;
  }
}
