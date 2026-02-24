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
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: MyColors.background3,
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
                        clipper: MyClipper(),
                        child: Container(
                          height: 300.h, //double.infinity - 500,
                          color: Colors.white,
                        ),
                      ),
                      // Content
                      Column(
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
                                    color: const Color(0xFFE6EBF2), width: 5.r),
                                color: Colors.white,
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
                              color: MyColors.textCancelButton,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // Mobile
                          Text(
                            ' موبایل: ${userMobile ?? 'نامشخص'}',
                            style: MyTextStyle.textMatn12Bold.copyWith(
                              color: MyColors.text3,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 16.h),
                            child: Center(
                              child: SizedBox(
                                width: 180.w,
                                height: 42.h,
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
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Custom edit icon - using a simple icon for now
                                      // You can replace this with the actual SVG from Figma
                                      Container(
                                        width: 16.r,
                                        height: 16.r,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFA3AFC2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 10.r,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'ویرایش حساب',
                                        style: MyTextStyle.textMatn11.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: MyColors.text3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // const Spacer(),
                          SizedBox(height: 80.h),
                          // Padding(
                          // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          // child:
                          Column(
                            children: [
                              _ProfileActionCard(
                                icon: Icons.star,
                                label: 'امتیازات',
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    MainPointsScreen.routeName,
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),
                              _ProfileActionCard(
                                icon: Icons.history,
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
                              _ProfileActionCard(
                                icon: Icons.bookmark,
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
                          // ),
                        ],
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

class _ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84.h,
      width: 357.838.w,
      margin: EdgeInsets.symmetric(horizontal: 17.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFFB200), size: 32.r),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    label,
                    style: MyTextStyle.textMatn16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: MyColors.textCancelButton,
                      height: 1.375, // 22px line height for 16px font
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top-left
    path.moveTo(0, 0);

    // Go to top-right
    path.lineTo(size.width, 0);

    // Go to bottom-right
    path.lineTo(size.width, size.height - 50.h);

    // Create the concave curve at the bottom
    path.quadraticBezierTo(
      size.width * 0.5, // Control point x (center)
      size.height +
          30.h, // Control point y (below the bottom for concave effect)
      size.width * 0.2, // End point x (20% from left)
      size.height - 20.h, // End point y
    );

    // Continue the curve to the left
    path.quadraticBezierTo(
      size.width * 0.05, // Control point x (5% from left)
      size.height - 45.h, // Control point y
      0, // End point x (left edge)
      size.height - 50.h, // End point y
    );

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
