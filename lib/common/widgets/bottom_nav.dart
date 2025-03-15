import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/bottom_nav_cubit/bottom_nav_cubit.dart';

// import '../../features/feature_auth/presentation/screens/mobile_signup_screen.dart';

class BottomNav extends StatelessWidget {
  final PageController controller;

  const BottomNav({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var primaryColor = Theme.of(context).primaryColor;
    // TextTheme textTheme = Theme.of(context).textTheme;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: 50,
        padding: EdgeInsets.only(bottom: 8),
        child: BlocBuilder<BottomNavCubit, int>(
          builder: (context, int state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  context: context,
                  state: state,
                  index: 0,
                  icon: "mage:video-player",
                  label: 'کاوش',
                  controller: controller,
                ),
                _buildNavItem(
                  context: context,
                  state: state,
                  index: 1,
                  icon: "mage:search", //mdi:text-box-search-outline
                  label: 'دسته بندی',
                  controller: controller,
                  // useCustomIcon: false,
                ),
                _buildNavItem(
                  context: context,
                  state: state,
                  index: 2,
                  label: 'سبد خرید',
                  icon: "hugeicons:shopping-cart-02", //"mage:shopping-cart",
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
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int state,
    required int index,
    required String label,
    required PageController controller,
    String icon = "",
    // bool useCustomIcon = false,
    // IconData materialIcon = Icons.circle,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(index);
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
                  ? IconifyIcon(
                      icon: icon,
                      color: index == 1 ? MyColors.primary : MyColors.primary)
                  : IconifyIcon(icon: icon, color: Colors.grey)),
              // useCustomIcon
              //     ? FaIcon(
              //         materialIcon,
              //         color: state == index ? MyColors.primary : Colors.grey,
              //         size: 24,
              //       )
              //     : (state == index
              //         ? IconifyIcon(
              //             icon: icon,
              //             color:
              //                 index == 1 ? MyColors.primary : MyColors.primary)
              //         : IconifyIcon(icon: icon, color: Colors.grey)),
              if (state == index)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: MyTextStyle.bottomNavEnabledTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> getDataFromPrefs() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool('user_loggedIn') ?? false;

    return loggedIn;
  }
}
