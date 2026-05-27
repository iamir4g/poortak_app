import 'package:flutter/material.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class InvoiceSummaryCard extends StatelessWidget {
  final int subTotal;
  final int discount;
  final int payable;

  const InvoiceSummaryCard({
    super.key,
    required this.subTotal,
    required this.discount,
    required this.payable,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelStyle = MyTextStyle.textMatn14Bold.copyWith(
      fontWeight: FontWeight.w500,
      color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
      height: 1.0,
    );
    final valueStyle = MyTextStyle.textMatn14Bold.copyWith(
      fontWeight: FontWeight.w500,
      color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
      height: 1.0,
    );
    final discountValueStyle = valueStyle.copyWith(
      color: discount > 0
          ? MyColors.darkError
          : (isDark ? MyColors.darkTextSecondary : MyColors.text6),
    );
    final innerBg =
        isDark ? MyColors.darkBackgroundSecondary : const Color(0xFFF7F9FC);

    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: Dimens.nw(360.0)),
        height: Dimens.nh(140.0),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.medium,
          vertical: Dimens.medium,
        ),
        decoration: BoxDecoration(
          color: isDark ? MyColors.termsBackgroundDark : MyColors.background,
          borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.medium,
              ),
              child: _InvoiceRow(
                label: 'صورت حساب',
                value: '${subTotal.addComma} تومان',
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            ),
            SizedBox(height: Dimens.nh(12)),
            Divider(
              height: Dimens.dividerHeight,
              thickness: Dimens.dividerHeight,
              color: isDark ? MyColors.darkBorder : MyColors.divider,
            ),
            SizedBox(height: Dimens.nh(12)),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: Dimens.medium,
              ),
              child: _InvoiceRow(
                label: 'تخفیف',
                value: '${discount.addComma} تومان',
                labelStyle: labelStyle,
                valueStyle: discountValueStyle,
              ),
            ),
            SizedBox(height: Dimens.nh(12)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.medium,
                vertical: Dimens.nh(12),
              ),
              decoration: BoxDecoration(
                color: innerBg,
                borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
              ),
              child: _InvoiceRow(
                label: 'مبلغ قابل پرداخت',
                value: '${payable.addComma} تومان',
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  const _InvoiceRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
