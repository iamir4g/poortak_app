import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/iknow_package_pricing.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/invoice_summary_card.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/payment_security_footer.dart';
import 'package:poortak/featueres/feature_shopping_cart/widgets/referral_code_card.dart';

class CartSummarySection extends StatelessWidget {
  final int subTotal;
  final int discount;
  final int payable;
  final IKnowPackagePricing? packagePricing;
  final Future<void> Function(String code)? onReferralSubmit;

  const CartSummarySection({
    super.key,
    required this.subTotal,
    required this.discount,
    required this.payable,
    this.packagePricing,
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
          packagePricing: packagePricing,
        ),
        SizedBox(height: Dimens.nh(12)),
        ReferralCodeCard(
          onSubmit: onReferralSubmit,
        ),
        SizedBox(height: Dimens.nh(4)),
        const PaymentSecurityFooter(),
      ],
    );
  }
}
