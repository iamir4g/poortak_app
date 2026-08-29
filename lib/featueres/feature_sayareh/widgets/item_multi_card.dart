import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/l10n/app_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:persian_tools/persian_tools.dart';

class ItemMultiCard extends StatelessWidget {
  final String title;
  final String price;
  const ItemMultiCard({
    super.key,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;
    final secondaryTextColor =
        isDark ? MyColors.darkTextSecondary : MyColors.textMatn1;

    return Container(
      width: 248.w,
      height: 25.h,
      decoration: BoxDecoration(
        color: isDark ? MyColors.cartItemCardDark : MyColors.background,
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 0, 8.w, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset("assets/images/check_icon.png"),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  title,
                  style: MyTextStyle.textMatn12W300.copyWith(color: textColor),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  convertEnToFa(MoneyUtils.formatTomanFromRial(price)),
                  style: MyTextStyle.textMatn12W500.copyWith(color: textColor),
                ),
                Text(
                  l10n?.toman ?? "",
                  style:
                      MyTextStyle.textMatn12W300.copyWith(color: secondaryTextColor),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
