import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/widgets/invite_friends_modal.dart';

class HowToGetPointsScreen extends StatefulWidget {
  static const routeName = "/how_to_get_points_screen";

  const HowToGetPointsScreen({super.key});

  @override
  State<HowToGetPointsScreen> createState() => _HowToGetPointsScreenState();
}

class _HowToGetPointsScreenState extends State<HowToGetPointsScreen> {
  @override
  void initState() {
    super.initState();
    // Status bar is managed centrally in MainWrapper
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? MyColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDarkMode),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Coin animation
                    _buildCoinAnimation(),

                    SizedBox(height: 20.h),

                    // Method cards
                    _buildMethodCards(isDarkMode),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      height: 57.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(33.5.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            offset: Offset(0, 1.h),
            blurRadius: 1.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'روش های کسب امتیاز',
            style: MyTextStyle.textMatn15.copyWith(
              color: isDarkMode
                  ? MyColors.darkTextPrimary
                  : const Color(0xFF29303D),
            ),
            textAlign: TextAlign.center,
          ),

          // Back Button
          Container(
            width: 50.r,
            height: 50.r,
            margin: EdgeInsets.only(left: 16.w),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_forward,
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF3D495C),
                size: 20.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinAnimation() {
    return SizedBox(
      height: 145.h,
      width: 267.w,
      child: Lottie.asset(
        'assets/images/points/coin.json',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMethodCards(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Method 1: App membership
          _buildMethodCard(
            isDarkMode: isDarkMode,
            title: 'عضویت در اپلیکیشن',
            points: '۵ سکه',
            description:
                'با ثبت شماره تماس خود در اپلیکیشن ۵ سکه دریافت میکنید.',
            backgroundColor: isDarkMode
                ? MyColors.darkCardBackground
                : const Color(0xFFFDF4F2),
            height: 95.h,
          ),

          SizedBox(height: 13.h),

          // Method 2: App purchase
          _buildMethodCard(
            isDarkMode: isDarkMode,
            title: 'خرید از اپلیکیشن',
            points: '۵ سکه',
            description: 'با هر خرید از اپلیکیشن ۵ سکه دریافت میکنید.',
            backgroundColor: isDarkMode
                ? MyColors.darkCardBackground
                : const Color(0xFFE9EFFF),
            height: 86.h,
          ),

          SizedBox(height: 13.h),

          // Method 3: Complete package purchase
          _buildMethodCard(
            isDarkMode: isDarkMode,
            title: 'خرید بسته کامل سیاره آی نو',
            points: '۵۰ سکه',
            description:
                'با خرید بسته ی کامل سیاره آی نو ۱۰ سکه دریافت میکنید.',
            backgroundColor: isDarkMode
                ? MyColors.darkCardBackground
                : const Color(0xFFFFF9EB),
            height: 86.h,
          ),

          SizedBox(height: 13.h),

          // Method 4: Invite friends
          _buildInviteFriendsCard(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required bool isDarkMode,
    required String title,
    required String points,
    required String description,
    required Color backgroundColor,
    required double height,
  }) {
    return Container(
      width: 360.w,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: MyTextStyle.textMatn16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : const Color(0xFF29303D),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                SizedBox(width: 16.w),

                // Points
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    points,
                    style: MyTextStyle.textMatn16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF29303D),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Description
            Text(
              description,
              style: MyTextStyle.textMatn10W300.copyWith(
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF3D495C),
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteFriendsCard(bool isDarkMode) {
    return Container(
      width: 360.w,
      height: 193.h,
      decoration: BoxDecoration(
        color:
            isDarkMode ? MyColors.darkCardBackground : const Color(0xFFF2FDF7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Text(
                    'دعوت از دوستان',
                    style: MyTextStyle.textMatn16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : const Color(0xFF29303D),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                SizedBox(width: 16.w),

                // Points
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    '۱۰ سکه',
                    style: MyTextStyle.textMatn16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF29303D),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Description
            Text(
              'با ارائه کد معرف به دوستان خود با ورود هریک به اپلیکیشن و انجام خرید، هر کدام ۱۰ امتیاز به دست می آورید.',
              style: MyTextStyle.textMatn10W300.copyWith(
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF3D495C),
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),

            SizedBox(height: 16.h),

            // Button inside the card
            Center(
              child: GestureDetector(
                onTap: () {
                  InviteFriendsModal.show(context);
                },
                child: Container(
                  width: 254.w,
                  height: 60.h,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF59E59A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'دعوت از دوستان',
                      style: MyTextStyle.textMatn15.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
