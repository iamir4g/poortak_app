import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/section_header.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/course_list_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_bloc.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_event.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_state.dart';
import 'package:poortak/locator.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocProvider(
      create: (context) => locator<CategoriesBloc>()
        ..add(
          FetchCategoryNodesSummaryEvent(
            treeType: KavooshTreeType.video,
          ),
        ),
      child: Scaffold(
        backgroundColor: isDark ? MyColors.darkBackground : Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(57.h),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 0),
              height: 57.h,
              decoration: BoxDecoration(
                color: isDark ? MyColors.darkBackgroundSecondary : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33.5.r),
                ),
                boxShadow: isDark
                    ? null
                    : [
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
                      'ویدئو های آموزشی',
                      style: MyTextStyle.textMatn16Bold.copyWith(
                        color: isDark
                            ? MyColors.darkTextPrimary
                            : const Color(0xFF29303D),
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
                        color: isDark
                            ? MyColors.darkTextPrimary
                            : const Color(0xFF29303D),
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
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? MyColors.darkBackgroundSecondary
                        : const Color(0xFFF9F6C6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  child: const Center(),
                ),
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
                Container(
                  height: 2.h,
                  width: double.infinity,
                  color: (isDark ? MyColors.darkBorder : Colors.grey)
                      .withValues(alpha: 0.35),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: _selectedTabIndex == 0
                              ? MyColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: _selectedTabIndex == 1
                              ? MyColors.primary
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                if (_selectedTabIndex == 0) ...[
                  BlocBuilder<CategoriesBloc, CategoriesState>(
                    builder: (context, state) {
                      if (state is CategoriesLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (state is CategoriesError) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Center(
                            child: Text(
                              state.message,
                              style: MyTextStyle.textMatn14Bold.copyWith(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      if (state is CategoriesLoaded) {
                        if (state.categories.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Center(
                              child: Text(
                                'دسته‌بندی‌ای یافت نشد',
                                style: MyTextStyle.textMatn14Bold.copyWith(
                                  color: isDark
                                      ? MyColors.darkTextSecondary
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: state.categories
                              .map((category) => _buildSection(category))
                              .toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
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
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isSelected
                  ? MyColors.primary
                  : (isDark ? MyColors.darkTextSecondary : Colors.grey),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            icon,
            color: isSelected
                ? MyColors.primary
                : (isDark ? MyColors.darkTextSecondary : Colors.grey),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(CategoryNodeSummary category) {
    return Column(
      children: [
        SectionHeader(
          title: category.title,
          onSeeAllTap: () {
            Navigator.pushNamed(
              context,
              CourseListScreen.routeName,
              arguments: {
                'title': 'ویدئو های آموزشی ${category.title}',
                'categoryId': category.id,
                'treeType': KavooshTreeType.video,
              },
            );
          },
        ),
        SizedBox(
          height: 190.h,
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
