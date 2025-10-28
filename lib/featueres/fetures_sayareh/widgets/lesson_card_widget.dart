import 'package:flutter/material.dart';

class LessonCardWidget extends StatelessWidget {
  final String iconPath;
  final String englishLabel;
  final String persianLabel;
  final VoidCallback onTap;
  final Widget? badge;

  const LessonCardWidget({
    super.key,
    required this.iconPath,
    required this.englishLabel,
    required this.persianLabel,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 359,
        height: 104,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 0),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
          child: Row(
            children: [
              badge != null
                  ? Stack(
                      children: [
                        Image.asset(
                          iconPath,
                          width: 48.0,
                          height: 48.0,
                        ),
                        Positioned(
                          top: 5,
                          left: 14,
                          child: badge!,
                        ),
                      ],
                    )
                  : Image.asset(
                      iconPath,
                      width: 48.0,
                      height: 48.0,
                    ),
              const SizedBox(width: 18),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    englishLabel,
                    style: const TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA3AFC2),
                    ),
                  ),
                  Text(
                    persianLabel,
                    style: const TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF29303D),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
