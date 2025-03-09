import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/bottom_nav_cubit/bottom_nav_cubit.dart';

// import '../../features/feature_auth/presentation/screens/mobile_signup_screen.dart';

class BottomNav extends StatelessWidget {
  final PageController controller;

  const BottomNav({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    TextTheme textTheme = Theme.of(context).textTheme;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      color: Colors.white,
      child: SizedBox(
        height: 64,
        child: BlocBuilder<BottomNavCubit, int>(
          builder: (context, int state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        /// change selected index
                        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(0);
                        controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      icon: state == 0 ? FaIcon(FontAwesomeIcons.video,color: Colors.amber,) : FaIcon(FontAwesomeIcons.video,color: Colors.grey),

                    ),
                    Text(

                      state == 0 ? 'کاوش' : '',
                      style: TextStyle(fontSize: 14,fontFamily: 'Yekan',color: Colors.grey.shade700),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(1);
                          controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        icon: state == 1 ? FaIcon(FontAwesomeIcons.searchengin,color: Colors.amber) : FaIcon(FontAwesomeIcons.searchengin,color: Colors.grey,)
                    ),
                    Text(
                      state == 1 ?'دسته بندی' :'',
                      style: TextStyle(fontSize: 14,fontFamily: 'Yekan',color: Colors.grey.shade700),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(2);
                        controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      // icon: SvgPicture.asset(state == 2 ? "assets/images/person_icon.svg" : "assets/images/person_icon2.svg", color: state == 2 ? Colors.red : Colors.grey.shade700,width: 48,),
                      icon: state == 2 ? FaIcon(Icons.shopping_cart_outlined,color: Colors.amber,) : FaIcon(Icons.shopping_cart_outlined,color: Colors.grey,),

                    ),
                    // Text(
                    //   state == 2 ? 'سبد خرید' : '',
                    //   style: TextStyle(fontSize: 14,fontFamily: 'Yekan',color: Colors.grey.shade700),
                    // ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(3);
                          controller.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        icon: FaIcon(
                          state == 3
                              ? Icons.folder_outlined
                              : Icons.folder_outlined,
                          color: state == 3 ? Colors.amber : Colors.grey,
                          size: 27,
                        )
                    ),
                    // Text(
                    //   state == 3
                    //       ?'سبد خرید' : '',
                    //   style: TextStyle(fontSize: 14,fontFamily: 'Yekan',color: Colors.grey.shade700),
                    // ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(4);
                          controller.animateToPage(4, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        icon: FaIcon(
                          state == 4
                              ? Icons.account_box_outlined
                              : Icons.account_box_outlined,
                          color: state == 4 ? Colors.amber : Colors.grey,
                          size: 27,
                        )
                    ),
                    // Text(
                    //   state == 4
                    //       ?'پروفایل':'',
                    //   style: TextStyle(fontSize: 14,fontFamily: 'Yekan',color: Colors.grey.shade700),
                    // ),
                  ],
                ),
              ],
            );
          },
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