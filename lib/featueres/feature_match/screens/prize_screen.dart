import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 40000),
    )..repeat(); // Repeat the animation

    // Animation from image 9 to 0
    _animation = IntTween(begin: 9, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9F0), // Light beige
              Color(0xFFFBFDF2), // Light green
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
                      top: 150.h,
                      left: -70.w,
                      child: Container(
                        width: 250.r,
                        height: 250.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8D0).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50.h,
                      right: -80.w,
                      child: Container(
                        width: 300.r,
                        height: 300.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5D0).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Main content card
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 20.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 50.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
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
                                  width: 140.w,
                                  height: 20.h,
                                  margin: EdgeInsets.only(bottom: 20.h),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 25,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _animation,
                                  builder: (context, child) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        for (int i = 9;
                                            i >= _animation.value;
                                            i--)
                                          Image.asset(
                                            'assets/images/mony/images-$i.png',
                                            width: 100.w,
                                            height: 100.h,
                                            fit: BoxFit.contain,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 30.h),

                            // Title
                            Text(
                              'جوایز نقدی به برندگان',
                              textAlign: TextAlign.center,
                              style: MyTextStyle.text16MediumText1.copyWith(
                                fontSize: 18.sp,
                                color: MyColors.text1,
                              ),
                            ),

                            SizedBox(height: 15.h),

                            // Description
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(
                                'پس از ارسال پاسخ صحیح در بخش (شرکت در مسابقه پورتک) به قید قرعه به ۱۰ نفر از عزیزانی که جواب درست را نوشته باشند مبلغ ۱ میلیون ریال تعلق می گیرد.',
                                textAlign: TextAlign.center,
                                style: MyTextStyle.text14LightText3.copyWith(
                                  height: 1.4,
                                  color: MyColors.text3,
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
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 0),
      height: 57.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(33.5.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 1.h),
            blurRadius: 1.r,
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
                color: MyColors.textMatn2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Back button
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_forward,
                color: MyColors.textMatn1,
                size: 28.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
