import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
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
  @override
  void initState() {
    super.initState();
    // Refresh access data if payment was successful
    if (widget.ok == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final accessBloc = locator<IknowAccessBloc>();
        accessBloc.add(FetchIknowAccessEvent(forceRefresh: true));
        debugPrint(
            "🔄 PaymentResultScreen: Refreshing IknowAccessBloc after successful payment");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "PaymentResultScreen: Building with status='${widget.ok}', ref='${widget.ref}'");
    final isSuccess = widget.ok == 1;

    debugPrint("PaymentResultScreen: isSuccess=$isSuccess");

    return Scaffold(
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
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors.textLight, size: 24.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0.r),
          child: Column(
            children: [
              SizedBox(height: 40.h),

              // Status Icon
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

              // Status Text
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

              if (isSuccess && widget.ref != null)
                Text(
                  'کد پیگیری: ${widget.ref}',
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    fontWeight: FontWeight.normal,
                    color: MyColors.textSecondary,
                  ),
                ),

              SizedBox(height: 40.h),

              // Payment Details Card
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
                    _buildDetailRow('کد پیگیری', _getTransactionId()),
                    _buildDetailRow('مبلغ', _getAmount()),
                    _buildDetailRow('روش پرداخت', _getPaymentMethod()),
                    _buildDetailRow('تاریخ و زمان', _getDateTime()),
                    if (widget.ref != null)
                      _buildDetailRow('کد پیگیری', widget.ref!),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Action Buttons
              if (isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to main app or specific screen
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        MainWrapper.routeName,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
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
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        MainWrapper.routeName,
                        (route) => false,
                      );
                    },
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

              // Additional Info
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
                            ? 'شما به زودی یک ایمیل تایید خواهید گرفت'
                            : 'لطفا با پشتیبانی تماس بگیرید اگر مشکلات خود را ادامه دهید',
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

  // Fake data methods - replace with real data later
  String _getTransactionId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  String _getAmount() {
    return '۲۹,۹۰۰ تومان'; // Replace with actual amount
  }

  String _getPaymentMethod() {
    return 'Credit Card **** 1234'; // Replace with actual payment method
  }

  String _getDateTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
