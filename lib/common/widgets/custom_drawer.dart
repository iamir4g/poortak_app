import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/featureMenu/screens/aboutUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/faq_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/contactUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/settings_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/main_reminder.dart';
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

  static const Map<String, String> _drawerIconAssets = {
    'tdesign:edit': 'assets/images/icons/tdesign--edit.svg',
    'famicons:sun': 'assets/images/icons/famicons--sunny-outline.svg',
    'famicons:moon': 'assets/images/icons/famicons--moon.svg',
    'ic:baseline-more-time': 'assets/images/icons/ic--baseline-more-time.svg',
    'famicons:settings-outline':
        'assets/images/icons/famicons--settings-outline.svg',
    'ph:chat-dots-light': 'assets/images/icons/ph--chat-dots-light.svg',
    'lsicon:circle-more-outline':
        'assets/images/icons/lsicon--circle-more-outline.svg',
    'ion:call-outline': 'assets/images/icons/ion--call-outline.svg',
    'material-symbols-light:info-outline-rounded':
        'assets/images/icons/material-symbols--info-outline-rounded.svg',
    'mynaui:share': 'assets/images/icons/mynaui--share.svg',
    'fluent:heart-28-regular':
        'assets/images/icons/fluent--heart-28-regular.svg',
  };

  Widget _buildDrawerIcon({
    required String icon,
    required double size,
    required Color color,
  }) {
    final assetPath = _drawerIconAssets[icon];
    if (assetPath == null) {
      return Icon(
        Icons.help_outline_rounded,
        size: size,
        color: color,
      );
    }

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

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
            width: Dimens.iconLarge,
            height: Dimens.iconLarge,
            decoration: BoxDecoration(
              color: themeState.isDark
                  ? MyColors.darkCardBackground
                  : MyColors.background1,
              borderRadius: BorderRadius.circular(Dimens.radiusCircle),
            ),
            child: Center(
              child: _buildDrawerIcon(
                size: Dimens.iconSmall,
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
        final backgroundColor =
            themeState.isDark ? MyColors.darkBackground : Colors.white;
        final statusBarHeight = MediaQuery.of(context).padding.top;

        return Drawer(
          backgroundColor: backgroundColor,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            child: Stack(
              children: [
                // پس‌زمینه کامل که تا بالای صفحه می‌رود
                Positioned.fill(
                  child: Container(
                    color: backgroundColor,
                  ),
                ),
                // محتوای دراور
                Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight,
                    left: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  child: Column(
                    children: [
                      // Drawer content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.medium,
                            vertical: Dimens.medium,
                          ),
                          child: ListView(
                            children: [
                              SizedBox(
                                height: 100.h,
                                width: 240.w,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      top: 20.h,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (isLoggedIn) {
                                            Navigator.pushNamed(context,
                                                ProfileScreen.routeName);
                                          } else {
                                            Navigator.pushNamed(
                                                context, LoginScreen.routeName);
                                          }
                                        },
                                        child: SizedBox(
                                          height: 80.h,
                                          width: 240.w,
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(Dimens.medium),
                                            decoration: BoxDecoration(
                                              color: themeState.isDark
                                                  ? MyColors.darkCardBackground
                                                  : MyColors.background1,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                ClipOval(
                                                  child: userAvatarUrl != null
                                                      ? Image.network(
                                                          userAvatarUrl!,
                                                          width: 50.w,
                                                          height: 50.h,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            Dimens.radiusCircle),
                                                                color:
                                                                    Colors.red,
                                                                image:
                                                                    const DecorationImage(
                                                                  image:
                                                                      AssetImage(
                                                                    "assets/images/profile/finalProfile.png",
                                                                  ),
                                                                ),
                                                              ),
                                                              width: 50.w,
                                                              height: 50.h,
                                                            );
                                                          },
                                                        )
                                                      : Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius: BorderRadius
                                                                .circular(Dimens
                                                                    .radiusCircle),
                                                            // color: Colors.red,
                                                            image:
                                                                const DecorationImage(
                                                              image: AssetImage(
                                                                "assets/images/profile/finalProfile.png",
                                                              ),
                                                            ),
                                                          ),
                                                          width: 50.w,
                                                          height: 50.h,
                                                        ),
                                                ),
                                                SizedBox(width: 10.w),
                                                Text(
                                                  isLoggedIn
                                                      ? (userFirstName !=
                                                                  null &&
                                                              userLastName !=
                                                                  null
                                                          ? "$userFirstName $userLastName"
                                                          : userFirstName ??
                                                              userLastName ??
                                                              "کاربر")
                                                      : "کاربر مهمان",
                                                  style: MyTextStyle
                                                      .textMatn14Bold
                                                      .copyWith(
                                                    color: themeState.isDark
                                                        ? MyColors
                                                            .darkTextPrimary
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
                                    if (isLoggedIn)
                                      Positioned(
                                        top: 10.h,
                                        left: 20.w,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                ProfileScreen.routeName);
                                          },
                                          child: Container(
                                            width: 30.w,
                                            height: 30.h,
                                            decoration: BoxDecoration(
                                              color: MyColors.secondary,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimens.radiusCircle),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2.w,
                                              ),
                                            ),
                                            child: Center(
                                              child: _buildDrawerIcon(
                                                icon: "tdesign:edit",
                                                color: Colors.white,
                                                size: 12.w,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                              SizedBox(height: 20.h),
                              ListTile(
                                onTap: () {
                                  context.read<ThemeCubit>().toggleTheme();
                                },
                                leading: Container(
                                  width: Dimens.iconLarge,
                                  height: Dimens.iconLarge,
                                  decoration: BoxDecoration(
                                    color: themeState.isDark
                                        ? MyColors.darkCardBackground
                                        : MyColors.background1,
                                    borderRadius: BorderRadius.circular(
                                        Dimens.radiusCircle),
                                  ),
                                  child: Center(
                                    child: _buildDrawerIcon(
                                      size: Dimens.iconSmall,
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
                                  activeTrackColor: MyColors.gray,
                                  inactiveTrackColor: MyColors.gray,
                                  inactiveThumbColor: Colors.white,
                                  activeThumbColor: MyColors.primary,
                                  trackOutlineColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                ),
                              ),
                              _buildListTile(
                                icon: "ic:baseline-more-time",
                                title: "یادآور مطالعه",
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ReminderScreen.routeName);
                                },
                              ),
                              _buildListTile(
                                icon: "famicons:settings-outline",
                                title: "تنظیمات",
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, SettingsScreen.routeName);
                                },
                              ),
                              _buildListTile(
                                icon: "ph:chat-dots-light",
                                title: "سوالات رایج",
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, FAQScreen.routeName);
                                },
                              ),
                              _buildListTile(
                                icon: "lsicon:circle-more-outline",
                                title: "پشتیبانی",
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("به زودی"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              _buildListTile(
                                icon: "ion:call-outline",
                                title: "تماس با ما",
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ContactUsScreen.routeName);
                                },
                              ),
                              _buildListTile(
                                icon:
                                    "material-symbols-light:info-outline-rounded",
                                title: "درباره ی ما",
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AboutUsScreen.routeName);
                                },
                              ),
                              _buildListTile(
                                icon: "mynaui:share",
                                title: "اشتراک گذاری به دوستان",
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("به زودی."),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              _buildListTile(
                                icon: "fluent:heart-28-regular",
                                title: "ثبت نظر درباره برنامه",
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("به زودی."),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
