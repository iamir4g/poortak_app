import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class LogoutConfirmationModal extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onStay;

  const LogoutConfirmationModal({
    super.key,
    required this.onLogout,
    required this.onStay,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350.w,
        height: 365.h,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2E3F) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Exit animation/image
                Container(
                  height: 115.h,
                  width: 121.601.w,
                  margin: EdgeInsets.only(bottom: 20.h),
                  child: Lottie.asset(
                    'assets/lottie/Exit.json', // Replace with your actual Lottie file
                    fit: BoxFit.contain,
                  ),
                ),

                // Confirmation text
                Container(
                  width: 211.48.w,
                  margin: EdgeInsets.only(bottom: 40.h),
                  child: Text(
                    'از حساب کاربری خود خارج می شوید؟',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      color: const Color(0xFF3D495C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logout button
                    SizedBox(
                      width: 144.w, // 36 * 4 = 144 (w-36 from Figma)
                      height: 56.h, // h-14 = 56px
                      child: ElevatedButton(
                        onPressed: onLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5A5A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'خروج از حساب',
                          style: TextStyle(
                            fontFamily: 'IRANSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Stay button
                    SizedBox(
                      width: 132.w,
                      height: 56.h,
                      child: OutlinedButton(
                        onPressed: onStay,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF3D495C),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          'بمانم',
                          style: TextStyle(
                            fontFamily: 'IRANSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: const Color(0xFF3D495C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Close Button (X) - Top Left
            Positioned(
              top: 12.h,
              left: 12.w,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF323548)
                        : const Color(0xFFF6F9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: isDarkMode ? Colors.white : const Color(0xFF3D495C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    required VoidCallback onLogout,
    required VoidCallback onStay,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LogoutConfirmationModal(
          onLogout: () {
            Navigator.of(context).pop();
            onLogout();
          },
          onStay: () {
            Navigator.of(context).pop();
            onStay();
          },
        );
      },
    );
  }
}
