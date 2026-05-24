import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_match/screens/match_screen.dart';
import 'package:poortak/featueres/feature_match/screens/prize_screen.dart';

class MainMatchScreen extends StatelessWidget {
  static const routeName = '/main_match_screen';
  const MainMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF171926),
                    MyColors.darkBackground,
                    Color(0xFF171926),
                  ],
                  stops: [0.1, 0.54, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF5F0),
                    Color(0xFFFBFDF2),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                height: Dimens.nh(57),
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: Dimens.medium),
                decoration: BoxDecoration(
                  color:
                      isDark ? MyColors.darkBackgroundSecondary : Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Dimens.nr(33.5)),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0x0D000000),
                            offset: Offset(0, Dimens.nh(1)),
                            blurRadius: Dimens.nr(1),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Flexible(
                      child: Text(
                        'مسابقه پورتک',
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: isDark
                              ? MyColors.darkTextPrimary
                              : MyColors.textMatn2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Back Button
                    Container(
                      width: Dimens.nw(50),
                      height: Dimens.nh(50),
                      margin: EdgeInsets.only(left: Dimens.medium),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_forward,
                          color: isDark
                              ? MyColors.darkTextPrimary
                              : MyColors.textMatn1,
                          size: Dimens.nr(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.nw(20),
                    vertical: Dimens.nh(20),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: Dimens.nh(20)),

                      // Match Option Cards
                      _buildMatchCard(
                        iconLottiePath: 'assets/images/match/questions.json',
                        title: 'شرکت در مسابقه',
                        isDark: isDark,
                        onTap: () {
                          // Navigate to join match screen
                          Navigator.pushNamed(context, MatchScreen.routeName);
                        },
                      ),

                      SizedBox(height: Dimens.nh(20)),

                      _buildMatchCard(
                        iconLottiePath: 'assets/images/match/prize.json',
                        title: 'جوایز مسابقه',
                        isDark: isDark,
                        onTap: () {
                          // Navigate to prizes screen
                          Navigator.pushNamed(
                              context, MatchPrizeScreen.routeName);
                        },
                      ),

                      SizedBox(height: Dimens.nh(40)),
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
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: Dimens.nh(162)),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.medium,
          vertical: Dimens.medium,
        ),
        decoration: BoxDecoration(
          color: isDark ? MyColors.termsBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(Dimens.nr(20)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0x0A000000),
                    offset: const Offset(0, 0),
                    blurRadius: Dimens.nr(4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: Dimens.nr(80),
              height: Dimens.nr(80),
              decoration: BoxDecoration(
                color: MyColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                iconLottiePath,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: Dimens.nh(16)),

            // Title
            Text(
              title,
              style: MyTextStyle.textMatn16.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? MyColors.darkTextPrimary : MyColors.text1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? MyColors.termsBackgroundDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.nr(20)),
          ),
          title: Flexible(
            child: Text(
              'به زودی',
              style: MyTextStyle.textMatn18Bold.copyWith(
                color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'این بخش به زودی راه‌اندازی خواهد شد.',
              style: MyTextStyle.textMatn14Bold.copyWith(
                fontWeight: FontWeight.normal,
                color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimens.nr(20)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.nw(30),
                    vertical: Dimens.nh(12),
                  ),
                ),
                child: Flexible(
                  child: Text(
                    'متوجه شدم',
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
