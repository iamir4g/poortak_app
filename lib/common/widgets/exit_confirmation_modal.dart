import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: Dimens.nw(350),
        height: Dimens.nh(311),
        decoration: BoxDecoration(
          color: isDark ? MyColors.profileHeaderDark : Colors.white,
          borderRadius: BorderRadius.circular(Dimens.nr(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Dimens.nw(80),
              height: Dimens.nh(80),
              decoration: BoxDecoration(
                color: MyColors.primaryTint3,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.exit_to_app,
                size: Dimens.nsp(40),
                color: MyColors.primary,
              ),
            ),
            SizedBox(height: Dimens.nh(20)),
            Container(
              width: Dimens.nw(250),
              margin: EdgeInsets.only(bottom: Dimens.nh(10)),
              child: Text(
                'خروج از برنامه',
                style: MyTextStyle.textMatn16Bold.copyWith(
                  color: isDark
                      ? MyColors.profileTextPrimaryDark
                      : MyColors.textMatn1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: Dimens.nw(250),
              margin: EdgeInsets.only(bottom: Dimens.nh(30)),
              child: Text(
                'آیا واقعاً می‌خواهید از برنامه خارج شوید؟',
                style: MyTextStyle.modalMessage14Medium.copyWith(
                  height: 1.4,
                  color: isDark ? MyColors.loginTextSecondaryDark : MyColors.text3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: Dimens.nw(140),
                  height: Dimens.nh(50),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onExit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimens.nr(20)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'خروج',
                      style: MyTextStyle.textMatnBtn.copyWith(
                        fontSize: Dimens.nsp(16),
                        color: MyColors.primaryButtonTextColor(isDark),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: Dimens.nw(140),
                  height: Dimens.nh(50),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onStay();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
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
                        fontWeight: FontWeight.w500,
                        fontSize: Dimens.nsp(16),
                        color: isDark
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
