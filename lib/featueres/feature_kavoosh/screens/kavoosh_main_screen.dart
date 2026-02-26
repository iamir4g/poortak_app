import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
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
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.medium, vertical: Dimens.nw(20.0)),
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

                    SizedBox(height: Dimens.nh(13.0)),

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

                    SizedBox(height: Dimens.nh(13.0)),

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
            constraints: BoxConstraints(minHeight: Dimens.nh(150.0)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(Dimens.nr(30.0)),
              border: Border.all(
                color: Colors.white,
                width: Dimens.nw(5.0),
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
              padding: EdgeInsets.all(Dimens.nr(20.0)),
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
                            color: MyColors.darkText1,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Dimens.tiny),
                        Text(
                          subtitle,
                          style: MyTextStyle.textMatn10W300.copyWith(
                            fontWeight: FontWeight.w500,
                            color: MyColors.text3,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Dimens.medium),
                  // Icon placeholder
                  Container(
                    width: Dimens.nr(80.0),
                    height: Dimens.nr(80.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(Dimens.radiusLarge),
                    ),
                    child: Center(
                      child: Image.asset(
                        _getIconPathForTitle(title),
                        width: Dimens.nr(60.0),
                        height: Dimens.nr(60.0),
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
              top: Dimens.small,
              right: Dimens.small,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.small, vertical: Dimens.tiny),
                decoration: BoxDecoration(
                  color: MyColors.darkError,
                  borderRadius: BorderRadius.circular(Dimens.radiusMedium),
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
