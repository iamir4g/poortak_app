import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_match/screens/match_screen.dart';

class MainMatchScreen extends StatelessWidget {
  static const routeName = '/main_match_screen';
  const MainMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF5F0), // Light orange
              Color(0xFFFBFDF2), // Light green
            ],
          ),
        ),
        child: SafeArea(
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
                      'مسابقه پورتک',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D495C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // ),

                    // Back Button
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(left: 16),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: MyColors.textMatn1,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Match Option Cards
                      _buildMatchCard(
                        iconLottiePath: 'assets/images/match/questions.json',
                        title: 'شرکت در مسابقه',
                        onTap: () {
                          // Navigate to join match screen
                          // _showComingSoonDialog(context);
                          Navigator.pushNamed(context, MatchScreen.routeName);
                        },
                      ),

                      const SizedBox(height: 20),

                      // _buildMatchCard(
                      //   iconLottiePath: 'assets/images/match/mylists.json',
                      //   title: 'اسامی برندگان مسابقه',
                      //   onTap: () {
                      //     // Navigate to winners list screen
                      //     _showComingSoonDialog(context);
                      //   },
                      // ),

                      const SizedBox(height: 20),

                      _buildMatchCard(
                        iconLottiePath: 'assets/images/match/prize.json',
                        title: 'جوایز مسابقه',
                        onTap: () {
                          // Navigate to prizes screen
                          _showComingSoonDialog(context);
                        },
                      ),

                      const SizedBox(height: 40),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 350,
        height: 162,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 0),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MyColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                iconLottiePath, // Replace with your actual Lottie file
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'IRANSans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF29303D),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'به زودی',
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'این بخش به زودی راه‌اندازی خواهد شد.',
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 14,
              color: MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  'متوجه شدم',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
