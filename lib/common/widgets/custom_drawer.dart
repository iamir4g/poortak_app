import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/featureMenu/screens/aboutUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/faq_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/contactUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/settings_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  final StorageService storageService = locator<StorageService>();
  bool isLoggedIn = false;
  String? userName;
  String? userFirstName;
  String? userLastName;
  String? userAvatar;
  String? userAvatarUrl;

  Widget _buildListTile({
    required String icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return ListTile(
          onTap: onTap,
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: themeState.isDark
                  ? MyColors.darkCardBackground
                  : MyColors.background1,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: IconifyIcon(
                size: 16,
                icon: icon,
                color: themeState.isDark
                    ? MyColors.darkTextSecondary
                    : MyColors.text3,
              ),
            ),
          ),
          title: Text(
            title,
            style: MyTextStyle.textMatn14Bold.copyWith(
              color: themeState.isDark
                  ? MyColors.darkTextPrimary
                  : MyColors.textMatn1,
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await prefsOperator.getLoggedIn();
    final name = await prefsOperator.getUserName();
    final firstName = await prefsOperator.getUserFirstName();
    final lastName = await prefsOperator.getUserLastName();
    final avatar = await prefsOperator.getUserAvatar();

    // Convert avatar ID to URL if exists
    String? avatarUrl;
    if (avatar != null && avatar.isNotEmpty) {
      avatarUrl = await storageService.callGetDownloadPublicUrl(avatar);
    }

    setState(() {
      isLoggedIn = loggedIn;
      userName = name;
      userFirstName = firstName;
      userLastName = lastName;
      userAvatar = avatar;
      userAvatarUrl = avatarUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Drawer(
          backgroundColor:
              themeState.isDark ? MyColors.darkBackground : Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
            child: ListView(
              children: [
                // const SizedBox(height: 20),
                // const SizedBox(height: 20),
                SizedBox(
                  height: 100, // افزایش ارتفاع برای جا دادن دایره نارنجی
                  width: 240,
                  child: Stack(
                    clipBehavior: Clip.none, // اجازه نمایش خارج از محدوده
                    children: [
                      Positioned(
                        top: 20, // فاصله از بالا برای جا دادن دایره
                        child: GestureDetector(
                          onTap: () {
                            if (isLoggedIn) {
                              Navigator.pushNamed(
                                  context, ProfileScreen.routeName);
                            } else {
                              Navigator.pushNamed(
                                  context, LoginScreen.routeName);
                            }
                          },
                          child: SizedBox(
                            height: 80,
                            width: 240,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeState.isDark
                                    ? MyColors.darkCardBackground
                                    : MyColors.background1,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipOval(
                                    child: userAvatarUrl != null
                                        ? Image.network(
                                            userAvatarUrl!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: Colors.red,
                                                  image: const DecorationImage(
                                                    image: AssetImage(
                                                      "assets/images/profile/finalProfile.png",
                                                    ),
                                                  ),
                                                ),
                                                width: 50,
                                                height: 50,
                                              );
                                            },
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.red,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                  "assets/images/profile/finalProfile.png",
                                                ),
                                              ),
                                            ),
                                            width: 50,
                                            height: 50,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isLoggedIn
                                        ? (userFirstName != null &&
                                                userLastName != null
                                            ? "$userFirstName $userLastName"
                                            : userFirstName ??
                                                userLastName ??
                                                "کاربر")
                                        : "وارد شوید",
                                    style: MyTextStyle.textMatn14Bold.copyWith(
                                      color: themeState.isDark
                                          ? MyColors.darkTextPrimary
                                          : MyColors.textMatn1,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Edit button positioned above the container
                      if (!isLoggedIn)
                        Positioned(
                          top: 10,
                          left: 20,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, ProfileScreen.routeName);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: MyColors.secondary,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: IconifyIcon(
                                  icon: "tdesign:edit",
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                ListTile(
                  onTap: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: themeState.isDark
                          ? MyColors.darkCardBackground
                          : MyColors.background1,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: IconifyIcon(
                        size: 16,
                        icon: themeState.isDark
                            ? "famicons:sun"
                            : "famicons:moon",
                        color: themeState.isDark
                            ? MyColors.darkTextAccent
                            : MyColors.text3,
                      ),
                    ),
                  ),
                  title: Text(
                    themeState.isDark ? "حالت روز" : "حالت شب",
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: themeState.isDark
                          ? MyColors.darkTextPrimary
                          : MyColors.textMatn1,
                    ),
                  ),
                  trailing: Switch(
                    value: themeState.isDark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    activeColor: MyColors.primary,
                    activeTrackColor: MyColors.primaryTint1,
                    inactiveThumbColor: MyColors.textSecondary,
                    inactiveTrackColor: MyColors.background1,
                  ),
                ),
                _buildListTile(
                  icon: "ic:baseline-more-time",
                  title: "یادآور مطالعه",
                ),
                _buildListTile(
                  icon: "famicons:settings-outline",
                  title: "تنظیمات",
                  onTap: () {
                    Navigator.pushNamed(context, SettingsScreen.routeName);
                  },
                ),
                _buildListTile(
                  icon: "ph:chat-dots-light",
                  title: "سوالات رایج",
                  onTap: () {
                    Navigator.pushNamed(context, FAQScreen.routeName);
                  },
                ),
                _buildListTile(
                  icon: "lsicon:circle-more-outline",
                  title: "پشتیبانی",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("به زودی")),
                    );
                    // Navigator.pushNamed(context, PaymentResultScreen.routeName,
                    //     arguments: {
                    //       'status': 0,
                    //       'ref': '1234567890',
                    //     });
                  },
                ),
                _buildListTile(
                  icon: "ion:call-outline",
                  title: "تماس با ما",
                  onTap: () {
                    Navigator.pushNamed(context, ContactUsScreen.routeName);
                  },
                ),
                _buildListTile(
                  icon: "material-symbols-light:info-outline-rounded",
                  title: "درباره ی ما",
                  onTap: () {
                    Navigator.pushNamed(context, AboutUsScreen.routeName);
                  },
                ),
                _buildListTile(
                  icon: "mynaui:share",
                  title: "اشتراک گذاری به دوستان",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("به زودی.")),
                    );
                    // Navigator.pushNamed(context, PaymentResultScreen.routeName,
                    //     arguments: {
                    //       'status': 1,
                    //       'ref': '1234567890',
                    //     });
                  },
                ),
                _buildListTile(
                  icon: "fluent:heart-28-regular",
                  title: "ثبت نظر درباره برنامه",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("به زودی.")),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
