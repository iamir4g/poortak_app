import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

class LeaderboardScreen extends StatelessWidget {
  static const routeName = '/leaderboard_screen';

  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7E4), // #fff7e4 - light cream background
              Color(0xFFFFF7E4), // Same color for gradient
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Leaderboard List
              Expanded(
                child: _buildLeaderboardList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(33.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: MyColors.textMatn1,
                size: 20,
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'اسامی برندگان مسابقه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IranSans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyColors.textMatn2,
              ),
            ),
          ),

          // Spacer for balance
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Month label - مهر ۱۴۰۳
            Container(
              width: 350,
              margin: const EdgeInsets.only(bottom: 28),
              child: const Text(
                'مهر ۱۴۰۳',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'IranSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MyColors.textMatn1,
                ),
              ),
            ),

            // Winner cards for مهر ۱۴۰۳
            ...List.generate(
                10,
                (index) => _buildWinnerCard(
                      name: 'حسین رادمهر',
                      phoneNumber: '۰۹۱۲****۳۸۶',
                    )),

            // Month label - شهریور ۱۴۰۳
            Container(
              width: 350,
              margin: const EdgeInsets.only(top: 28, bottom: 28),
              child: const Text(
                'شهریور ۱۴۰۳',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'IranSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MyColors.textMatn1,
                ),
              ),
            ),

            // Winner cards for شهریور ۱۴۰۳
            ...List.generate(
                10,
                (index) => _buildWinnerCard(
                      name: 'حسین رادمهر',
                      phoneNumber: '۰۹۱۲****۳۸۶',
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard({required String name, required String phoneNumber}) {
    return Container(
      width: 350,
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 2),
            blurRadius: 7.3,
          ),
        ],
      ),
      child: Row(
        children: [
          // Phone number (left side)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                phoneNumber,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'IranSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Name (right side)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'IranSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
