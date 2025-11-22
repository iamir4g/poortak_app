import 'package:flutter/material.dart';
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
              height: 57,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    'امتیازات',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D495C),
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
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF3D495C),
                        size: 20,
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
      height: 193,
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
                    // TextStyle(
                    //   color: Colors.black,
                    //   fontSize: 16,
                    //   fontFamily: 'IRANSans',
                    //   fontWeight: FontWeight.w500,
                    // ),
                  ),
                  Text(
                    "امتیاز کسب شده از ابتدای آموزش",
                    textAlign: TextAlign.right,
                    style: MyTextStyle.textMatn12W300,
                    // TextStyle(
                    //   color: const Color(0xFF3D485B),
                    //   fontSize: 10,
                    //   fontFamily: 'IRANSans',
                    //   fontWeight: FontWeight.w300,
                    // ),
                  ),
                ],
              ),
              SizedBox(width: 55),
              // const Spacer(),
              // 200 coins container
              Container(
                width: 88,
                height: 33,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8CC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "۲۰۰ سکه",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF28303D),
                      fontSize: 16,
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          // Ways to earn points section
          _buildWaysToEarnSection(),
        ],
      ),
    );
  }

  Widget _buildWaysToEarnSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: 254,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFDB80),
        borderRadius: BorderRadius.circular(20),
      ),
      // padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
      child: Row(
        children: [
          // Star icon
          Container(
            width: 36,
            height: 34,
            child: Image.asset(
              'assets/images/points/star_icon.png',
              fit: BoxFit.contain,
            ),
          ),

          // const SizedBox(width: 31),

          // Yellow container
          Expanded(
            child: Container(
              height: 60,
              child: Center(
                child: Text(
                  "روش های کسب امتیاز",
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn15,
                  // TextStyle(
                  //   color: const Color(0xFF28303D),
                  //   fontSize: 15,
                  //   fontFamily: 'IRANSans',
                  //   fontWeight: FontWeight.w500,
                  // ),
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
        width: 350,
        height: 119,
        margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 0),
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
                padding: EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "تاریخچه امتیاز",
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn13,
                      // TextStyle(
                      //   color: const Color(0xFF28303D),
                      //   fontSize: 13,
                      //   fontFamily: 'IRANSans',
                      //   fontWeight: FontWeight.w500,
                      // ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "تاریخچه ی امتیازهای کسب شده خود را ببینید.",
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn10W300,
                      // TextStyle(
                      //   color: const Color(0xFF3D485B),
                      //   fontSize: 10,
                      //   fontFamily: 'IRANSans',
                      //   fontWeight: FontWeight.w300,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
            // Calendar animation placeholder
            Container(
              width: 100,
              height: 100,
              child: Lottie.asset(
                'assets/images/points/calendar.json',
                width: 79,
                height: 78,
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
        width: 350,
        height: 119,
        margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EB),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
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
                      // TextStyle(
                      //   color: const Color(0xFF28303D),
                      //   fontSize: 13,
                      //   fontFamily: 'IRANSans',
                      //   fontWeight: FontWeight.w500,
                      // ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "جایزه سکه های جمع شده خود را مشاهده کنید.",
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn10W300,
                      // TextStyle(
                      //   color: const Color(0xFF3D485B),
                      //   fontSize: 10,
                      //   fontFamily: 'IRANSans',
                      //   fontWeight: FontWeight.w300,
                      // ),
                    ),
                  ],
                ),
              ),

              // Prize animation placeholder with background circle
              Container(
                width: 70,
                height: 70,
                // margin: const EdgeInsets.only(left: 23),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Lottie.asset(
                  'assets/images/points/prize.json',
                  width: 78,
                  height: 78,
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
