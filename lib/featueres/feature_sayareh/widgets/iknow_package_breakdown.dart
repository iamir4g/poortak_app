import 'package:flutter/material.dart';
import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/iknow_package_pricing.dart';
import 'package:poortak/l10n/app_localizations.dart';

class IKnowPackageBreakdown extends StatelessWidget {
  final IKnowPackagePricing pricing;
  final bool compact;

  const IKnowPackageBreakdown({
    super.key,
    required this.pricing,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;
    final secondaryTextColor =
        isDark ? MyColors.darkTextSecondary : MyColors.text1;
    final toman = l10n?.toman ?? 'تومان';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PriceRow(
          label: 'قیمت پایه',
          amountToman: pricing.basePriceToman,
          unit: toman,
          labelColor: secondaryTextColor,
          amountColor: primaryTextColor,
          emphasize: false,
        ),
        if (pricing.packageDiscount > 0) ...[
          SizedBox(height: Dimens.nh(compact ? 8.0 : 12.0)),
          _DiscountChip(
            label: 'تخفیف مجموعه',
            amountToman: pricing.packageDiscountToman,
            unit: toman,
            isDark: isDark,
            labelColor: secondaryTextColor,
            amountColor: primaryTextColor,
          ),
        ],
        if (pricing.ownedItems.isNotEmpty || pricing.appliedDeduction > 0) ...[
          SizedBox(height: Dimens.nh(compact ? 8.0 : 12.0)),
          _OwnedCountChip(
            count:
                pricing.ownedItems.isNotEmpty ? pricing.ownedItems.length : 1,
            amountToman: pricing.appliedDeductionToman,
            unit: toman,
            isDark: isDark,
          ),
        ],
        SizedBox(height: Dimens.nh(compact ? 8.0 : 16.0)),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: Dimens.nh(54.0)),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.nw(12.0),
            vertical: Dimens.nh(10.0),
          ),
          decoration: ShapeDecoration(
            color: isDark
                ? MyColors.cartPayableBackgroundDark
                : MyColors.background2,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: Dimens.nw(2.0),
                color: MyColors.primary,
              ),
              borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
            ),
          ),
          child: _PriceRow(
            label: 'مبلغ قابل پرداخت',
            amountToman: pricing.payablePriceToman,
            unit: toman,
            labelColor: secondaryTextColor,
            amountColor: primaryTextColor,
            emphasize: true,
          ),
        ),
      ],
    );
  }
}

class _DiscountChip extends StatelessWidget {
  final String label;
  final int amountToman;
  final String unit;
  final bool isDark;
  final Color labelColor;
  final Color amountColor;

  const _DiscountChip({
    required this.label,
    required this.amountToman,
    required this.unit,
    required this.isDark,
    required this.labelColor,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: Dimens.nh(42.0)),
      padding: EdgeInsets.symmetric(horizontal: Dimens.nw(12.0)),
      decoration: ShapeDecoration(
        color: isDark
            ? MyColors.cartDiscountBackgroundDark
            : MyColors.discountBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
        ),
      ),
      child: _PriceRow(
        label: label,
        amountToman: amountToman,
        unit: unit,
        labelColor: labelColor,
        amountColor: isDark ? MyColors.darkTextAccent : amountColor,
        emphasize: false,
      ),
    );
  }
}

class _OwnedCountChip extends StatelessWidget {
  final int count;
  final int amountToman;
  final String unit;
  final bool isDark;

  const _OwnedCountChip({
    required this.count,
    required this.amountToman,
    required this.unit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isDark
        ? MyColors.quizAnswerCorrectTextDark
        : MyColors.quizAnswerCorrectBorderLight;
    final label =
        '${convertEnToFa(count.toString())} آیتم قبلاً خریداری شده است.';

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: Dimens.nh(42.0)),
      padding: EdgeInsets.symmetric(horizontal: Dimens.nw(12.0)),
      decoration: ShapeDecoration(
        color: isDark
            ? MyColors.quizAnswerCorrectBackgroundDark
            : MyColors.quizAnswerCorrectBackgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
        ),
      ),
      child: _PriceRow(
        label: label,
        amountToman: amountToman,
        unit: unit,
        labelColor: statusColor,
        amountColor: statusColor,
        emphasize: false,
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final int amountToman;
  final String unit;
  final Color labelColor;
  final Color amountColor;
  final bool emphasize;

  const _PriceRow({
    required this.label,
    required this.amountToman,
    required this.unit,
    required this.labelColor,
    required this.amountColor,
    required this.emphasize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: (emphasize
                ? MyTextStyle.textMatn12W300
                : MyTextStyle.textMatn12W300),
          ),
        ),
        SizedBox(width: Dimens.nw(8.0)),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(
              amountToman.toString().addComma,
              style: (emphasize
                  ? MyTextStyle.textMatn14Bold
                  : MyTextStyle.textMatn14Bold),
            ),
            SizedBox(width: Dimens.nw(4.0)),
            Text(
              unit,
              style: MyTextStyle.textMatn10W300,
            ),
          ],
        ),
      ],
    );
  }
}

class IKnowOwnedItemsCaption extends StatelessWidget {
  final IKnowPackagePricing pricing;

  const IKnowOwnedItemsCaption({super.key, required this.pricing});

  @override
  Widget build(BuildContext context) {
    if (pricing.ownedItems.isEmpty && pricing.appliedDeduction <= 0) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final names = pricing.ownedItems.map((item) => item.name).join('، ');
    final deduction = pricing.appliedDeductionToman;
    final text = names.isEmpty
        ? 'کسر مالکیت: ${MoneyUtils.formatTomanDisplay(deduction)} تومان'
        : 'کسر مالکیت ($names): ${MoneyUtils.formatTomanDisplay(deduction)} تومان';
    return Text(
      text,
      textAlign: TextAlign.right,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: MyTextStyle.textMatn10W300.copyWith(
        color: isDark ? MyColors.darkTextSecondary : MyColors.text6,
      ),
    );
  }
}
