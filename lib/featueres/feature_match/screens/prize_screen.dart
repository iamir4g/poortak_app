import 'package:flutter/material.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class MatchPrizeScreen extends StatefulWidget {
  static const routeName = '/match_prize_screen';
  const MatchPrizeScreen({super.key});

  @override
  State<MatchPrizeScreen> createState() => _MatchPrizeScreenState();
}

class _MatchPrizeScreenState extends State<MatchPrizeScreen>
    with SingleTickerProviderStateMixin {
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF9F0),
                    Color(0xFFFBFDF2),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Main content
              Expanded(
                child: Stack(
                  children: [
                    // Abstract background shapes
                    Positioned(
                      top: Dimens.nh(150),
                      left: -Dimens.nw(70),
                      child: Container(
                        width: Dimens.nr(250),
                        height: Dimens.nr(250),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? MyColors.primary
                                  : const Color(0xFFFFE8D0))
                              .withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: Dimens.nh(50),
                      right: -Dimens.nw(80),
                      child: Container(
                        width: Dimens.nr(300),
                        height: Dimens.nr(300),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? MyColors.secondary
                                  : const Color(0xFFE8F5D0))
                              .withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Main content card
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.nw(12),
                        vertical: Dimens.nh(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.nw(24),
                          vertical: Dimens.nh(50),
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? MyColors.termsBackgroundDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(Dimens.nr(30)),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    offset: const Offset(0, 10),
                                    blurRadius: 20,
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            // Money animation with shadow
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Shadow under money
                                Container(
                                  width: Dimens.nw(176),
                                  height: Dimens.nh(20),
                                  margin: EdgeInsets.only(
                                    bottom: Dimens.nh(20),
                                  ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDark
                                                ? Colors.black
                                                : Colors.black)
                                            .withValues(
                                                alpha: isDark ? 0.25 : 0.08),
                                        blurRadius: 25,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                buildImageFromAssetOrEmbeddedSvg(
                                  'assets/images/mony/allmony.png',
                                  width: Dimens.nw(176),
                                  height: Dimens.nh(187),
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),

                            SizedBox(height: Dimens.nh(30)),

                            // Title
                            Text(
                              'جوایز نقدی به برندگان',
                              textAlign: TextAlign.center,
                              style: MyTextStyle.text16MediumText1.copyWith(
                                fontSize: Dimens.nsp(18),
                                color: isDark
                                    ? MyColors.darkTextPrimary
                                    : MyColors.text1,
                              ),
                            ),

                            SizedBox(height: Dimens.nh(15)),

                            // Description
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.nw(10),
                              ),
                              child: Text(
                                'پس از ارسال پاسخ صحیح در بخش (شرکت در مسابقه پورتک) به قید قرعه به ۱۰ نفر از عزیزانی که جواب درست را نوشته باشند مبلغ ۱ میلیون ریال تعلق می گیرد.',
                                textAlign: TextAlign.center,
                                style: MyTextStyle.text14LightText3.copyWith(
                                  height: 1.4,
                                  color: isDark
                                      ? MyColors.darkTextSecondary
                                      : MyColors.text3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimens.medium,
        0,
        Dimens.nw(32),
        0,
      ),
      height: Dimens.nh(57),
      decoration: BoxDecoration(
        color: isDark ? MyColors.darkBackgroundSecondary : Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimens.nr(33.5)),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
              'جوایز مسابقه',
              textAlign: TextAlign.center,
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Back button
          SizedBox(
            width: Dimens.nw(40),
            height: Dimens.nh(40),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_forward,
                color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
                size: Dimens.nr(28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
