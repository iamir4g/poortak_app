import 'package:flutter/material.dart';
import 'package:poortak/config/myTextStyle.dart';

class SelfAssessmentSubjectCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color backgroundColor;
  final VoidCallback onTap;

  const SelfAssessmentSubjectCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                iconPath,
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: MyTextStyle.textMatn14Bold,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
