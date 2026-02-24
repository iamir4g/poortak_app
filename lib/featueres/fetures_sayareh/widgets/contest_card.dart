import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';

class ContestCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ContestCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360.w,
      height: 105.h,
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: Container(
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, 0.50),
                end: Alignment(1.00, 0.50),
                colors: [Color(0xFFF1EFFF), Color(0xFFF2F6FD)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  // Text content - positioned exactly like Figma
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'مسابقه پورتک',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                ),
                              ),
                              Text(
                                'در مسابقه ماهانه پورتک شرکت کنید و جایزه ببرید.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                            ],
                          ))),
                  SizedBox(width: 16.w),
                  // Gift box icon container - positioned exactly like Figma
                  Container(
                    width: 77.5.w,
                    height: 79.h,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                        ),
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                        ),
                      ],
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF4A4D6B) // Dark icon background
                          : MyColors.background, // Light icon background
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Center(
                      child: Container(
                        width: 48.w,
                        height: 49.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Image.asset("assets/images/main/gift-box.png"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
