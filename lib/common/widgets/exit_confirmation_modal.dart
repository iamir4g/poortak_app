import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        width: 350,
        height: 311,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exit icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MyColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app,
                size: 40,
                color: MyColors.error,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Container(
              width: 250,
              margin: const EdgeInsets.only(bottom: 10),
              child: const Text(
                'خروج از برنامه',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: MyColors.textMatn1,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Message
            Container(
              width: 250,
              margin: const EdgeInsets.only(bottom: 30),
              child: const Text(
                'آیا واقعاً می‌خواهید از برنامه خارج شوید؟',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF3D495C),
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
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onExit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'خروج',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Stay button (secondary)
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onStay();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: MyColors.primary, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'ماندن',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: MyColors.primary,
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
