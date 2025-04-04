import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

    return Container(
      width: 248,
      height: 25,
      decoration: BoxDecoration(
        color: MyColors.background,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset("assets/images/check_icon.png"),
                SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: MyTextStyle.textMatn12W300,
                )
              ],
            ),
            Row(
              children: [
                Text(
                  convertEnToFa(price).addComma,
                  style: MyTextStyle.textMatn12W500,
                ),
                Text(
                  l10n?.toman ?? "",
                  style: MyTextStyle.textMatn12W300,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
