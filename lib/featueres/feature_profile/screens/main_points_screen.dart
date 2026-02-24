import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/myTextStyle.dart';

class MainPointsScreen extends StatefulWidget {
  static const routeName = "/main_points_screen";

  const MainPointsScreen({super.key});

  @override
  State<MainPointsScreen> createState() => _MainPointsScreenState();
}

class _MainPointsScreenState extends State<MainPointsScreen> {
  @override
  void initState() {
    super.initState();
    // Status bar is managed centrally in MainWrapper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                    'امتیازات',
                    style: MyTextStyle.textHeader16Bold.copyWith(
                      color: const Color(0xFF3D495C),
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
                        color: const Color(0xFF3D495C),
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
                child: Column(
                  children: [
                    // Points earned section
                    _buildPointsEarnedSection(),

                    // Points history card
                    _buildPointsHistoryCard(),

                    // Discounts and rewards card
                    _buildDiscountsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsEarnedSection() {
    return Container(
      height: 193.h,
      width: double.infinity,
      color: const Color(0xFFFBFCFE),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Subtitle text

          // Points earned text and container
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "امتیاز کسب شده:",
                    textAlign: TextAlign.right,
                    style: MyTextStyle.textMatn16Bold,
                  ),
                  Text(
                    "امتیاز کسب شده از ابتدای آموزش",
                    textAlign: TextAlign.right,
                    style: MyTextStyle.textMatn12W300,
                  ),
                ],
              ),
              SizedBox(width: 55.w),
              // const Spacer(),
              // 200 coins container
              Container(
                width: 88.w,
                height: 33.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8CC),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    "۲۰۰ سکه",
                    textAlign: TextAlign.center,
                    style: MyTextStyle.textMatn16Bold.copyWith(
                      color: const Color(0xFF28303D),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          // Ways to earn points section
          _buildWaysToEarnSection(),
        ],
      ),
    );
  }

  Widget _buildWaysToEarnSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      width: 254.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFDB80),
        borderRadius: BorderRadius.circular(20.r),
      ),
      // padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
      child: Row(
        children: [
          // Star icon
          SizedBox(
            width: 36.r,
            height: 34.r,
            child: Image.asset(
              'assets/images/points/star_icon.png',
              fit: BoxFit.contain,
            ),
          ),

          // const SizedBox(width: 31),

          // Yellow container
          Expanded(
            child: SizedBox(
              height: 60.h,
              child: Center(
                child: Text(
                  "روش های کسب امتیاز",
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHistoryCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/history_prize_screen');
      },
      child: Container(
        width: 350.w,
        height: 119.h,
        margin: EdgeInsets.symmetric(horizontal: 23.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EFFF),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 4.r,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // SizedBox(width: 20),

            // Text content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "تاریخچه امتیاز",
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn13,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "تاریخچه ی امتیازهای کسب شده خود را ببینید.",
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn10W300,
                    ),
                  ],
                ),
              ),
            ),
            // Calendar animation placeholder
            SizedBox(
              width: 100.r,
              height: 100.r,
              child: Lottie.asset(
                'assets/images/points/calendar.json',
                width: 79.r,
                height: 78.r,
                fit: BoxFit.cover,
              ),
            ),

            // const
            // const SizedBox(width: 23),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/prize_screen');
      },
      child: Container(
        width: 350.w,
        height: 119.h,
        margin: EdgeInsets.symmetric(horizontal: 23.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EB),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 4.r,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // const SizedBox(width: 20),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "تخفیف ها و جایزه",
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn13,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "جایزه سکه های جمع شده خود را مشاهده کنید.",
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn10W300,
                    ),
                  ],
                ),
              ),

              // Prize animation placeholder with background circle
              Container(
                width: 70.r,
                height: 70.r,
                // margin: const EdgeInsets.only(left: 23),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Lottie.asset(
                  'assets/images/points/prize.json',
                  width: 78.r,
                  height: 78.r,
                  fit: BoxFit.cover,
                ),
              ),

              // const SizedBox(width: 23),
            ],
          ),
        ),
      ),
    );
  }
}
