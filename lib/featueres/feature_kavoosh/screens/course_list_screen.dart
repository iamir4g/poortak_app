import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/detailed_course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/book_details_screen.dart';

class CourseListScreen extends StatefulWidget {
  static const String routeName = '/course-list';
  final String title;
  final String? type;

  const CourseListScreen({
    super.key,
    required this.title,
    this.type,
  });

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'همه',
    'ریاضی',
    'علوم تجربی',
    'زبان فارسی',
    'قرآن',
    'هدیه ها'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background1, // Light background color
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
                Flexible(
                  child: Text(
                    widget.title,
                    style: MyTextStyle.textHeader16Bold.copyWith(
                      color: MyColors.textMatn2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60.h,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MyColors.secondary // Orange
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: MyTextStyle.textMatn12W500.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : MyColors.text4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // List of Cards
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
              itemCount: 10,
              itemBuilder: (context, index) {
                // Mock data
                final colors = [
                  const Color(0xFFFBEBDF), // Light orange
                  const Color(0xFFE3F2FD), // Light blue
                  const Color(0xFFF3E5F5), // Light purple
                  const Color(0xFFE8F5E9), // Light green
                ];

                return DetailedCourseCard(
                  title: 'ریاضی سوم دبستان',
                  author: 'سمانه مراقی',
                  date: '۵ ماه پیش',
                  isPurchased: index % 2 == 0, // Alternate purchased status
                  backgroundColor: colors[index % colors.length],
                  onTap: widget.type == 'book'
                      ? () {
                          Navigator.pushNamed(
                            context,
                            BookDetailsScreen.routeName,
                            arguments: {'title': 'ریاضی سوم دبستان'},
                          );
                        }
                      : null,
                  // imagePath: 'assets/images/placeholder_book.png',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
