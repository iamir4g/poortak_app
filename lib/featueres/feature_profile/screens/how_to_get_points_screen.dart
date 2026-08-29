import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/common/widgets/invite_friends_modal.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class HowToGetPointsScreen extends StatelessWidget {
  static const routeName = '/how_to_get_points_screen';

  const HowToGetPointsScreen({super.key});

  static const _methods = [
    _ScoreGuideMethod(
      title: MyTextStyle.scoreGuideMembershipTitle,
      points: MyTextStyle.scoreGuideMembershipPoints,
      description: MyTextStyle.scoreGuideMembershipDescription,
      lightBackgroundColor: MyColors.scoreGuideMembershipCardLight,
    ),
    _ScoreGuideMethod(
      title: MyTextStyle.scoreGuidePurchaseTitle,
      points: MyTextStyle.scoreGuidePurchasePoints,
      description: MyTextStyle.scoreGuidePurchaseDescription,
      lightBackgroundColor: MyColors.scoreGuidePurchaseCardLight,
    ),
    _ScoreGuideMethod(
      title: MyTextStyle.scoreGuidePackageTitle,
      points: MyTextStyle.scoreGuidePackagePoints,
      description: MyTextStyle.scoreGuidePackageDescription,
      lightBackgroundColor: MyColors.scoreGuidePackageCardLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: MyColors.scoreGuidePageBackground(isDark),
      appBar: PoortakAppBar(
        title: MyTextStyle.scoreGuideScreenTitle,
        titleStyle: MyTextStyle.scoreGuideAppBarTitleFor(isDark),
        foregroundColor: MyColors.scoreGuideAppBarForeground(isDark),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildCoinAnimation(),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    for (var i = 0; i < _methods.length; i++) ...[
                      if (i > 0) SizedBox(height: 13.h),
                      _MethodCard(
                        method: _methods[i],
                        isDark: isDark,
                      ),
                    ],
                    SizedBox(height: 13.h),
                    _InviteFriendsCard(isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinAnimation() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 145.h,
        maxWidth: 267.w,
      ),
      child: Lottie.asset(
        'assets/images/points/coin.json',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ScoreGuideMethod {
  final String title;
  final String points;
  final String description;
  final Color lightBackgroundColor;

  const _ScoreGuideMethod({
    required this.title,
    required this.points,
    required this.description,
    required this.lightBackgroundColor,
  });
}

class _MethodCard extends StatelessWidget {
  final _ScoreGuideMethod method;
  final bool isDark;

  const _MethodCard({
    required this.method,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColors.scoreGuideCardBackground(isDark, method.lightBackgroundColor),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  method.title,
                  style: MyTextStyle.scoreGuideCardTitleFor(isDark),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12.w),
              _PointsBadge(points: method.points, isDark: isDark),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            method.description,
            style: MyTextStyle.scoreGuideCardDescriptionFor(isDark),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _InviteFriendsCard extends StatelessWidget {
  final bool isDark;

  const _InviteFriendsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColors.scoreGuideCardBackground(
          isDark,
          MyColors.scoreGuideInviteCardLight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  MyTextStyle.scoreGuideInviteTitle,
                  style: MyTextStyle.scoreGuideCardTitleFor(isDark),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(width: 12.w),
              _PointsBadge(
                points: MyTextStyle.scoreGuideInvitePoints,
                isDark: isDark,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            MyTextStyle.scoreGuideInviteDescription,
            style: MyTextStyle.scoreGuideCardDescriptionFor(isDark),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 16.h),
          Center(
            child: SizedBox(
              width: 254.w,
              height: 60.h,
              child: ElevatedButton(
                onPressed: () => InviteFriendsModal.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      MyColors.scoreGuideInviteButtonBackground(isDark),
                  disabledBackgroundColor: MyColors.scoreGuideInviteButtonLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  MyTextStyle.scoreGuideInviteButton,
                  style: MyTextStyle.scoreGuideInviteButtonFor(isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  final String points;
  final bool isDark;

  const _PointsBadge({
    required this.points,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: MyColors.scoreGuidePointsBadgeBackground(isDark),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        points,
        style: MyTextStyle.scoreGuidePointsBadgeFor(isDark),
      ),
    );
  }
}
