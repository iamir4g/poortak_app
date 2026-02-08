import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SelfAssessmentGradeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SelfAssessmentGradeCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 80,
        decoration: BoxDecoration(
          color: MyColors.background,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/quiz_icon.png',
              width: 40,
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                title,
                style: MyTextStyle.textMatn18Bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
