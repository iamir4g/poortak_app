import 'package:flutter/material.dart';

class LessonCardWidget extends StatelessWidget {
  final String iconPath;
  final String englishLabel;
  final String persianLabel;
  final VoidCallback onTap;
  final Widget? badge;
  final int? progress;

  const LessonCardWidget({
    super.key,
    required this.iconPath,
    required this.englishLabel,
    required this.persianLabel,
    required this.onTap,
    this.badge,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 359,
        height: 104,
        clipBehavior: Clip.antiAlias,
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
        child: Stack(
          children: [
            if (progress != null && progress! > 0 && progress! < 100)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 359 * (progress! / 100),
                  color: const Color(
                      0xFFE3F2FD), // Light blue color for progress background
                ),
              ),
            Padding(
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
                  ),
                  if (progress != null && progress! > 0) ...[
                    const Spacer(),
                    if (progress == 100)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50), // Green color
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    else
                      Text(
                        "%$progress",
                        style: const TextStyle(
                          fontFamily: 'IranSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF53668E),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
