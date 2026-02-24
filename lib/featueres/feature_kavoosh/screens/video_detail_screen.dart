import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/session_item.dart';

class VideoDetailScreen extends StatefulWidget {
  static const String routeName = '/video-detail';
  final String title;

  const VideoDetailScreen({
    super.key,
    required this.title,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background1,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(57.h),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 0),
            height: 57.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(33.5.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: Offset(0, 1.h),
                  blurRadius: 1.r,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: MyColors.textMatn2,
                  ),
                ),
                SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_forward,
                      color: MyColors.textMatn2,
                      size: 28.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Video Player Placeholder
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder Icon
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Icon(
                      Icons.movie_creation_outlined,
                      color: const Color(0xFF2196F3),
                      size: 30.r,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'برای تماشای ویدئو روی بخش مورد نظر\nکلیک کنید.',
                    textAlign: TextAlign.center,
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: MyColors.text3,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Teacher Info Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teacher Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          color: Colors.grey[200],
                          // child: Image.asset(...), 
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: MyTextStyle.textMatn16Bold.copyWith(
                                color: MyColors.textMatn2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'نام استاد:',
                                  style: MyTextStyle.textMatn12W500.copyWith(
                                    color: MyColors.text4,
                                  ),
                                ),
                                Text(
                                  'فاطمه میرایی', // Mock data
                                  style: MyTextStyle.textMatn12Bold.copyWith(
                                    color: MyColors.textMatn2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'قیمت دوره:',
                                  style: MyTextStyle.textMatn12W500.copyWith(
                                    color: MyColors.text4,
                                  ),
                                ),
                                Text(
                                  '۷۵,۰۰۰ تومان', // Mock data
                                  style: MyTextStyle.textMatn12Bold.copyWith(
                                    color: MyColors.textMatn2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Expandable Description
                  if (_isDescriptionExpanded) ...[
                    SizedBox(height: 16.h),
                    const Divider(),
                    SizedBox(height: 8.h),
                    Text(
                      'درباره ی استاد:',
                      style: MyTextStyle.textMatn12Bold.copyWith(
                        color: MyColors.text4,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'تالیف کتاب کار ریاضی چهارم کلاغ سپید - ریاضی چهارم چهل قدم کلاغ سپید - کتاب فارسی ششم منتشران - موسسه المپیاد ریاضی - مدرس غیر انتفاعی',
                      style: MyTextStyle.textMatn12W500.copyWith(
                        color: MyColors.text3,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: MyColors.background1,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'مدت زمان کل این دوره:',
                            style: MyTextStyle.textMatn12W500.copyWith(
                              color: MyColors.text4,
                            ),
                          ),
                          Text(
                            '۱۴ ساعت و ۲۰ دقیقه',
                            style: MyTextStyle.textMatn12Bold.copyWith(
                              color: MyColors.textMatn2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isDescriptionExpanded ? 'بستن اطلاعات' : 'اطلاعات دوره',
                          style: MyTextStyle.textMatn12Bold.copyWith(
                            color: MyColors.primary,
                          ),
                        ),
                        Icon(
                          _isDescriptionExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_left,
                          color: MyColors.primary,
                          size: 20.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Sessions List
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SessionItem(
                    title: 'جلسه صفر - پیش نمایش دوره',
                    isLocked: false, // Free
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه یک - حل مسئله - الگو یابی - شمارش...',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه دو - مرور فصل ۶',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه سه - آمار و احتمال',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه چهار - احتمال',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه پنج - نمودار دایره ای',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  // Add more items as needed
                ],
              ),
            ),
            
            SizedBox(height: 80.h), // Space for bottom button
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              // Add to cart action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.secondary, // Blue button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 4,
            ),
            child: Text(
              'اضافه به سبد خرید',
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
