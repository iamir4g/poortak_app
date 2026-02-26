import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class PrizeScreen extends StatefulWidget {
  static const routeName = "/prize_screen";

  const PrizeScreen({super.key});

  @override
  State<PrizeScreen> createState() => _PrizeScreenState();
}

class _PrizeScreenState extends State<PrizeScreen> {
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

                    // Prize conversion section
                    _buildPrizeConversionSection(),

                    SizedBox(height: 20.h),

                    // Prize cards
                    _buildPrizeCards(isDarkMode),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Bottom button
            _buildBottomButton(),
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
            'جوایز ها',
            style: MyTextStyle.textHeader16Bold.copyWith(
              color: isDarkMode
                  ? MyColors.darkTextPrimary
                  : const Color(0xFF3D495C),
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

  Widget _buildPrizeConversionSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1000 Toman container
          Expanded(
            child: Container(
              height: 75.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7F1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Center(
                child: Text(
                  '۱۰۰۰ تومان',
                  style: MyTextStyle.textMatn15.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // Arrow
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: SizedBox(
              width: 40.r,
              height: 40.r,
              child: Icon(
                Icons.arrow_forward,
                size: 28.r,
                color: const Color(0xFFFFA73F),
              ),
            ),
          ),

          // 1 Coin container
          Expanded(
            child: Container(
              height: 75.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5DB),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 28.r,
                    height: 26.r,
                    child: Image.asset(
                      'assets/images/points/star_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'هر ۱ سکه',
                      style: MyTextStyle.textMatn15.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeCards(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // First prize card - Discount
          _buildPrizeCard(
            isDarkMode: isDarkMode,
            title: 'تخفیف در خرید ها',
            description:
                'به ازای هر ۱ سکه مبلغ ۱۰۰۰ تومان از صورت حساب سبد خرید شما کسر می شود که برای این منظور کافیست قبل از اقدام به خرید در بخش سبد خرید دکمه ی (محاسبه امتیاز بر روی سبد خرید) را بزنید.\n\nنکته: اگر دروس سیاره آی نو را بدون احتساب سکه ها خریده باشید می توانید برای بخش کاوش که کتابهای الکترونیکی و صوتی و همینطور فیلم های آموزشی پایه های تحصیلی را شامل می شود اعمال کنید.',
            number: '۱',
          ),

          SizedBox(height: 20.h),

          // Second prize card - Cash purchase
          _buildPrizeCard(
            isDarkMode: isDarkMode,
            title: 'خرید نقدی امتیازات شما',
            description:
                'خبر خوب اینه که اگر تعداد سکه های شما به ۵۰۰ سکه یا بالاتر برسد میتوانید از طریق ارسال اسکرین شات از صفحه امتیازات خود به آدرس ایمیل ما، هزینه ی نقدی امتیازات خود را پس از صحت سنجی از ما دریافت کنید.😍💵',
            number: '۲',
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeCard({
    required bool isDarkMode,
    required String title,
    required String description,
    required String number,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            isDarkMode ? MyColors.darkCardBackground : const Color(0xFFF4F5F5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          // Header with number
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF323548) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 31.r,
                  height: 31.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFA73F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: MyTextStyle.textMatn16.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: MyTextStyle.textMatn16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : const Color(0xFF29303D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Description
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            child: Text(
              description,
              style: MyTextStyle.textMatn11.copyWith(
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF29303D),
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.only(bottom: 16.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, -2.h),
            blurRadius: 4.r,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          // Ways to earn points button
          GestureDetector(
            onTap: () {
              // Navigate to how to get points screen
              Navigator.pushNamed(context, '/how_to_get_points_screen');
            },
            child: Container(
              width: 254.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDB80),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  'روش های کسب امتیاز',
                  style: MyTextStyle.textMatn15.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF29303D),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Continue and pay button
          GestureDetector(
            onTap: () {
              // This could navigate to a payment screen or show a dialog
              // For now, just show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('این قابلیت به زودی اضافه خواهد شد'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                'ادامه و پرداخت',
                style: MyTextStyle.textMatn11.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF29303D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
