import 'package:flutter/material.dart';

Widget buildEmptyCartUI() {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE8F0FC),
          Color(0xFFFCEBF1),
          Color(0xFFEFE8FC),
        ],
        stops: [0.1, 0.54, 1.0],
      ),
    ),
    child: Column(
      children: [
        const SizedBox(height: 40),
        // Top section: star icon and score
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/star_icon.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'مجموع امتیاز های شما : ',
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF29303D),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '۲۰۰ سکه',
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF29303D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Body: white container with border, illustration, and text
        Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Color(0xFFC2C9D6), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/empty_cart_illustration.png',
                  width: 140,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const Text(
                  'سبد خرید شما خالی است!',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFF3D495C),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
