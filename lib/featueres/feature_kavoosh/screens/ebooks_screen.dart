import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_bloc.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_event.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_state.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/category_content_section.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/kavoosh_category_tabs.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/kavoosh_hero_background.dart';
import 'package:poortak/locator.dart';

class EBooksScreen extends StatefulWidget {
  static const String routeName = '/ebooks';

  const EBooksScreen({super.key});

  @override
  State<EBooksScreen> createState() => _EBooksScreenState();
}

class _EBooksScreenState extends State<EBooksScreen> {
  int _selectedTabIndex = 0;
  List<CategoryNodeSummary> _rootTabs = const [];
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  IconData _tabIconFor(CategoryNodeSummary tab) {
    final title = tab.title;
    if (title.contains('سوال')) return Icons.quiz_outlined;
    return Icons.book_outlined;
  }

  int _defaultTabIndex(List<CategoryNodeSummary> tabs) {
    final preferred = tabs.indexWhere((e) => e.title.contains('کتاب'));
    return preferred >= 0 ? preferred : 0;
  }

  void _onTabSelected(int index) {
    if (index == _selectedTabIndex) return;
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Widget _buildTabContent(CategoryNodeSummary tab, bool isDark) {
    if (tab.children.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Text(
            'زیردسته‌ای یافت نشد',
            style: MyTextStyle.textMatn14Bold.copyWith(
              color: isDark ? MyColors.darkTextSecondary : Colors.grey,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
      child: Column(
        children: tab.children
            .map(
              (section) => CategoryContentSection(
                key: ValueKey(section.id),
                section: section,
                treeType: KavooshTreeType.book,
                seeAllTitlePrefix: 'کتاب های',
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocProvider(
      create: (context) => locator<CategoriesBloc>()
        ..add(
          FetchCategoryNodesSummaryEvent(
            treeType: KavooshTreeType.book,
          ),
        ),
      child: Scaffold(
        backgroundColor: isDark ? MyColors.darkBackground : Colors.white,
        appBar: PoortakAppBar(
          title: 'کتاب الکترونیکی',
          titleStyle: MyTextStyle.textMatn16Bold,
          foregroundColor:
              isDark ? MyColors.darkTextPrimary : const Color(0xFF29303D),
        ),
        body: SafeArea(
          top: false,
          child: BlocConsumer<CategoriesBloc, CategoriesState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                final wasEmpty = _rootTabs.isEmpty;
                final nextTabs = state.categories;
                var nextIndex = _selectedTabIndex;

                if (wasEmpty) {
                  nextIndex = _defaultTabIndex(nextTabs);
                } else if (nextIndex >= nextTabs.length) {
                  nextIndex = 0;
                }

                setState(() {
                  _rootTabs = nextTabs;
                  _selectedTabIndex = nextIndex;
                });

                if (wasEmpty && nextTabs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_pageController.hasClients) return;
                    _pageController.jumpToPage(nextIndex);
                  });
                }
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

              return Column(
                children: [
                  KavooshHeroBackground(
                    backgroundImageId: selectedTab.backgroundImageId,
                  ),
                  KavooshCategoryTabs(
                    tabs: _rootTabs,
                    selectedIndex: _selectedTabIndex,
                    onSelected: _onTabSelected,
                    iconFor: _tabIconFor,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _rootTabs.length,
                      onPageChanged: (index) {
                        setState(() => _selectedTabIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return _buildTabContent(_rootTabs[index], isDark);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
