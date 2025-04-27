import 'package:url_launcher/url_launcher.dart';
import 'package:zarinpal/zarinpal.dart';

class PaymentService {
  final PaymentRequest _paymentRequest = PaymentRequest();
  String? _authority;

  Future<void> startPayment({
    required int amount,
    required String description,
    required String callbackUrl,
    required Function(bool isSuccess, String? refId) onPaymentComplete,
  }) async {
    // Initialize payment request
    _paymentRequest
      ..setIsSandBox(true) // Enable sandbox mode for testing
      // ..setMerchantID("60eaaca9-81aa-4920-83b5-c08a20d27635")
      ..setMerchantID("89ed112e-44c7-4701-a484-07a9695d955e")
      ..setAmount(amount)
      ..setCallbackURL(callbackUrl)
      ..setDescription(description);

    // Start payment
    ZarinPal().startPayment(_paymentRequest,
        (int? status, String? paymentGatewayUri, data) async {
      if (status == 100 && paymentGatewayUri != null) {
        // Store the authority for later verification
        _authority = data['Authority'];
        print('Payment started with authority: $_authority');

        // Launch payment gateway URL in browser
        final Uri url = Uri.parse(paymentGatewayUri);
        print('Launching payment URL: $url');
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } catch (e) {
          print('Could not launch payment URL: $e');
        }
      } else {
        print('Payment start failed with status: $status');
        onPaymentComplete(false, null);
      }
    });
  }

  Future<void> verifyPayment(String status, String authority) async {
    if (status == 'OK' && authority.isNotEmpty) {
      ZarinPal().verificationPayment(
        status,
        authority,
        _paymentRequest,
        (isPaymentSuccess, refID, paymentRequest, data) {
          print(
              'Payment verification result: $isPaymentSuccess, RefID: $refID');
          // You can call a callback here if needed
        },
      );
    }
  }
}
