import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/invoice_summary_card.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/payment_security_footer.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/referral_code_card.dart';

class CartSummarySection extends StatelessWidget {
  final int subTotal;
  final int discount;
  final int payable;
  final ValueChanged<String>? onReferralSubmit;

  const CartSummarySection({
    super.key,
    required this.subTotal,
    required this.discount,
    required this.payable,
    this.onReferralSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InvoiceSummaryCard(
          subTotal: subTotal,
          discount: discount,
          payable: payable,
        ),
        SizedBox(height: Dimens.nh(12)),
        Padding(
          padding: EdgeInsets.only(bottom: Dimens.nh(8)),
          child: ReferralCodeCard(
            onSubmit: onReferralSubmit,
          ),
        ),
        const PaymentSecurityFooter(),
      ],
    );
  }
}
