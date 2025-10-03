import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class TermsConditionsModal extends StatelessWidget {
  const TermsConditionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 333,
        height: 848,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 73,
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // const Spacer(),
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "قوانین و مقررات ",
                              style: MyTextStyle.textMatn12Bold.copyWith(
                                fontSize: 15,
                                color: const Color(0xFFF88F48), // Orange color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "خرید از پورتک",
                              style: MyTextStyle.textMatn12Bold.copyWith(
                                fontSize: 15,
                                color: MyColors.textMatn1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Empty space to balance the close button
                      const SizedBox(width: 24),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 24,
                          height: 24,
                          // decoration: BoxDecoration(
                          //   color: MyColors.secondary,
                          //   borderRadius: BorderRadius.circular(12),
                          // ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: MyColors.divider,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'اطلاعات شخصی کاربران همانند ایمیل، شماره همراه و… با حفظ حریم شخصی در اپلیکیشن ثبت می‌شود. علاوه‌ بر آن به منظور اطلاع رسانی بهتر تخفیفات ویژه و سایر تخفیفات مناسبتی سایت، ایمیل یا پیامک به آدرس الکترونیک و یا شماره‌ همراه ثبت شده‌ کاربر ارسال خواهد شد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'کلیه حقوق و امتیازات مجموعه آموزشی سیاره آی نو متعلق به انتشارات تاجیک می باشد و هر گونه کپی برداری و تکثیر از آن غیر مجاز بوده و پیگرد قانونی به همراه خواهد داشت.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ثبت، پردازش و ارسال سفارش سفارش های فبزیکی ثبت شده در طول روزهای کاری و اولین روز پس از تعطیلات پردازش می شوند، و ارسال از طریق پست به تهران و شهرستان ها میسر می باشد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'کاربران باید هنگام سفارش کالای مورد نظر خود، فرم سفارش را با اطلاعات صحیح و به طور کامل تکمیل کنند. بدیهی است درصورت ورود اطلاعات ناقص یا نادرست، سفارش کاربر قابل پیگیری و تحویل نخواهد بود. بنابراین درج آدرس، ایمیل و شماره تماس همراه مشتری، به منزله مورد تایید بودن صحت آنها است و در صورتی که این موارد به صورت صحیح یا کامل درج نشده باشد،همچنین، مشتریان می‌توانند نام، آدرس و تلفن شخص دیگری را برای تحویل گرفتن سفارش وارد کنند و تحویل گیرنده سفارش هنگام دریافت کالا باید کارت شناسایی همراه داشته باشد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'برای سفارش یک کالا به تعداد بالا، لازم است پیش از ارسال، سفارش مشتریان ابتدا توسط پشتیبان بررسی و در صورت تایید، پردازش گردد. در صورت عدم تایید سفارشات با هماهنگی مشتری کنسل شده و در صورت واریز وجه، مبلغ پرداخت شده طی 5 الی 7 روز کاری به حساب مشتری عودت داده خواهد شد.',
                      style: MyTextStyle.textMatn13.copyWith(
                        fontSize: 14,
                        color: MyColors.textMatn1,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 20),
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
