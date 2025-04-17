import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/bloc/storage/storage_bloc.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/widgets/bottom_nav.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/bloc_storage_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/sayareh_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/screens/shopping_cart_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/bloc/permission/permission_bloc.dart';

class MainWrapper extends StatelessWidget {
  static const routeName = "/main_wrapper";
  MainWrapper({super.key});

  // Using late init to ensure PageController is created only once
  final PageController controller = PageController();

  // Define screens as getters to ensure they're created when needed
  List<Widget> get topLevelScreens => [
        const SayarehScreen(),
        Container(
          color: Colors.blue,
        ),
        const ShoppingCartScreen(),
        Container(
          color: Colors.yellow,
        ),
        const ProfileScreen(),
        // Container(
        //   color: Colors.purple,
        // ),
      ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(
        //   create: (context) => StorageBloc(
        //     storageService: locator<StorageService>(),
        //   ),
        // ),
        BlocProvider(
          create: (context) => BlocStorageBloc(
            sayarehRepository: locator<SayarehRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => locator<PermissionBloc>(),
        ),
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
                // bottom: PreferredSize(
                //   preferredSize: const Size.fromHeight(150.0),
                //   child: Container(
                //     height: 57,
                //     // width: 100,
                //     color: Colors.white,
                //     alignment: Alignment.center,
                //     child: const Text('Some content'),
                //   ),
                // ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30.0),
                    ),
                    // gradient: LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    //   colors: [
                    //     Color(0xFF72326a),
                    //     Color(0xFF321c53),
                    //   ],
                    // ),
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30.0),
                  ),
                ),
                // title: Text("Poortak"),
                // actions: [
                //   IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                // ],
              ),
              drawer: Drawer(
                backgroundColor: Colors.white,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 80,
                      width: 240,
                      child: Container(
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              color: Colors.red,
                            ),
                            Text(
                              "امیر فراهانی",
                              style: MyTextStyle.textMatn14Bold,
                            )
                          ],
                        ),
                      ),
                    ),
                    // ListTile(
                    //   title: Text("Profile"),
                    // ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            icon: "famicons:moon",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "حالت شب",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            icon: "ic:baseline-more-time",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "یادآور مطالعه",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            icon: "famicons:settings-outline",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "تنظیمات",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            icon: "ph:chat-dots-light",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "سوالات رایج",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            size: 18.0,
                            icon: "lsicon:circle-more-outline",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "پشتیبانی",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            icon: "ion:call-outline",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "تماس با ما",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                    // ListTile(
                    //   leading: IconifyIcon(icon: "tdesign:moon"),
                    //   title: Text("Settings"),
                    // ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            icon: "material-symbols-light:info-outline-rounded",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "درباره ی ما",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MyColors.background1,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconifyIcon(
                            icon: "mynaui:share",
                            color: MyColors.text3,
                          ),
                        ),
                      ),
                      title: Text(
                        "اشتراک گذاری به دوستان",
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: BottomNav(controller: controller),
              body: state is PermissionLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView(controller: controller, children: topLevelScreens),
            );
          },
        ),
      ),
    );
  }
}
