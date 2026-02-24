import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';

class ExitConfirmationModal extends StatelessWidget {
  final VoidCallback onExit;
  final VoidCallback onStay;

  const ExitConfirmationModal({
    super.key,
    required this.onExit,
    required this.onStay,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350.w,
        height: 311.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exit icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: MyColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.exit_to_app,
                size: 40.w,
                color: MyColors.error,
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Container(
              width: 250.w,
              margin: EdgeInsets.only(bottom: 10.h),
              child: Text(
                'خروج از برنامه',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: MyColors.textMatn1,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Message
            Container(
              width: 250.w,
              margin: EdgeInsets.only(bottom: 30.h),
              child: Text(
                'آیا واقعاً می‌خواهید از برنامه خارج شوید؟',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: const Color(0xFF3D495C),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Two buttons layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Exit button (primary)
                SizedBox(
                  width: 140.w,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onExit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'خروج',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Stay button (secondary)
                SizedBox(
                  width: 140.w,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onStay();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF3D495C), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      'بمانم',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        color: const Color(0xFF3D495C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required VoidCallback onExit,
    required VoidCallback onStay,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ExitConfirmationModal(
          onExit: onExit,
          onStay: onStay,
        );
      },
    );
  }
}
