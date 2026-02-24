import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/section_header.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/course_list_screen.dart';

class EducationalVideosScreen extends StatefulWidget {
  static const String routeName = '/educational-videos';

  const EducationalVideosScreen({super.key});

  @override
  State<EducationalVideosScreen> createState() =>
      _EducationalVideosScreenState();
}

class _EducationalVideosScreenState extends State<EducationalVideosScreen> {
  int _selectedTabIndex = 0; // 0 for Courses, 1 for Shorts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  'ویدئو های آموزشی',
                  style: MyTextStyle.textMatn16Bold.copyWith(
                    color: const Color(0xFF29303D),
                  ),
                ),
                SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_forward,
                      color: const Color(0xFF29303D),
                      size: 28.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Slider Placeholder
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F6C6), // Light yellow placeholder
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(0), // Figma might show different
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: const Center(
                    // child: Text('Slider Placeholder'),
                    ),
              ),

              // Custom Tabs
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabItem(0, 'دوره ها', Icons.play_circle_outline),
                    SizedBox(width: 24.w),
                    _buildTabItem(1, 'کوتاه آموزشی', Icons.movie_outlined),
                  ],
                ),
              ),
              // Divider line for tabs
              Container(
                height: 2.h,
                width: double.infinity,
                color: Colors.grey.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                            color: _selectedTabIndex == 0
                                ? Colors.orange
                                : Colors.transparent)),
                    Expanded(
                        child: Container(
                            color: _selectedTabIndex == 1
                                ? Colors.orange
                                : Colors.transparent)),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Content Sections
              if (_selectedTabIndex == 0) ...[
                _buildSection('پایه اول دبستان'),
                _buildSection('پایه دوم دبستان'),
                _buildSection('پایه سوم دبستان'),
                _buildSection('پایه چهارم دبستان'),
              ] else ...[
                SizedBox(
                  height: 200.h,
                  child: const Center(child: Text('محتوای کوتاه آموزشی')),
                ),
              ],

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Row(
        children: [
          Text(
            title,
            style: MyTextStyle.textMatn14Bold.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.grey,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () {
            Navigator.pushNamed(
              context,
              CourseListScreen.routeName,
              arguments: {'title': 'ویدئو های آموزشی $title'},
            );
          },
        ),
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 5,
            itemBuilder: (context, index) {
              // Alternating background colors for demo
              final colors = [
                const Color(0xFFFBEBDF), // Light orange
                const Color(0xFFE3F2FD), // Light blue
                const Color(0xFFF3E5F5), // Light purple
              ];
              return CourseCard(
                title: 'ریاضی',
                backgroundColor: colors[index % colors.length],
                // imagePath: 'assets/images/placeholder_book.png',
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
