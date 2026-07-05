import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/date_util.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_model.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/locator.dart';

class PaymentResultScreen extends StatefulWidget {
  static const String routeName = '/payment-result';

  final int ok;
  final String? ref;

  const PaymentResultScreen({
    super.key,
    required this.ok,
    this.ref,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  Datum? _payment;
  bool _isLoadingPayment = false;
  String? _paymentError;
  bool _isCartCleared = false;
  bool _isClearingCart = false;
  bool _isNavigatingBack = false;

  @override
  void initState() {
    super.initState();
    if (widget.ok == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSuccessfulPayment();
      });
    } else if (widget.ref != null && widget.ref!.isNotEmpty) {
      _loadPaymentDetails();
    }
  }

  Future<void> _clearCartAfterPayment() async {
    if (_isCartCleared || _isClearingCart) return;

    setState(() => _isClearingCart = true);
    try {
      await locator<ShoppingCartBloc>().clearAfterSuccessfulPayment();
      _isCartCleared = true;
      debugPrint(
          "✅ PaymentResultScreen: Shopping cart cleared after successful payment");
    } catch (e) {
      debugPrint("⚠️ PaymentResultScreen: Failed to clear cart: $e");
    } finally {
      if (mounted) {
        setState(() => _isClearingCart = false);
      }
    }
  }

  Future<void> _handleSuccessfulPayment() async {
    final accessBloc = locator<IknowAccessBloc>();
    accessBloc.add(FetchIknowAccessEvent(forceRefresh: true));
    debugPrint(
        "🔄 PaymentResultScreen: Refreshing IknowAccessBloc after successful payment");

    await _clearCartAfterPayment();

    if (widget.ref != null && widget.ref!.isNotEmpty) {
      await _loadPaymentDetails();
    }
  }

