import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/cubit/cart_points_discount_cubit.dart';

/// RTL panel: points slider + live quote-driven price preview.
class CartPointsDiscountPanel extends StatelessWidget {
  const CartPointsDiscountPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<CartPointsDiscountCubit, CartPointsDiscountState>(
      builder: (context, state) {
        if (!state.eligible || !state.panelOpen) {
          return const SizedBox.shrink();
        }

        final pointValueHint = state.pointValueInRials ??
            state.quote?.pointValueInRials ??
            0;
        final pointValueToman = MoneyUtils.rialToTomanInt(pointValueHint);

        return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(
            Dimens.medium,
            Dimens.nh(8),
            Dimens.medium,
            Dimens.nh(4),
          ),
          padding: EdgeInsets.all(Dimens.medium),
          decoration: BoxDecoration(
            color: isDark
                ? MyColors.darkBackgroundSecondary
                : Colors.white,
            borderRadius: BorderRadius.circular(Dimens.nr(12)),
            border: Border.all(
              color: isDark ? MyColors.darkBorder : const Color(0xFFFFA73F),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'استفاده از امتیاز',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: Dimens.nsp(15),
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? MyColors.darkTextPrimary
                      : const Color(0xFF29303D),
                ),
              ),
              SizedBox(height: Dimens.nh(4)),
              Text(
                state.maxPoints <= 0
                    ? 'امتیازی برای استفاده ندارید'
                    : pointValueToman > 0
                        ? 'هر امتیاز ≈ ${MoneyUtils.formatTomanDisplay(pointValueToman)} تومان'
                        : 'با تغییر اسلایدر، قیمت نهایی از سرور محاسبه می‌شود',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: Dimens.nsp(12),
                  color: isDark
                      ? MyColors.darkTextSecondary
                      : MyColors.text6,
                ),
              ),
              SizedBox(height: Dimens.nh(12)),
              Row(
                children: [
                  Text(
                    toPersianDigits('0'),
                    style: TextStyle(
                      fontSize: Dimens.nsp(12),
                      color: isDark
                          ? MyColors.darkTextSecondary
                          : MyColors.text6,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: Dimens.nr(8),
                        ),
                      ),
                      child: Slider(
                        value: state.pointsToSpend
                            .clamp(0, state.maxPoints)
                            .toDouble(),
                        min: 0,
                        max: state.maxPoints <= 0
                            ? 1
                            : state.maxPoints.toDouble(),
                        divisions: state.maxPoints <= 0
                            ? 1
                            : state.maxPoints,
                        activeColor: MyColors.primary,
                        inactiveColor: isDark
                            ? MyColors.darkBorder
                            : const Color(0xFFFFE8CC),
                        label: toPersianDigits('${state.pointsToSpend}'),
                        onChanged: state.maxPoints <= 0
                            ? null
                            : (v) => context
                                .read<CartPointsDiscountCubit>()
                                .setPointsToSpend(v.round()),
                      ),
                    ),
                  ),
                  Text(
                    toPersianDigits('${state.maxPoints}'),
                    style: TextStyle(
                      fontSize: Dimens.nsp(12),
                      color: isDark
                          ? MyColors.darkTextSecondary
                          : MyColors.text6,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'امتیاز انتخاب‌شده: ${toPersianDigits('${state.pointsToSpend}')}',
                  style: TextStyle(
                    fontSize: Dimens.nsp(13),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? MyColors.darkTextPrimary
                        : const Color(0xFF29303D),
                  ),
                ),
              ),
              if (state.isQuoting) ...[
                SizedBox(height: Dimens.nh(10)),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
              if (state.quote != null && !state.isQuoting) ...[
                SizedBox(height: Dimens.nh(10)),
                _QuotePriceRow(
                  label: 'قیمت پایه',
                  amountToman: state.quote!.basePriceToman,
                  isDark: isDark,
                ),
                SizedBox(height: Dimens.nh(4)),
                _QuotePriceRow(
                  label: 'تخفیف امتیاز',
                  amountToman: state.quote!.discountAmountToman,
                  isDark: isDark,
                  highlight: true,
                ),
                SizedBox(height: Dimens.nh(4)),
                _QuotePriceRow(
                  label: 'مبلغ قابل پرداخت',
                  amountToman: state.quote!.finalPriceToman,
                  isDark: isDark,
                  bold: true,
                ),
              ],
              if (state.error != null && !state.isQuoting) ...[
                SizedBox(height: Dimens.nh(8)),
                Text(
                  state.error!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: Dimens.nsp(12),
                    color: MyColors.darkError,
                  ),
                ),
                if (state.pointsToSpend > 0)
                  TextButton(
                    onPressed: () =>
                        context.read<CartPointsDiscountCubit>().retryQuote(),
                    child: const Text('تلاش مجدد'),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QuotePriceRow extends StatelessWidget {
  final String label;
  final int amountToman;
  final bool isDark;
  final bool highlight;
  final bool bold;

  const _QuotePriceRow({
    required this.label,
    required this.amountToman,
    required this.isDark,
    this.highlight = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? MyColors.darkError
        : (isDark ? MyColors.darkTextPrimary : const Color(0xFF29303D));
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: Dimens.nsp(13),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
        Text(
          '${MoneyUtils.formatTomanDisplay(amountToman)} تومان',
          style: TextStyle(
            fontSize: Dimens.nsp(13),
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
