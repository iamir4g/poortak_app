import 'package:flutter/material.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';

class PaymentResultScreen extends StatelessWidget {
  static const String routeName = '/payment-result';

  final int ok;
  final String? ref;

  const PaymentResultScreen({
    super.key,
    required this.ok,
    this.ref,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("PaymentResultScreen: Building with status='$ok', ref='$ref'");
    final isSuccess = ok == 1 ? true : false;

    debugPrint("PaymentResultScreen: isSuccess=$isSuccess");

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "رسید نهایی",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Status Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess ? Colors.green[50] : Colors.red[50],
                border: Border.all(
                  color: isSuccess ? Colors.green : Colors.red,
                  width: 3,
                ),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                size: 80,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 30),

            // Status Text
            Text(
              isSuccess
                  ? 'پرداخت با موفقیت انجام شد'
                  : 'پرداخت با خطا مواجه شد',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green[700] : Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 40),

            // Payment Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'جزئیات پرداخت',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('کد پیگیری', _getTransactionId()),
                  _buildDetailRow('مبلغ', _getAmount()),
                  _buildDetailRow('روش پرداخت', _getPaymentMethod()),
                  _buildDetailRow('تاریخ و زمان', _getDateTime()),
                  if (ref != null) _buildDetailRow('کد پیگیری', ref!),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            if (isSuccess) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to main app or specific screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      MainWrapper.routeName,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'بازگشت به صفحه اصلی',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      MainWrapper.routeName,
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'بازگشت به صفحه اصلی',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Additional Info
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isSuccess
                          ? 'شما به زودی یک ایمیل تایید خواهید گرفت'
                          : 'لطفا با پشتیبانی تماس بگیرید اگر مشکلات خود را ادامه دهید',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fake data methods - replace with real data later
  String _getTransactionId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  String _getAmount() {
    return '\$29.99'; // Replace with actual amount
  }

  String _getPaymentMethod() {
    return 'Credit Card **** 1234'; // Replace with actual payment method
  }

  String _getDateTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
