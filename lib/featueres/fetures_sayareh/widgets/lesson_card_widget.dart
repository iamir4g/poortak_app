import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/config/dimens.dart';

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
    final width = Dimens.nw(320); // Reduced from 359 to be more responsive
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: Dimens.nh(90), // Reduced from 104
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.nr(30)), // Reduced from 40
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 0),
              blurRadius: Dimens.nr(4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (progress != null && progress! > 0 && progress! < 100)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0, // In RTL, progress should start from right
                child: Container(
                  width: width * (progress! / 100),
                  color: const Color(0xFFE3F2FD),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimens.nh(15), // Reduced from 22
                horizontal: Dimens.nw(20), // Reduced from 28
              ),
              child: Row(
                children: [
                  badge != null
                      ? Stack(
                          children: [
                            Image.asset(
                              iconPath,
                              width: Dimens.nr(40), // Reduced from 48
                              height: Dimens.nr(40),
                            ),
                            Positioned(
                              top: Dimens.nh(4),
                              left: Dimens.nw(10),
                              child: badge!,
                            ),
                          ],
                        )
                      : Image.asset(
                          iconPath,
                          width: Dimens.nr(40), // Reduced from 48
                          height: Dimens.nr(40),
                        ),
                  SizedBox(width: Dimens.nw(15)), // Reduced from 18
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        englishLabel,
                        style: MyTextStyle.textMatn12W500.copyWith(
                          color: const Color(0xFFA3AFC2),
                          fontSize: Dimens.nsp(10), // Explicitly responsive
                        ),
                      ),
                      Text(
                        persianLabel,
                        style: MyTextStyle.textMatn18Bold.copyWith(
                          color: const Color(0xFF29303D),
                          fontSize: Dimens.nsp(16), // Explicitly responsive
                        ),
                      )
                    ],
                  ),
                  if (progress != null && progress! > 0) ...[
                    const Spacer(),
                    if (progress == 100)
                      Container(
                        width: Dimens.nw(32), // Reduced from 40
                        height: Dimens.nh(32),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: Dimens.nr(20), // Reduced from 24
                        ),
                      )
                    else
                      Text(
                        "%$progress",
                        style: TextStyle(
                          fontFamily: 'IranSans',
                          fontSize: Dimens.nsp(14), // Reduced from 16
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF53668E),
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
