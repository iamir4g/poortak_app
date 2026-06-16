import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/screens/favorit_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/main_points_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/payment_history_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/edit_profile_screen.dart';
import 'package:poortak/common/widgets/custom_concave_clipper.dart';
import 'package:poortak/featueres/feature_profile/widgets/profile_action_card.dart';
import 'package:poortak/locator.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "/profile_screen";
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  final StorageService storageService = locator<StorageService>();
  bool isLoggedIn = false;
  String? userFirstName;
  String? userLastName;
  String? userAvatar;
  String? userMobile;
  String? userAvatarUrl;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await prefsOperator.getLoggedIn();
    if (loggedIn) {
      // Load user profile data
      final firstName = await prefsOperator.getUserFirstName();
      final lastName = await prefsOperator.getUserLastName();
      final avatar = await prefsOperator.getUserAvatar();
      final mobile = await prefsOperator.getUserName();

      // Convert avatar ID to URL if exists
      String? avatarUrl;
      if (avatar != null && avatar.isNotEmpty) {
        avatarUrl = await storageService.callGetDownloadPublicUrl(avatar);
      }

      setState(() {
        isLoggedIn = loggedIn;
        userFirstName = firstName;
        userLastName = lastName;
        userAvatar = avatar;
        userAvatarUrl = avatarUrl;
        userMobile = mobile;
      });
    } else {
      setState(() {
        isLoggedIn = loggedIn;
      });
    }
    print("token: ${await prefsOperator.getAccessToken()}");
  }

  String _getDisplayName() {
    if (userFirstName != null && userLastName != null) {
      return "$userFirstName $userLastName";
    } else if (userFirstName != null) {
      return userFirstName!;
    } else if (userLastName != null) {
      return userLastName!;
    } else {
      return "کاربر";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? MyColors.profileBackgroundDark : MyColors.background3;
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Left and right brand secondary strips
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Curved white background
                      ClipPath(
                        clipper: CustomConcaveClipper(
                            curveDepth: 10, bottomOffset: 20),
                        child: Container(
                          height: 280.h, //double.infinity - 500,
                          color: isDark
                              ? MyColors.profileHeaderDark
                              : Colors.white,
                        ),
                      ),
                      // Content
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 24.h),
                            // Avatar
                            Center(
                              child: Container(
                                width: 94.r,
                                height: 94.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? MyColors.profileAvatarBorderDark
                                        : const Color(0xFFE6EBF2),
                                    width: 5.r,
                                  ),
                                  color: Colors.transparent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4.r,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: userAvatarUrl != null
                                      ? Image.network(
                                          userAvatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/profile/finalProfile.png',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/profile/finalProfile.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // Name
                            Text(
                              _getDisplayName(),
                              style: MyTextStyle.textMatn16Bold.copyWith(
                                color: isDark
                                    ? MyColors.profileTextPrimaryDark
                                    : MyColors.textCancelButton,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Mobile
                            Text(
                              ' موبایل: ${userMobile ?? 'نامشخص'}',
                              style: MyTextStyle.textMatn12Bold.copyWith(
                                color: isDark
                                    ? MyColors.profileTextPrimaryDark
                                    : MyColors.text3,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 16.h),
                              child: Center(
                                child: SizedBox(
                                  width: 190.w,
                                  height: 48.h,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        EditProfileScreen.routeName,
                                      ).then((_) {
                                        // Refresh profile data when returning from edit screen
                                        _checkLoginStatus();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: const Color(0xFFE0E4EB),
                                          width: 2.r),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Custom edit icon - using a simple icon for now
                                        // You can replace this with the actual SVG from Figma
                                        Container(
                                          width: 16.r,
                                          height: 16.r,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? MyColors
                                                    .loginIconContainerDark
                                                : MyColors.background,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(2.r),
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            color: isDark
                                                ? MyColors.loginTextPrimaryDark
                                                : MyColors.text3,
                                            size: 10.r,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'ویرایش حساب',
                                          style:
                                              MyTextStyle.textMatn11.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? MyColors
                                                    .profileTextPrimaryDark
                                                : MyColors.text3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // const Spacer(),
                            SizedBox(height: 40.h),
                            // Padding(
                            // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            // child:
                            Column(
                              children: [
                                ProfileActionCard(
                                  iconAssetPath:
                                      'assets/images/profile/icon_star.png',
                                  label: 'امتیازات',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      MainPointsScreen.routeName,
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),
                                ProfileActionCard(
                                  iconAssetPath:
                                      'assets/images/profile/icon_history.png',
                                  label: 'تاریخچه خرید',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PaymentHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),
                                ProfileActionCard(
                                  iconAssetPath:
                                      'assets/images/profile/icon_bookmark.png',
                                  label: 'علاقه مندی ها',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      FavoritScreen.routeName,
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right strip
                // Container(
                //   width: 20,
                //   height: double.infinity,
                //   color: MyColors.brandSecondary,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
