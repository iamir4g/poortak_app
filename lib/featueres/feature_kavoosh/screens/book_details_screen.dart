import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class BookDetailsScreen extends StatefulWidget {
  static const String routeName = '/book-detail';
  final String title;

  const BookDetailsScreen({
    super.key,
    required this.title,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                  'کتاب آموزشی دبستان',
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
        child: Column(
          children: [
            SizedBox(height: 24.h),
            // Book Image and Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 200.w,
                    height: 280.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20.r,
                          offset: Offset(0, 10.h),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        'assets/images/placeholder_book.png', // Needs a valid asset or network image
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child:
                              Icon(Icons.book, size: 80.r, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    widget.title,
                    style: MyTextStyle.textMatn18Bold.copyWith(
                      fontSize: 20.sp,
                      color: MyColors.textMatn2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'نسخه الکترونیکی',
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: MyColors.text4,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'قیمت:',
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: MyColors.textMatn2,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '۷۵,۰۰۰ تومان',
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: MyColors.textMatn2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: MyColors.divider, width: 1.h),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: MyColors.primary,
                unselectedLabelColor: MyColors.text4,
                indicatorColor: MyColors.primary,
                indicatorWeight: 3.h,
                labelStyle: MyTextStyle.textMatn14Bold,
                tabs: const [
                  Tab(text: 'درباره کالا'),
                  Tab(text: 'ویژگی های کالا'),
                ],
              ),
            ),

            // Tab Content
            Container(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  _buildDetailRow('ناشر:', 'انتشارات تاجیک'),
                  _buildDetailRow('نویسنده:', 'پرویز تاجیک'),
                  _buildDetailRow('فرمت:', 'PDF'),
                  _buildDetailRow('حجم:', '۲۴ مگابایت'),
                  _buildDetailRow('تعداد صفحه:', '۱۰۵ صفحه'),
                  _buildDetailRow('تاریخ نشر:', '۱۴۰۱'),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: MyColors.text4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'خواندن نمونه',
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: MyColors.text4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'افزودن به سبد خرید',
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: MyTextStyle.textMatn14Bold.copyWith(
              color: MyColors.text4,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: MyTextStyle.textMatn14Bold.copyWith(
              color: MyColors.text3,
            ),
          ),
        ],
      ),
    );
  }
}
