import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_bloc.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_event.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_state.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/category_content_section.dart';
import 'package:poortak/locator.dart';

class EducationalVideosScreen extends StatefulWidget {
  static const String routeName = '/educational-videos';

  const EducationalVideosScreen({super.key});

  @override
  State<EducationalVideosScreen> createState() =>
      _EducationalVideosScreenState();
}

class _EducationalVideosScreenState extends State<EducationalVideosScreen> {
  int _selectedTabIndex = 0;
  List<CategoryNodeSummary> _rootTabs = const [];

  IconData _tabIconFor(CategoryNodeSummary tab) {
    final title = tab.title;
    if (title.contains('کوتاه')) return Icons.movie_outlined;
    return Icons.play_circle_outline;
  }

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
        appBar: PoortakAppBar(
          title: 'ویدئو های آموزشی',
          titleStyle: MyTextStyle.textMatn16Bold,
          foregroundColor:
              isDark ? MyColors.darkTextPrimary : const Color(0xFF29303D),
        ),
        body: SafeArea(
          top: false,
          child: BlocConsumer<CategoriesBloc, CategoriesState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                setState(() {
                  final wasEmpty = _rootTabs.isEmpty;
                  _rootTabs = state.categories;
                  if (wasEmpty) {
                    final preferred =
                        _rootTabs.indexWhere((e) => e.title == 'دوره ها');
                    _selectedTabIndex = preferred >= 0 ? preferred : 0;
                  } else if (_selectedTabIndex >= _rootTabs.length) {
                    _selectedTabIndex = 0;
                  }
                });
              }
            },
            builder: (context, state) {
              if (state is CategoriesLoading && _rootTabs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CategoriesError && _rootTabs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
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
              if (_rootTabs.isEmpty) {
                return Center(
                  child: Text(
                    'دسته‌بندی‌ای یافت نشد',
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: isDark ? MyColors.darkTextSecondary : Colors.grey,
                    ),
                  ),
                );
              }

              final selectedTab = _rootTabs[_selectedTabIndex];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroBackground(selectedTab, isDark),
                    _buildTabs(isDark),
                    SizedBox(height: 16.h),
                    ...selectedTab.children.map(
                      (section) => CategoryContentSection(
                        key: ValueKey(section.id),
                        section: section,
                        treeType: KavooshTreeType.video,
                        seeAllTitlePrefix: 'ویدئو های آموزشی',
                      ),
                    ),
                    if (selectedTab.children.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Text(
                          'زیردسته‌ای یافت نشد',
                          style: MyTextStyle.textMatn14Bold.copyWith(
                            color: isDark
                                ? MyColors.darkTextSecondary
                                : Colors.grey,
                          ),
                        ),
                      ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBackground(CategoryNodeSummary tab, bool isDark) {
    final fallbackColor =
        isDark ? MyColors.darkBackgroundSecondary : const Color(0xFFF9F6C6);
    final backgroundId = tab.backgroundImageId;

    return SizedBox(
      height: 200.h,
      width: double.infinity,
      child: backgroundId == null || backgroundId.isEmpty
          ? ColoredBox(color: fallbackColor)
          : FutureBuilder<String>(
              future: GetImageUrlService().getImageUrl(backgroundId),
              builder: (context, snapshot) {
                final url = snapshot.data;
                if (url == null || url.isEmpty) {
                  return ColoredBox(color: fallbackColor);
                }
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200.h,
                  errorBuilder: (_, __, ___) =>
                      ColoredBox(color: fallbackColor),
                );
              },
            ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _rootTabs.length; i++) ...[
                if (i > 0) SizedBox(width: 24.w),
                _buildTabItem(i, _rootTabs[i], isDark),
              ],
            ],
          ),
        ),
        Container(
          height: 2.h,
          width: double.infinity,
          color: (isDark ? MyColors.darkBorder : Colors.grey)
              .withValues(alpha: 0.35),
          child: Row(
            children: List.generate(_rootTabs.length, (index) {
              return Expanded(
                child: Container(
                  color: _selectedTabIndex == index
                      ? MyColors.primary
                      : Colors.transparent,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, CategoryNodeSummary tab, bool isDark) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTabIndex = index);
      },
      child: Row(
        children: [
          Text(
            tab.title,
            style: MyTextStyle.textMatn14Bold.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? MyColors.primary
                  : (isDark ? MyColors.darkTextSecondary : Colors.grey),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            _tabIconFor(tab),
            color: isSelected
                ? MyColors.primary
                : (isDark ? MyColors.darkTextSecondary : Colors.grey),
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
