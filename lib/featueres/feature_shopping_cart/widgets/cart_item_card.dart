import 'package:flutter/material.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_shopping_cart/utils/cart_item_pricing.dart';

class CartItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final CartItemPricing pricing;
  final Widget image;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.title,
    required this.pricing,
    required this.image,
    required this.onRemove,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimens.medium,
        vertical: Dimens.small,
      ),
      padding: EdgeInsets.all(Dimens.medium),
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : MyColors.background,
        borderRadius: BorderRadius.circular(Dimens.nr(16)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -Dimens.nh(10),
            left: -Dimens.nw(10),
            child: IconButton(
              iconSize: Dimens.nr(18),
              icon: Icon(
                Icons.close,
                color: isDark ? MyColors.darkTextSecondary : MyColors.text3,
              ),
              onPressed: onRemove,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Dimens.nw(100),
                height: Dimens.nh(100),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.nr(10)),
                  color:
                      isDark ? MyColors.darkCardBackground : Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.nr(10)),
                  child: image,
                ),
              ),
              SizedBox(width: Dimens.small),
              Expanded(
                child: SizedBox(
                  height: Dimens.nh(100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          color: titleColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: Dimens.nh(4)),
                        Text(
                          subtitle!,
                          style: MyTextStyle.textMatn10W300.copyWith(
                            color: isDark
                                ? MyColors.darkTextSecondary
                                : MyColors.text6,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: _CartItemPriceSection(pricing: pricing),
                      ),
                      // _CartItemPriceSection(pricing: pricing),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartItemPriceSection extends StatelessWidget {
  final CartItemPricing pricing;

  const _CartItemPriceSection({required this.pricing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceColor = isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;

    if (!pricing.hasDiscount) {
      return _PriceRow(
        amount: pricing.finalPriceToman,
        amountStyle: TextStyle(
          fontFamily: 'IRANSans',
          fontSize: Dimens.nsp(16),
          fontWeight: FontWeight.bold,
          color: priceColor,
          height: 1.0,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pricing.discountPercentLabel != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.nw(6),
                  vertical: Dimens.nh(2),
                ),
                decoration: BoxDecoration(
                  color: MyColors.darkErrorLight,
                  borderRadius: BorderRadius.circular(Dimens.nr(11.5)),
                ),
                child: Text(
                  pricing.discountPercentLabel!,
                  style: MyTextStyle.textMatn10W300.copyWith(
                    color: MyColors.textLight,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(width: Dimens.nw(6)),
            ],
            RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontSize: Dimens.nsp(12),
                  fontWeight: FontWeight.w400,
                  color: isDark ? MyColors.darkTextSecondary : MyColors.text6,
                  decoration: TextDecoration.lineThrough,
                  decorationColor:
                      isDark ? MyColors.darkTextSecondary : MyColors.text6,
                  height: 1.0,
                ),
                children: [
                  TextSpan(
                    text: MoneyUtils.formatTomanDisplay(
                      pricing.originalPriceToman!,
                    ),
                  ),
                  TextSpan(
                    text: ' تومان',
                    style: TextStyle(
                      fontSize: Dimens.nsp(10),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: Dimens.nh(4)),
        _PriceRow(
          amount: pricing.finalPriceToman,
          amountStyle: TextStyle(
            fontFamily: 'IRANSans',
            fontSize: Dimens.nsp(16),
            fontWeight: FontWeight.bold,
            color: priceColor,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final int amount;
  final TextStyle amountStyle;

  const _PriceRow({
    required this.amount,
    required this.amountStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: amountStyle,
        children: [
          TextSpan(text: MoneyUtils.formatTomanDisplay(amount)),
          TextSpan(
            text: ' تومان',
            style: amountStyle.copyWith(
              fontSize: Dimens.nsp(12),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
