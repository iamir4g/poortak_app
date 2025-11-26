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

  Widget _buildIcon({
    required BuildContext context,
    required int index,
    required int state,
    required String icon,
    required bool isSelected,
    required ThemeState themeState,
  }) {
    // برای کاوش (index 1) و لایتنر (index 3) از تصویر استفاده می‌کنیم
    if (index == 1 || index == 3) {
      String imagePath = index == 1
          ? 'assets/images/bottomNav/kavoshicon.png'
          : 'assets/images/bottomNav/litnericon.png';

      return Image.asset(
        imagePath,
        width: 24,
        height: 24,
        color: isSelected
            ? MyColors.primary
            : (themeState.isDark ? MyColors.darkTextSecondary : Colors.grey),
        colorBlendMode: BlendMode.srcIn,
      );
    }

    // برای بقیه از IconifyIcon استفاده می‌کنیم
    Color iconColor = isSelected
        ? MyColors.primary
        : (themeState.isDark ? MyColors.darkTextSecondary : Colors.grey);

    if (index == 2) {
      // برای سبد خرید با badge
      return BlocConsumer<ShoppingCartBloc, ShoppingCartState>(
        listener: (context, state) {
          if (state is ShoppingCartLoaded) {
            // You can add any side effects here when cart changes
          }
        },
        builder: (context, cartState) {
          if (cartState is ShoppingCartInitial) {
            return IconifyIcon(icon: icon, color: iconColor);
          }

          if (cartState is ShoppingCartLoading) {
            return IconifyIcon(icon: icon, color: iconColor);
          }

          if (cartState is ShoppingCartLoaded) {
            final cart = cartState.cart;
            if (cart.items.isNotEmpty) {
              return badges.Badge(
                badgeContent: Text(cart.items.length.toString()),
                child: IconifyIcon(icon: icon, color: iconColor),
              );
            }
            return IconifyIcon(icon: icon, color: iconColor);
          }

          return IconifyIcon(icon: icon, color: iconColor);
        },
      );
    }

    return IconifyIcon(icon: icon, color: iconColor);
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
        final isSelected = state == index;
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
                  _buildIcon(
                    context: context,
                    index: index,
                    state: state,
                    icon: icon,
                    isSelected: isSelected,
                    themeState: themeState,
                  ),
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
