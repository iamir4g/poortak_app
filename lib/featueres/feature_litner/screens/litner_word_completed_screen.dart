import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class LitnerWordCompletedScreen extends StatelessWidget {
  static const String routeName = '/litner-word-completed';
  const LitnerWordCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FE), // Figma background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9FE),
        elevation: 0,
        title: const Text(
          'آموخته شده ها',
          style: MyTextStyle.textHeader16Bold,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3D495C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Image.asset(
              'assets/images/litner/litner_empty_state.png',
              width: 246,
              height: 246,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            // Main message
            const Text(
              'شما هنوز هیچ کلمه ای را به صورت کامل نیاموخته اید.',
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF29303D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Sub message
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'وقتی معنی کلمه ای را به طور کامل به خاطر بسپارید، کلمه به این قسمت هدایت می شود.',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Color(0xFFA3AFC2),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
