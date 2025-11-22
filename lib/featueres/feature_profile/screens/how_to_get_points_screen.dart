import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/widgets/invite_friends_modal.dart';

class HowToGetPointsScreen extends StatefulWidget {
  static const routeName = "/how_to_get_points_screen";

  const HowToGetPointsScreen({super.key});

  @override
  State<HowToGetPointsScreen> createState() => _HowToGetPointsScreenState();
}

class _HowToGetPointsScreenState extends State<HowToGetPointsScreen> {
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
                    const SizedBox(height: 20),

                    // Coin animation
                    _buildCoinAnimation(),

                    const SizedBox(height: 20),

                    // Method cards
                    _buildMethodCards(isDarkMode),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
            'روش های کسب امتیاز',
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? MyColors.darkTextPrimary
                  : const Color(0xFF29303D),
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

  Widget _buildCoinAnimation() {
    return Container(
      height: 145,
      width: 267,
      child: Lottie.asset(
        'assets/images/points/coin.json',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMethodCards(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Method 1: App membership
          _buildMethodCard(
            isDarkMode: isDarkMode,
            title: 'عضویت در اپلیکیشن',
            points: '۵ سکه',
            description:
                'با ثبت شماره تماس خود در اپلیکیشن ۵ سکه دریافت میکنید.',
            backgroundColor: isDarkMode
                ? MyColors.darkCardBackground
                : const Color(0xFFFDF4F2),
            height: 95,
          ),

          const SizedBox(height: 13),

          // Method 2: App purchase
          _buildMethodCard(
            isDarkMode: isDarkMode,
            title: 'خرید از اپلیکیشن',
            points: '۵ سکه',
            description: 'با هر خرید از اپلیکیشن ۵ سکه دریافت میکنید.',
            backgroundColor: isDarkMode
                ? MyColors.darkCardBackground
                : const Color(0xFFE9EFFF),
            height: 86,
          ),

          const SizedBox(height: 13),

          // Method 3: Complete package purchase
          _buildMethodCard(
            isDarkMode: isDarkMode,
            title: 'خرید بسته کامل سیاره آی نو',
            points: '۵۰ سکه',
            description:
                'با خرید بسته ی کامل سیاره آی نو ۱۰ سکه دریافت میکنید.',
            backgroundColor: isDarkMode
                ? MyColors.darkCardBackground
                : const Color(0xFFFFF9EB),
            height: 86,
          ),

          const SizedBox(height: 13),

          // Method 4: Invite friends
          _buildInviteFriendsCard(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required bool isDarkMode,
    required String title,
    required String points,
    required String description,
    required Color backgroundColor,
    required double height,
  }) {
    return Container(
      width: 360,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : const Color(0xFF29303D),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                const SizedBox(width: 16),

                // Points
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    points,
                    style: const TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF29303D),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: TextStyle(
                fontFamily: 'IranSans',
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF3D495C),
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteFriendsCard(bool isDarkMode) {
    return Container(
      width: 360,
      height: 193,
      decoration: BoxDecoration(
        color:
            isDarkMode ? MyColors.darkCardBackground : const Color(0xFFF2FDF7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Text(
                    'دعوت از دوستان',
                    style: TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : const Color(0xFF29303D),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                const SizedBox(width: 16),

                // Points
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '۱۰ سکه',
                    style: const TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF29303D),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              'با ارائه کد معرف به دوستان خود با ورود هریک به اپلیکیشن و انجام خرید، هر کدام ۱۰ امتیاز به دست می آورید.',
              style: TextStyle(
                fontFamily: 'IranSans',
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF3D495C),
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),

            const SizedBox(height: 16),

            // Button inside the card
            Center(
              child: GestureDetector(
                onTap: () {
                  InviteFriendsModal.show(context);
                },
                child: Container(
                  width: 254,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF59E59A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'دعوت از دوستان',
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
