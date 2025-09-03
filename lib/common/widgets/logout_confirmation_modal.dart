import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LogoutConfirmationModal extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onStay;

  const LogoutConfirmationModal({
    Key? key,
    required this.onLogout,
    required this.onStay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        height: 365,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exit animation/image
            Container(
              height: 115,
              width: 121.601,
              margin: const EdgeInsets.only(bottom: 20),
              child: Lottie.asset(
                'assets/lottie/Exit.json', // Replace with your actual Lottie file
                fit: BoxFit.contain,
              ),
            ),

            // Confirmation text
            Container(
              width: 211.48,
              margin: const EdgeInsets.only(bottom: 40),
              child: const Text(
                'از حساب کاربری خود خارج می شوید؟',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF3D495C),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logout button
                Container(
                  width: 144, // 36 * 4 = 144 (w-36 from Figma)
                  height: 56, // h-14 = 56px
                  child: ElevatedButton(
                    onPressed: onLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'خروج از حساب',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Stay button
                Container(
                  width: 132,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: onStay,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF3D495C),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'ماندن',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF3D495C),
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
