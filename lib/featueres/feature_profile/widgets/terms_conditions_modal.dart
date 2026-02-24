import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class TermsConditionsModal extends StatelessWidget {
  const TermsConditionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        width: 333.w,
        height: 600.h, // Adjusted height to be more reasonable
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 73.h,
              padding: EdgeInsets.symmetric(horizontal: 19.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "قوانین و مقررات ",
                              style: MyTextStyle.textMatn12Bold.copyWith(
                                fontSize: 15.sp,
                                color: const Color(0xFFF88F48), // Orange color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "خرید از پورتک",
                              style: MyTextStyle.textMatn12Bold.copyWith(
                                fontSize: 15.sp,
                                color: MyColors.textMatn1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Empty space to balance the close button
                      SizedBox(width: 24.w),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 1.h,
                    color: MyColors.divider,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 19.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Text(
                      'اطلاعات شخصی کاربران همانند ایمیل، شماره همراه و… با حفظ حریم شخصی در اپلیکیشن ثبت می‌شود. علاوه‌ بر آن به منظور اطلاع رسانی بهتر تخفیفات ویژه و سایر تخفیفات مناسبتی سایت، ایمیل یا پیامک به آدرس الکترونیک و یا شماره‌ همراه ثبت شده‌ کاربر ارسال خواهد شد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14.sp,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'کلیه حقوق و امتیازات مجموعه آموزشی سیاره آی نو متعلق به انتشارات تاجیک می باشد و هر گونه کپی برداری و تکثیر از آن غیر مجاز بوده و پیگرد قانونی به همراه خواهد داشت.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14.sp,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'ثبت، پردازش و ارسال سفارش سفارش های فبزیکی ثبت شده در طول روزهای کاری و اولین روز پس از تعطیلات پردازش می شوند، و ارسال از طریق پست به تهران و شهرستان ها میسر می باشد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14.sp,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'کاربران باید هنگام سفارش کالای مورد نظر خود، فرم سفارش را با اطلاعات صحیح و به طور کامل تکمیل کنند. بدیهی است درصورت ورود اطلاعات ناقص یا نادرست، سفارش کاربر قابل پیگیری و تحویل نخواهد بود. بنابراین درج آدرس، ایمیل و شماره تماس همراه مشتری، به منزله مورد تایید بودن صحت آنها است و در صورتی که این موارد به صورت صحیح یا کامل درج نشده باشد،همچنین، مشتریان می‌توانند نام، آدرس و تلفن شخص دیگری را برای تحویل گرفتن سفارش وارد کنند و تحویل گیرنده سفارش هنگام دریافت کالا باید کارت شناسایی همراه داشته باشد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14.sp,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'برای سفارش یک کالا به تعداد بالا، لازم است پیش از ارسال، سفارش مشتریان ابتدا توسط پشتیبان بررسی و در صورت تایید، پردازش گردد. در صورت عدم تایید سفارشات با هماهنگی مشتری کنسل شده و در صورت واریز وجه، مبلغ پرداخت شده طی 5 الی 7 روز کاری به حساب مشتری عودت داده خواهد شد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14.sp,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const TermsConditionsModal();
      },
    );
  }
}
