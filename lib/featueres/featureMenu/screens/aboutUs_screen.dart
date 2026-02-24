import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class AboutUsScreen extends StatelessWidget {
  static const routeName = '/about-us';

  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background3,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 57.h,
              decoration: BoxDecoration(
                color: Colors.white,
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
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    left: 16.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_forward,
                          color: MyColors.textMatn1,
                          size: 24.r,
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        'درباره ی ما',
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: MyColors.textCancelButton,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    // Main content text
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'در حدود ۳۰ سال پیش مؤسسه ی انتشارات تاجیک اقدام به چاپ و نشر کتاب های کار در زمینه ی آموزش درس زبان انگلیسی نمود و در این راه پیش قدم شد.',
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'این کتاب ها که با نام تست و نمونه سؤالات انگلیسی توسط پرویز تاجیک تالیف شده بودند، چنان مورد استقبال دبیران زبان و دانش آموزان مدارس راهنمایی و دبیرستان ها و چندی بعد دوره های پیش دانشگاهی قرار گرفتند که هر کدام دهها بار با تیراژهای بسیار بالا تجدید چاپ شدند.',
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'در بسیاری از مدارس راهنمایی و دبیرستان های کشور،دبیران از این کتاب ها در کنار کتاب درسی استفاده می کردند و دانش آموزان زیادی با استفاده از این کتاب هاتوانستند به سهولت زبان انگلیسی پایه ی خود را یاد بگیرند و به نمرات بالایی در امتحانات دست یابند.',
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'کتاب هایی که هنوز هم با نام (( آزمون و نمونه سؤالات انگلیسی)) توسط انتشارات تاجیک چاپ می شوند و خاطره خوش آن ها در ذهن دانش آموزان آن سال ها(والدین فعلی) باقی مانده است.',
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'چند سال پیش این مؤسسه تصمیم گرفت که علاوه بر چاپ کتاب در زمینه های مختلف یک سریال انیمیشنی هم با حال و هوای فرهنگ ایرانی اسلامی تهیه کند و در آن مکالمات روزمره ی انگلیسی را آموزش دهد.',
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'سریالی که در کنار آموزش مکالمات زبان، داستانی سرگرم کننده و جذاب و خنده دار هم داشته باشد که مورد استقبال همه قرار بگیرد. از کودک دوساله تا افراد میان سال و تمام کسانی که به یادگیری مکالمات انگلیسی علاقه مند هستند یا مجبورند آن ها را بیاموزند. این پروژه توسط یک تیم انیمیشن مجرب و با سابقه تهیه شده است.',
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'در این سریال 8 قسمتی، تقریبا بسیاری از مکالمات روزمره ی انگلیسی در قالب یک داستان آموزش داده شده اند و در کتاب های دستور زبان پورتک و کتاب فرهنگ لغات پورتک تمامی نکات و لغت های استفاده شده در انیمیشن گرد آوری شده که می توانید آن ها را با استفاده از سرویس اشتراک پورتک آنها را تهیه کنید.',
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Taxi driver image
                    Container(
                      height: 175.h,
                      width: 247.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/bb988dc544213a4e701876539a24257f921a670f.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
