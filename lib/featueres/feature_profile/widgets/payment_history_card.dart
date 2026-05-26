import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/date_util.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_model.dart';

class PaymentHistoryCard extends StatelessWidget {
  final Datum payment;
  final VoidCallback? onTap;

  const PaymentHistoryCard({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? MyColors.paymentHistoryCardDark : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 1.h),
            blurRadius: 4.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with gray background
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? MyColors.paymentHistoryCardHeaderDark
                        : MyColors.paymentHistoryCardHeaderLight,
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Row(
                    children: [
                      // Product title
                      Expanded(
                        child: Text(
                          _getProductTitle(),
                          style: MyTextStyle.textMatn14Bold.copyWith(
                            color: isDark
                                ? MyColors.profileTextPrimaryDark
                                : MyColors.paymentHistoryHeaderTitleLight,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Status icon
                      _buildStatusIcon(),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Details section
                _buildDetailRow(
                  context: context,
                  label: 'تاریخ خرید',
                  value: payment.createdAt != null
                      ? _formatDate(payment.createdAt!)
                      : 'نامشخص',
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  context: context,
                  label: 'وضعیت خرید',
                  value: _getStatusText(),
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  context: context,
                  label: 'مبلغ پرداخت شده',
                  value: payment.grandTotal != null
                      ? _formatAmount(payment.grandTotal!)
                      : 'نامشخص',
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  context: context,
                  label: 'مبلغ کل خرید',
                  value: payment.grandTotal != null
                      ? _formatAmount(payment.grandTotal!)
                      : 'نامشخص',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 25.w,
      height: 25.h,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getStatusIcon(),
        color: Colors.white,
        size: 16.sp,
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label (left side in RTL)
        Text(
          label,
          style: MyTextStyle.paymentHistoryLabel14Light.copyWith(
            color: isDark
                ? MyColors.profileTextPrimaryDark
                : MyColors.paymentHistoryDetailLabelLight,
          ),
        ),
        // Value (right side in RTL)
        Text(
          value,
          style: MyTextStyle.paymentHistoryValue14Medium.copyWith(
            color: isDark
                ? MyColors.profileTextPrimaryDark
                : MyColors.paymentHistoryDetailValueLight,
          ),
        ),
      ],
    );
  }

  String _getProductTitle() {
    // Extract product name from description or items
    if (payment.items != null && payment.items!.isNotEmpty) {
      final item = payment.items!.first;
      if (item.description != null) {
        return item.description.toString();
      }
    }
    return payment.description != null && payment.description!.isNotEmpty
        ? payment.description!
        : 'خرید محصول';
  }

  String _getStatusText() {
    if (payment.status == null) return 'نامشخص';

    switch (payment.status) {
      case 'Pending':
        return 'در انتظار';
      case 'Succeeded':
        return 'موفق';
      case 'Failed':
        return 'ناموفق';
      case 'Expired':
        return 'منقضی شده';
      case 'Refunded':
        return 'برگشت خورده';
      default:
        return 'نامشخص';
    }
  }

  Color _getStatusColor() {
    if (payment.status == null) return const Color(0xFF9E9E9E);

    switch (payment.status) {
      case 'Pending':
        return const Color(0xFFFFA726); // Orange
      case 'Succeeded':
        return const Color(0xFF4CAF50); // Green
      case 'Failed':
        return const Color(0xFFF44336); // Red
      case 'Expired':
        return const Color(0xFF9E9E9E); // Gray
      case 'Refunded':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Gray
    }
  }

  IconData _getStatusIcon() {
    if (payment.status == null) return Icons.help_outline;

    switch (payment.status) {
      case 'Pending':
        return Icons.schedule;
      case 'Succeeded':
        return Icons.check;
      case 'Failed':
        return Icons.close;
      case 'Expired':
        return Icons.access_time;
      case 'Refunded':
        return Icons.undo;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return DateUtil.formatPersianDateWithDigits(date, separator: '/');
  }

  String _formatAmount(String amount) {
    return formatTomanAmount(amount);
  }
}
