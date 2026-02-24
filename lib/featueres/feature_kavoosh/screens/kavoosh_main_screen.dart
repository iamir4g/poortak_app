import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/educational_videos_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/ebooks_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/self_assessment_screen.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class KavooshMainScreen extends StatefulWidget {
  static const String routeName = '/kavoosh-main';
  const KavooshMainScreen({super.key});

  @override
  State<KavooshMainScreen> createState() => _KavooshMainScreenState();
}

class _KavooshMainScreenState extends State<KavooshMainScreen> {
  @override
  void initState() {
    super.initState();
    // Status bar is managed centrally in MainWrapper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background3,
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  children: [
                    // Educational Videos Card
                    _buildContentCard(
                      title: 'ویدئو های آموزشی',
                      subtitle: 'ویدئو های آموزشی برای پایه های تحصیلی',
                      gradientColors: const [
                        Color(0xFFFFFDCC),
                        Color(0xFFFFF3D6),
                      ],
                      onTap: () {
                        Navigator.pushNamed(
                            context, EducationalVideosScreen.routeName);
                      },
                    ),

                    SizedBox(height: 13.h),

                    // E-Books Card
                    _buildContentCard(
                      title: 'کتاب الکترونیکی',
                      subtitle:
                          'کتاب های آموزشی الکترونیکی برای پایه های تحصیلی',
                      gradientColors: const [
                        Color(0xFFFBEBDF),
                        Color(0xFFFFDBDB),
                      ],
                      onTap: () {
                        Navigator.pushNamed(context, EBooksScreen.routeName);
                      },
                    ),

                    SizedBox(height: 13.h),

                    // Self-Assessment Card
                    _buildContentCard(
                      title: 'خود سنجی',
                      subtitle: 'آزمون دروس پایه های تحصیلی',
                      gradientColors: const [
                        Color(0xFFD9FFFA),
                        Color(0xFFD9FFEA),
                      ],
                      onTap: () {
                        Navigator.pushNamed(
                            context, SelfAssessmentScreen.routeName);
                      },
                      showComingSoonBadge: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool showComingSoonBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 150.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: Colors.white,
                width: 5.w,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F92A2BE),
                  blurRadius: 13,
                  offset: Offset(0, -7),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: MyTextStyle.textMatn17W700.copyWith(
                            color: const Color(0xFF29303D),
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: MyTextStyle.textMatn10W300.copyWith(
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF52617A),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  // Icon placeholder
                  Container(
                    width: 100.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        _getIconPathForTitle(title),
                        width: 114.w,
                        height: 70.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Coming Soon Badge
          if (showComingSoonBadge)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'به زودی',
                  style: MyTextStyle.textMatn10W300.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getIconPathForTitle(String title) {
    switch (title) {
      case 'ویدئو های آموزشی':
        return 'assets/images/kavoosh/videoIcon.png';
      case 'کتاب های صوتی':
        return 'assets/images/kavoosh/audioBookIcon.png';
      case 'کتاب الکترونیکی':
        return 'assets/images/kavoosh/ebookIcon.png';
      case 'خود سنجی':
        return 'assets/images/kavoosh/selfAssessmentIcon.png';
      default:
        return 'assets/images/kavoosh/videoIcon.png';
    }
  }
}
