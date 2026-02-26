import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class FavoritScreen extends StatefulWidget {
  static const routeName = "/favorit_screen";
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  // این متغیر برای نمایش حالت خالی یا پر استفاده می‌شود
  bool hasFavorites = false; // برای تست، true کنید تا حالت پر نمایش داده شود

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? MyColors.darkBackground : MyColors.background3,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDarkMode),

            // Content
            Expanded(
              child: hasFavorites
                  ? _buildFavoritesList(isDarkMode)
                  : _buildEmptyState(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      height: 57.h,
      margin: EdgeInsets.only(top: 22.h),
      child: Stack(
        children: [
          // Header Background
          Container(
            height: 57.h,
            decoration: BoxDecoration(
              color:
                  isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(33.5.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 1.h),
                  blurRadius: 1.r,
                ),
              ],
            ),
          ),

          // Title
          Positioned(
            right: 32.w,
            top: 16.h,
            child: Text(
              'علاقه مندی ها',
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: isDarkMode ? Colors.white : MyColors.textMatn1,
              ),
            ),
          ),

          // Back Button
          Positioned(
            left: 16.w,
            top: 11.h,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 35.r,
                height: 35.r,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode ? Colors.white : MyColors.textMatn1,
                  size: 20.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Image
          Transform.rotate(
            angle: 0.025, // تقریباً 1.435 درجه
            child: SizedBox(
              width: 110.7.w,
              height: 212.8.h,
              child: Image.asset(
                'assets/images/favorit/Delivery_Final.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: 58.h),

          // Empty State Text
          Text(
            'هنوز چیزی اضافه نکردی!',
            style: MyTextStyle.textMatn16.copyWith(
              color: isDarkMode ? Colors.white : MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(bool isDarkMode) {
    return ListView.builder(
      padding: EdgeInsets.all(17.r),
      itemCount: 5, // تعداد آیتم‌های نمونه
      itemBuilder: (context, index) {
        return _buildFavoriteItem(isDarkMode, index);
      },
    );
  }

  Widget _buildFavoriteItem(bool isDarkMode, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Stack(
        children: [
          // Main Container
          Container(
            decoration: BoxDecoration(
              color:
                  isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 0),
                  blurRadius: 4.r,
                ),
              ],
            ),
            child: Row(
              children: [
                // Content Section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Title
                        Text(
                          'درس اول آموزش زبان انگلیسی (سیاره آی نو)',
                          style: MyTextStyle.textMatn13.copyWith(
                            color:
                                isDarkMode ? Colors.white : MyColors.textMatn1,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 12.h),

                        // Play Button
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: MyColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Image Section
                Container(
                  width: 110.r,
                  height: 110.r,
                  margin: EdgeInsets.all(17.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.asset(
                      'assets/images/favorit/Delivery_Final.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Favorite Button
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () {
                // حذف از علاقه‌مندی‌ها
                setState(() {
                  // در اینجا باید آیتم از لیست حذف شود
                });
              },
              child: Container(
                width: 17.r,
                height: 17.r,
                decoration: BoxDecoration(
                  color: MyColors.error,
                  borderRadius: BorderRadius.circular(8.5.r),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 10.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
