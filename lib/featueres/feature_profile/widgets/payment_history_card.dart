import 'package:flutter/material.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_modle.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with gray background
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: [
                      // Product title
                      Expanded(
                        child: Text(
                          _getProductTitle(),
                          style: const TextStyle(
                            fontFamily: 'IRANSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF29303D),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status icon
                      _buildStatusIcon(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Details section
                _buildDetailRow(
                  label: 'تاریخ خرید',
                  value: _formatDate(payment.createdAt),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  label: 'وضعیت خرید',
                  value: _getStatusText(),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  label: 'مبلغ پرداخت شده',
                  value: _formatAmount(payment.grandTotal),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  label: 'مبلغ کل خرید',
                  value: _formatAmount(payment.grandTotal),
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
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getStatusIcon(),
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Value (right side in RTL)
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF494E6A),
            height: 1.2,
          ),
        ),
        // Label (left side in RTL)
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w300,
            fontSize: 14,
            color: Color(0xFF717483),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  String _getProductTitle() {
    // Extract product name from description or items
    if (payment.items.isNotEmpty) {
      final item = payment.items.first;
      return item.description.toString().replaceAll('Description.', '');
    }
    return payment.description.isNotEmpty ? payment.description : 'خرید محصول';
  }

  String _getStatusText() {
    switch (payment.status) {
      case Status.PENDING:
        return 'در انتظار';
      case Status.SUCCEEDED:
        return 'موفق';
      case Status.FAILED:
        return 'ناموفق';
      case Status.EXPIRED:
        return 'منقضی شده';
      case Status.REFUNDED:
        return 'برگشت خورده';
    }
  }

  Color _getStatusColor() {
    switch (payment.status) {
      case Status.PENDING:
        return const Color(0xFFFFA726); // Orange
      case Status.SUCCEEDED:
        return const Color(0xFF4CAF50); // Green
      case Status.FAILED:
        return const Color(0xFFF44336); // Red
      case Status.EXPIRED:
        return const Color(0xFF9E9E9E); // Gray
      case Status.REFUNDED:
        return const Color(0xFF2196F3); // Blue
    }
  }

  IconData _getStatusIcon() {
    switch (payment.status) {
      case Status.PENDING:
        return Icons.schedule;
      case Status.SUCCEEDED:
        return Icons.check;
      case Status.FAILED:
        return Icons.close;
      case Status.EXPIRED:
        return Icons.access_time;
      case Status.REFUNDED:
        return Icons.undo;
    }
  }

  String _formatDate(DateTime date) {
    // Format date as Persian date (you might want to use a Persian date package)
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }

  String _formatAmount(String amount) {
    // Format amount with proper Persian number formatting
    try {
      final numAmount = double.parse(amount);
      final formattedAmount = numAmount.toStringAsFixed(0);
      return '${_toPersianNumbers(formattedAmount)} تومان';
    } catch (e) {
      return '${_toPersianNumbers(amount)} تومان';
    }
  }

  String _toPersianNumbers(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], persian[i]);
    }
    return text;
  }
}
