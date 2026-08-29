import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class LeaderboardScreen extends StatelessWidget {
  static const routeName = '/leaderboard_screen';

  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PoortakAppBar(
        title: 'اسامی برندگان مسابقه',
        foregroundColor: MyColors.textMatn2,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7E4), // #fff7e4 - light cream background
              Color(0xFFFFF7E4), // Same color for gradient
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Leaderboard List
              Expanded(
                child: _buildLeaderboardList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Month label - مهر ۱۴۰۳
            Container(
              width: 350.w,
              margin: EdgeInsets.only(bottom: 28.h),
              child: Text(
                'مهر ۱۴۰۳',
                textAlign: TextAlign.right,
                style: MyTextStyle.textMatn13.copyWith(
                  fontWeight: FontWeight.w500,
                  color: MyColors.textMatn1,
                ),
              ),
            ),

            // Winner cards for مهر ۱۴۰۳
            ...List.generate(
                10,
                (index) => _buildWinnerCard(
                      name: 'حسین رادمهر',
                      phoneNumber: '۰۹۱۲****۳۸۶',
                    )),

            // Month label - شهریور ۱۴۰۳
            Container(
              width: 350.w,
              margin: EdgeInsets.only(top: 28.h, bottom: 28.h),
              child: Text(
                'شهریور ۱۴۰۳',
                textAlign: TextAlign.right,
                style: MyTextStyle.textMatn13.copyWith(
                  fontWeight: FontWeight.w500,
                  color: MyColors.textMatn1,
                ),
              ),
            ),

            // Winner cards for شهریور ۱۴۰۳
            ...List.generate(
                10,
                (index) => _buildWinnerCard(
                      name: 'حسین رادمهر',
                      phoneNumber: '۰۹۱۲****۳۸۶',
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard({required String name, required String phoneNumber}) {
    return Container(
      width: 350.w,
      height: 50.h,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: Offset(0, 2.h),
            blurRadius: 7.3.r,
          ),
        ],
      ),
      child: Row(
        children: [
          // Phone number (left side)
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 20.w),
              child: Text(
                phoneNumber,
                textAlign: TextAlign.center,
                style: MyTextStyle.textMatn14Bold.copyWith(
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Name (right side)
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 20.w),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: MyTextStyle.textMatn14Bold.copyWith(
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
