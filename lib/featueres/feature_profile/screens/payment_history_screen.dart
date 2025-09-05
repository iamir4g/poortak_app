import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_modle.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_state.dart';
import 'package:poortak/featueres/feature_profile/widgets/payment_history_card.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';

class PaymentHistoryScreen extends StatefulWidget {
  static const routeName = "/payment_history_screen";
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late PaymentHistoryBloc _paymentHistoryBloc;

  @override
  void initState() {
    super.initState();
    _paymentHistoryBloc = PaymentHistoryBloc(
      repository: locator<ProfileRepository>(),
    );
    // Load payment history on screen initialization
    _paymentHistoryBloc.add(LoadPaymentHistoryEvent());
  }

  @override
  void dispose() {
    _paymentHistoryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background3,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: MyColors.textMatn1),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'تاریخچه خرید',
          style: TextStyle(
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: MyColors.textMatn1,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(33.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                offset: Offset(0, 1),
                blurRadius: 1,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(33.5),
          ),
        ),
      ),
      body: BlocProvider.value(
        value: _paymentHistoryBloc,
        child: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
          builder: (context, state) {
            if (state is PaymentHistoryLoading) {
              return _buildLoadingState();
            } else if (state is PaymentHistoryError) {
              return _buildErrorState(state.message);
            } else if (state is PaymentHistoryEmpty) {
              return _buildEmptyState(state.message);
            } else if (state is PaymentHistorySuccess) {
              return _buildSuccessState(state);
            }
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(MyColors.primary),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'IRANSans',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _paymentHistoryBloc.add(LoadPaymentHistoryEvent());
            },
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Container(
            width: 150,
            height: 230,
            child: Image(
              image:
                  AssetImage('assets/images/profile/emptyPaymentHistory.png'),
            ),
          ),
          const SizedBox(height: 32),
          // Empty state text
          Text(
            message ?? 'هنوز خریدی انجام نشده!',
            style: const TextStyle(
              fontFamily: 'IRANSans',
              fontWeight: FontWeight.w300,
              fontSize: 16,
              color: MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _paymentHistoryBloc.add(RefreshPaymentHistoryEvent());
            },
            child: const Text('بروزرسانی'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(PaymentHistorySuccess state) {
    return RefreshIndicator(
      onRefresh: () async {
        _paymentHistoryBloc.add(RefreshPaymentHistoryEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.paymentHistoryList.data.length +
            (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == state.paymentHistoryList.data.length) {
            // Load more button
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _paymentHistoryBloc.add(LoadMorePaymentHistoryEvent());
                },
                child: const Text('بارگذاری بیشتر'),
              ),
            );
          }

          final payment = state.paymentHistoryList.data[index];
          return PaymentHistoryCard(
            payment: payment,
            onTap: () {
              // Handle payment card tap
              _onPaymentCardTap(payment);
            },
          );
        },
      ),
    );
  }

  void _onPaymentCardTap(payment) {
    // Handle payment card tap - you can navigate to payment details
    // or show a bottom sheet with more details
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'جزئیات تراکنش',
              style: const TextStyle(
                fontFamily: 'IRANSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: MyColors.textMatn1,
              ),
            ),
            const SizedBox(height: 16),
            Text('کد پیگیری: ${payment.trackingCode}'),
            Text('وضعیت: ${_getStatusText(payment.status)}'),
            Text('مبلغ: ${_formatAmount(payment.grandTotal)}'),
            Text('تاریخ: ${_formatDate(payment.createdAt)}'),
          ],
        ),
      ),
    );
  }

  String _getStatusText(status) {
    switch (status) {
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
      default:
        return 'نامشخص';
    }
  }

  String _formatAmount(String amount) {
    try {
      final numAmount = double.parse(amount);
      final formattedAmount = numAmount.toStringAsFixed(0);
      return '${_toPersianNumbers(formattedAmount)} تومان';
    } catch (e) {
      return '${_toPersianNumbers(amount)} تومان';
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
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
