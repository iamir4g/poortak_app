import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class PaymentSecurityFooter extends StatelessWidget {
  const PaymentSecurityFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimens.nw(10)),
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.nw(14),
        vertical: Dimens.nh(8),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'امنیت در پرداخت',
                  style: MyTextStyle.paymentSecurityTitle13Medium.copyWith(
                    color: isDark
                        ? MyColors.darkTextPrimary
                        : MyColors.activeTabBackground,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: Dimens.nh(6)),
                Text(
                  'دارای نماد اعتماد الکترونیک از وزارت صمت',
                  style: MyTextStyle.paymentSecuritySubtitle10Medium.copyWith(
                    color: isDark
                        ? MyColors.darkTextPrimary
                        : MyColors.activeTabBackground,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/enamad.png',
            width: Dimens.nw(80),
            height: Dimens.nh(80),
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
