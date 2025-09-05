// Example usage of PaymentHistoryCard widget
// This file demonstrates how to use the payment history card widget

import 'package:flutter/material.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_modle.dart';
import 'package:poortak/featueres/feature_profile/widgets/payment_history_card.dart';
import 'package:poortak/common/models/cart_enum.dart';

class PaymentHistoryCardUsageExample extends StatelessWidget {
  const PaymentHistoryCardUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History Card Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Basic usage
          const Text(
            'Basic Payment History Card:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          PaymentHistoryCard(
            payment: _createSamplePayment(),
            onTap: () {
              print('Payment card tapped!');
            },
          ),

          const SizedBox(height: 24),

          // Example 2: Different status cards
          const Text(
            'Different Status Cards:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Pending payment
          PaymentHistoryCard(
            payment: _createSamplePayment(status: Status.PENDING),
            onTap: () => _showSnackBar(context, 'Pending payment tapped'),
          ),

          const SizedBox(height: 8),

          // Succeeded payment
          PaymentHistoryCard(
            payment: _createSamplePayment(status: Status.SUCCEEDED),
            onTap: () => _showSnackBar(context, 'Succeeded payment tapped'),
          ),

          const SizedBox(height: 8),

          // Failed payment
          PaymentHistoryCard(
            payment: _createSamplePayment(status: Status.FAILED),
            onTap: () => _showSnackBar(context, 'Failed payment tapped'),
          ),

          const SizedBox(height: 8),

          // Expired payment
          PaymentHistoryCard(
            payment: _createSamplePayment(status: Status.EXPIRED),
            onTap: () => _showSnackBar(context, 'Expired payment tapped'),
          ),

          const SizedBox(height: 8),

          // Refunded payment
          PaymentHistoryCard(
            payment: _createSamplePayment(status: Status.REFUNDED),
            onTap: () => _showSnackBar(context, 'Refunded payment tapped'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Helper method to create sample payment data
  static Datum _createSamplePayment({Status status = Status.SUCCEEDED}) {
    return Datum(
      id: 'sample-payment-id',
      userId: 'sample-user-id',
      source: Source.IPG,
      status: status,
      trackingCode: 'TRK123456789',
      buyerEmail: BuyerEmail.BEYRAMIBAHAREH_GMAIL_COM,
      buyerMobile: '09123456789',
      discountCode: null,
      discountAmount: '0',
      discountType: null,
      subTotal: '118200',
      grandTotal: '118200',
      referenceId: 'REF123456',
      cardPan: '****1234',
      authority: 'AUTH123456',
      description: 'خرید درس اول سیاره آی نو',
      internalNote: null,
      paidAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        Item(
          id: 'item-1',
          paymentId: 'sample-payment-id',
          itemType: CartType.IKnow,
          itemId: 'lesson-1',
          description: Description.PURCHASING_I_KNOW_COLLECTION,
          discountCode: null,
          discountAmount: '0',
          discountType: DiscountType.PERCENT,
          quantity: 1,
          price: '118200',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}

// Example of how to use the card in different scenarios:

class PaymentHistoryCardExamples {
  // Example 1: Simple card without tap handler
  static Widget simpleCard(Datum payment) {
    return PaymentHistoryCard(payment: payment);
  }

  // Example 2: Card with custom tap handler
  static Widget cardWithTapHandler(Datum payment, VoidCallback onTap) {
    return PaymentHistoryCard(
      payment: payment,
      onTap: onTap,
    );
  }

  // Example 3: Card in a list
  static Widget cardInList(List<Datum> payments) {
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return PaymentHistoryCard(
          payment: payments[index],
          onTap: () {
            // Handle payment tap
            print('Payment ${payments[index].trackingCode} tapped');
          },
        );
      },
    );
  }

  // Example 4: Card with different styling based on status
  static Widget statusBasedCard(Datum payment) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getStatusBorderColor(payment.status),
          width: 2,
        ),
      ),
      child: PaymentHistoryCard(
        payment: payment,
        onTap: () {
          // Handle tap based on status
          _handleStatusBasedTap(payment.status);
        },
      ),
    );
  }

  static Color _getStatusBorderColor(Status status) {
    switch (status) {
      case Status.PENDING:
        return Colors.orange;
      case Status.SUCCEEDED:
        return Colors.green;
      case Status.FAILED:
        return Colors.red;
      case Status.EXPIRED:
        return Colors.grey;
      case Status.REFUNDED:
        return Colors.blue;
    }
  }

  static void _handleStatusBasedTap(Status status) {
    switch (status) {
      case Status.PENDING:
        print('Pending payment - show waiting message');
        break;
      case Status.SUCCEEDED:
        print('Succeeded payment - show success details');
        break;
      case Status.FAILED:
        print('Failed payment - show retry option');
        break;
      case Status.EXPIRED:
        print('Expired payment - show renewal option');
        break;
      case Status.REFUNDED:
        print('Refunded payment - show refund details');
        break;
    }
  }
}
