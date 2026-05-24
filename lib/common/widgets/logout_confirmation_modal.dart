import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

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
      insetPadding: EdgeInsets.symmetric(horizontal: Dimens.nw(22)),
      child: Container(
        width: Dimens.nw(350),
        height: Dimens.nh(365),
        decoration: BoxDecoration(
          color: isDarkMode ? MyColors.profileHeaderDark : Colors.white,
          borderRadius: BorderRadius.circular(Dimens.nr(20)),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Exit animation/image
                Container(
                  height: Dimens.nh(115),
                  width: Dimens.nw(121.601),
                  margin: EdgeInsets.only(bottom: Dimens.nh(20)),
                  child: Lottie.asset(
                    'assets/lottie/Exit.json', // Replace with your actual Lottie file
                    fit: BoxFit.contain,
                  ),
                ),

                // Confirmation text
                Container(
                  width: Dimens.nw(211.48),
                  margin: EdgeInsets.only(bottom: Dimens.nh(40)),
                  child: Text(
                    'از حساب کاربری خود خارج می شوید؟',
                    style: MyTextStyle.textMatn13PrimaryShade1.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: Dimens.nsp(13),
                      color: isDarkMode
                          ? MyColors.profileTextPrimaryDark
                          : MyColors.text2,
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
                      width: Dimens.nw(144),
                      height: Dimens.nh(56),
                      child: ElevatedButton(
                        onPressed: onLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5A5A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimens.nr(20)),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'خروج از حساب',
                          style: MyTextStyle.textMatnBtn.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimens.nsp(14),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: Dimens.nw(8)),

                    // Stay button
                    SizedBox(
                      width: Dimens.nw(144),
                      height: Dimens.nh(56),
                      child: OutlinedButton(
                        onPressed: onStay,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDarkMode
                                ? MyColors.profileTextPrimaryDark
                                : MyColors.text2,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimens.nr(20)),
                          ),
                        ),
                        child: Text(
                          'بمانم',
                          style: MyTextStyle.textMatnBtn.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimens.nsp(14),
                            color: isDarkMode
                                ? MyColors.profileTextPrimaryDark
                                : MyColors.text2,
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
              top: Dimens.nh(12),
              left: Dimens.nw(12),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: Dimens.nw(32),
                  height: Dimens.nh(32),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? MyColors.paymentHistoryCardHeaderDark
                        : MyColors.background3,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: Dimens.nsp(20),
                    color: isDarkMode
                        ? MyColors.profileTextPrimaryDark
                        : MyColors.text2,
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