  Future<void> _goToMain() async {
    if (_isNavigatingBack) return;
    _isNavigatingBack = true;

    if (widget.ok == 1) {
      await _clearCartAfterPayment();
    }

    if (!mounted) return;

    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == MainWrapper.routeName || route.isFirst,
    );
  }

  Future<void> _loadPaymentDetails() async {
    if (widget.ref == null || widget.ref!.isEmpty) return;

    setState(() {
      _isLoadingPayment = true;
      _paymentError = null;
    });

    final result =
        await locator<ProfileRepository>().fetchPaymentByRef(widget.ref!);

    if (!mounted) return;

    setState(() {
      _isLoadingPayment = false;
      if (result is DataSuccess<Datum> && result.data != null) {
        _payment = result.data;
      } else {
        _paymentError = result.error ?? "خطا در دریافت اطلاعات پرداخت";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.ok == 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _goToMain();
        }
      },
      child: Scaffold(
      backgroundColor: MyColors.background1,
      appBar: AppBar(
        title: Text(
          "رسید نهایی",
          style: MyTextStyle.textHeader16Bold.copyWith(
            color: MyColors.textLight,
          ),
        ),
        backgroundColor: isSuccess ? MyColors.success : MyColors.error,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors.textLight, size: 24.sp),
          onPressed:
              (_isClearingCart || _isNavigatingBack) ? null : _goToMain,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0.r),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isSuccess ? MyColors.success : MyColors.error)
                      .withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSuccess ? MyColors.success : MyColors.error,
                    width: 3.w,
                  ),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.cancel,
                  size: 80.sp,
                  color: isSuccess ? MyColors.success : MyColors.error,
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                isSuccess
                    ? 'پرداخت با موفقیت انجام شد'
                    : 'پرداخت با خطا مواجه شد',
                style: MyTextStyle.textMatn18Bold.copyWith(
                  fontSize: 22.sp,
                  color: isSuccess ? MyColors.success : MyColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              if (_getTrackingCode() != null)
                Text(
                  'کد پیگیری: ${_getTrackingCode()}',
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    fontWeight: FontWeight.normal,
                    color: MyColors.textSecondary,
                  ),
                ),
              SizedBox(height: 40.h),
              if (_isLoadingPayment)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: DotLoadingWidget(size: 48.r),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: MyColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.shadow,
                        spreadRadius: 1,
                        blurRadius: 10.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'جزئیات پرداخت',
                          style: MyTextStyle.textMatn16Bold.copyWith(
                            color: MyColors.textMatn2,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      if (_paymentError != null)
                        Text(
                          _paymentError!,
                          style: MyTextStyle.textMatn14Bold.copyWith(
                            color: MyColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else ...[
                        _buildDetailRow('محصول', _getProductTitle()),
                        _buildDetailRow('کد پیگیری', _getTrackingCode() ?? '—'),
                        _buildDetailRow('مبلغ', _getAmount()),
                        _buildDetailRow('روش پرداخت', _getPaymentMethod()),
                        if (_getCardPan() != null)
                          _buildDetailRow('شماره کارت', _getCardPan()!),
                        _buildDetailRow('وضعیت', _getStatusText()),
                        _buildDetailRow('تاریخ و زمان', _getDateTime()),
                      ],
                    ],
                  ),
                ),
              SizedBox(height: 30.h),
              if (isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed:
                        (_isClearingCart || _isNavigatingBack) ? null : _goToMain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: _isClearingCart
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: MyColors.textLight,
                            ),
                          )
                        : Text(
                            'بازگشت به صفحه اصلی',
                            style: MyTextStyle.textMatnBtn,
                          ),
                  ),
                ),
              ] else ...[
                SizedBox(height: 15.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: _goToMain,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: MyColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'بازگشت به صفحه اصلی',
                      style: MyTextStyle.textMatn16Bold.copyWith(
                        color: MyColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  color: MyColors.secondaryTint4,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: MyColors.secondaryTint2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: MyColors.secondary, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        isSuccess
                            ? 'دسترسی به محصولات خریداری‌شده برای شما فعال شد'
                            : 'لطفا در صورت کسر وجه با پشتیبانی تماس بگیرید',
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          fontWeight: FontWeight.normal,
                          color: MyColors.secondaryShade2,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: MyTextStyle.textMatn14Bold.copyWith(
                color: MyColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MyTextStyle.textMatn14Bold.copyWith(
                color: MyColors.textMatn2,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProductTitle() {
    if (_payment == null) return '—';

    if (_payment!.items != null && _payment!.items!.isNotEmpty) {
      final description = _payment!.items!.first.description;
      if (description != null && description.toString().isNotEmpty) {
        return description.toString();
      }
    }

    if (_payment!.description != null && _payment!.description!.isNotEmpty) {
      return _payment!.description!;
    }

    return 'خرید محصول';
  }

  String? _getTrackingCode() {
    final trackingCode = _payment?.trackingCode;
    if (trackingCode != null && trackingCode.isNotEmpty) {
      return trackingCode;
    }
    return widget.ref;
  }

  String _getAmount() {
    final grandTotal = _payment?.grandTotal;
    if (grandTotal != null && grandTotal.isNotEmpty) {
      return formatTomanAmount(grandTotal);
    }
    return '—';
  }

  String _getPaymentMethod() {
    switch (_payment?.source) {
      case 'IPG':
        return 'درگاه اینترنتی';
      case 'Card':
        return 'کارت بانکی';
      default:
        return 'درگاه پرداخت';
    }
  }

  String? _getCardPan() {
    final cardPan = _payment?.cardPan;
    if (cardPan == null) return null;
    final value = cardPan.toString().trim();
    return value.isEmpty ? null : value;
  }

  String _getStatusText() {
    switch (_payment?.status) {
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
        return widget.ok == 1 ? 'موفق' : 'ناموفق';
    }
  }

  String _getDateTime() {
    DateTime? dateTime;

    final paidAt = _payment?.paidAt;
    if (paidAt != null) {
      if (paidAt is DateTime) {
        dateTime = paidAt;
      } else {
        dateTime = DateTime.tryParse(paidAt.toString());
      }
    }

    dateTime ??= _payment?.createdAt;

    if (dateTime != null) {
      final date = DateUtil.formatPersianDateWithDigits(dateTime, separator: '/');
      final time =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      return '$date ${toPersianDigits(time)}';
    }

    final now = DateTime.now();
    final date = DateUtil.formatPersianDateWithDigits(now, separator: '/');
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$date ${toPersianDigits(time)}';
  }
}
