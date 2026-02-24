import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_match/screens/match_screen.dart';

class MainMatchScreen extends StatelessWidget {
  static const routeName = '/main_match_screen';
  const MainMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF5F0), // Light orange
              Color(0xFFFBFDF2), // Light green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                height: 57.h,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      'مسابقه پورتک',
                      style: MyTextStyle.textHeader16Bold.copyWith(
                        color: MyColors.textMatn2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Back Button
                    Container(
                      width: 50.w,
                      height: 50.h,
                      margin: EdgeInsets.only(left: 16.w),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_forward,
                          color: MyColors.textMatn1,
                          size: 20.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),

                      // Match Option Cards
                      _buildMatchCard(
                        iconLottiePath: 'assets/images/match/questions.json',
                        title: 'شرکت در مسابقه',
                        onTap: () {
                          // Navigate to join match screen
                          Navigator.pushNamed(context, MatchScreen.routeName);
                        },
                      ),

                      SizedBox(height: 20.h),

                      _buildMatchCard(
                        iconLottiePath: 'assets/images/match/prize.json',
                        title: 'جوایز مسابقه',
                        onTap: () {
                          // Navigate to prizes screen
                          _showComingSoonDialog(context);
                        },
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard({
    required String iconLottiePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 350.w,
        height: 162.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              offset: const Offset(0, 0),
              blurRadius: 4.r,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: MyColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                iconLottiePath,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 16.h),

            // Title
            Text(
              title,
              style: MyTextStyle.textMatn16.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF29303D),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'به زودی',
            style: MyTextStyle.textMatn18Bold.copyWith(
              color: MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'این بخش به زودی راه‌اندازی خواهد شد.',
            style: MyTextStyle.textMatn14Bold.copyWith(
              fontWeight: FontWeight.normal,
              color: MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                ),
                child: Text(
                  'متوجه شدم',
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
