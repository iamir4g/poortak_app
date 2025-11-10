import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poortak/config/myColors.dart';

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
    // Set status bar to light content
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: MyColors.primary,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
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
                    const SizedBox(height: 20),

                    // Prize conversion section
                    _buildPrizeConversionSection(),

                    const SizedBox(height: 20),

                    // Prize cards
                    _buildPrizeCards(isDarkMode),

                    const SizedBox(height: 20),
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
      height: 57,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(33.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'جوایز ها',
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? MyColors.darkTextPrimary
                  : const Color(0xFF3D495C),
            ),
            textAlign: TextAlign.center,
          ),

          // Back Button
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_forward,
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF3D495C),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeConversionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1000 Toman container
          Container(
            width: 125,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7F1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '۱۰۰۰ تومان',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Arrow
          Container(
            width: 52,
            height: 52,
            child: Icon(
              Icons.arrow_forward,
              size: 32,
              color: const Color(0xFFFFA73F),
            ),
          ),

          // 1 Coin container
          Container(
            width: 135,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5DB),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 26,
                  child: Image.asset(
                    'assets/images/points/star_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'هر ۱ سکه',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeCards(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

          const SizedBox(height: 20),

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
      width: 315,
      decoration: BoxDecoration(
        color:
            isDarkMode ? MyColors.darkCardBackground : const Color(0xFFF4F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header with number
          Container(
            width: 293,
            height: 44,
            margin: const EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF323548) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Container(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFA73F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        fontFamily: 'IranSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IranSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? MyColors.darkTextPrimary
                        : const Color(0xFF29303D),
                  ),
                ),
              ],
            ),
            // Stack(
            //   children: [
            //     // Title
            //     Positioned(
            //       right: 16,
            //       top: 14,
            //       child:
            //     ),
            //     // Number badge
            //     Positioned(
            //       left: 16,
            //       top: 6,
            //       child:
            //     ),
            //   ],
            // ),
          ),

          // Description
          Container(
            width: 293,
            padding: const EdgeInsets.all(16),
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontSize: 11,
                fontWeight: FontWeight.w300,
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
      height: 111,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Ways to earn points button
          GestureDetector(
            onTap: () {
              // Navigate to how to get points screen
              Navigator.pushNamed(context, '/how_to_get_points_screen');
            },
            child: Container(
              width: 254,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDB80),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'روش های کسب امتیاز',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF29303D),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
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
            child: Container(
              width: 128,
              height: 23,
              child: Center(
                child: Text(
                  'ادامه و پرداخت',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
