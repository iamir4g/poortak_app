import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/date_util.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_bloc/payment_history_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_bloc/payment_history_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/payment_history_bloc/payment_history_state.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? MyColors.profileBackgroundDark : MyColors.background3,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 57.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isDark
                    ? MyColors.paymentHistoryScreenHeaderDark
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33.5.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0D000000),
                    offset: Offset(0, 1.h),
                    blurRadius: 1.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    'تاریخچه خرید',
                    style: MyTextStyle.textHeader16Bold.copyWith(
                      color: isDark
                          ? MyColors.profileTextPrimaryDark
                          : MyColors.textMatn1,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Back Button
                  Container(
                    width: 50.r,
                    height: 50.r,
                    margin: EdgeInsets.only(left: 16.w),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_forward,
                        color: isDark
                            ? MyColors.profileTextPrimaryDark
                            : MyColors.textMatn1,
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocProvider.value(
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
            ),
          ],
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
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: MyTextStyle.textMatn16.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? MyColors.profileTextPrimaryDark
                  : MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
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
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 150.w,
                maxHeight: 230.h,
              ),
              child: const Image(
                image:
                    AssetImage('assets/images/profile/emptyPaymentHistory.png'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10.h),
            // Empty state text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                message ?? 'هنوز خریدی انجام نشده!',
                style: MyTextStyle.textMatn16.copyWith(
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? MyColors.profileTextPrimaryDark
                      : MyColors.textMatn1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                _paymentHistoryBloc.add(RefreshPaymentHistoryEvent());
              },
              child: const Text('بروزرسانی'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(PaymentHistorySuccess state) {
    return RefreshIndicator(
      onRefresh: () async {
        _paymentHistoryBloc.add(RefreshPaymentHistoryEvent());
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: (state.paymentHistoryList.data?.length ?? 0) +
            (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == (state.paymentHistoryList.data?.length ?? 0)) {
            // Load more button
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: ElevatedButton(
                onPressed: () {
                  _paymentHistoryBloc.add(LoadMorePaymentHistoryEvent());
                },
                child: const Text('بارگذاری بیشتر'),
              ),
            );
          }

          final payment = state.paymentHistoryList.data?[index];
          if (payment != null) {
            return PaymentHistoryCard(
              payment: payment,
              onTap: () {
                // Handle payment card tap
                _onPaymentCardTap(payment);
              },
            );
          }
          return const SizedBox.shrink();
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
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'جزئیات تراکنش',
              style: MyTextStyle.textMatn18Bold.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? MyColors.profileTextPrimaryDark
                    : MyColors.textMatn1,
              ),
            ),
            SizedBox(height: 16.h),
            Text('کد پیگیری: ${payment.trackingCode ?? 'نامشخص'}'),
            Text('وضعیت: ${_getStatusText(payment.status)}'),
            Text(
                'مبلغ: ${payment.grandTotal != null ? formatTomanAmount(payment.grandTotal!) : 'نامشخص'}'),
            Text(
                'تاریخ: ${payment.createdAt != null ? DateUtil.formatPersianDateWithDigits(payment.createdAt!, separator: '/') : 'نامشخص'}'),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    if (status == null) return 'نامشخص';

    switch (status) {
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
}
