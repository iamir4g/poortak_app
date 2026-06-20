import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/utils/date_util.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_bloc.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_event.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_state.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/detailed_course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/book_details_screen.dart';
import 'package:poortak/locator.dart';

class CourseListScreen extends StatefulWidget {
  static const String routeName = '/course-list';
  final String title;
  final String? type;
  final String categoryId;
  final KavooshTreeType? treeType;

  const CourseListScreen({
    super.key,
    required this.title,
    this.type,
    required this.categoryId,
    this.treeType,
  });

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late final CategoriesBloc _bloc;
  int _selectedFilterIndex = 0;
  late List<String> _filters;
  List<CategoryNodeSummary> _filterCategories = const [];
  List<Map<String, dynamic>> _items = const [];
  bool _isItemsLoading = false;
  String? _itemsError;

  @override
  void initState() {
    super.initState();
    _bloc = locator<CategoriesBloc>();
    _filters = const ['همه'];
    _fetchNodeChildren();
    _fetchItemsForCategory(widget.categoryId);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  KavooshTreeType get _effectiveTreeType {
    if (widget.treeType != null) return widget.treeType!;
    if (widget.type == 'book') return KavooshTreeType.book;
    return KavooshTreeType.video;
  }

  void _fetchNodeChildren() {
    if (widget.categoryId.isEmpty) return;
    _bloc.add(
      FetchCategoryNodeContentEvent(
        categoryId: widget.categoryId,
      ),
    );
  }

  void _fetchItemsForCategory(String categoryId) {
    if (categoryId.isEmpty) return;
    setState(() {
      _isItemsLoading = true;
      _itemsError = null;
    });
    _bloc.add(
      FetchCategoryItemsEvent(
        treeType: _effectiveTreeType,
        categoryId: categoryId,
        size: 10,
        page: 1,
        order: 'asc',
        query: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<CategoriesBloc, CategoriesState>(
        listener: (context, state) {
          if (state is CategoryNodeContentLoaded) {
            setState(() {
              _filterCategories = state.category.children;
              _filters = [
                'همه',
                ..._filterCategories.map((e) => e.title),
              ];
              _selectedFilterIndex = 0;
            });
          }
          if (state is CategoryItemsLoaded) {
            setState(() {
              _items = state.items;
              _isItemsLoading = false;
              _itemsError = null;
            });
          }
          if (state is CategoriesError) {
            setState(() {
              _isItemsLoading = false;
              _itemsError = state.message;
            });
          }
        },
        child: Scaffold(
          backgroundColor:
              isDark ? MyColors.darkBackground : MyColors.background1,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(57.h),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 0),
                height: 57.h,
                decoration: BoxDecoration(
                  color:
                      isDark ? MyColors.darkBackgroundSecondary : Colors.white,
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
                        widget.title,
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: isDark
                              ? MyColors.darkTextPrimary
                              : MyColors.textMatn2,
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
                              : MyColors.textMatn2,
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
              BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoading && _filters.length == 1) {
                    return SizedBox(
                      height: 60.h,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (state is CategoriesError && _filters.length == 1) {
                    return SizedBox(
                      height: 60.h,
                      child: Center(
                        child: Text(
                          state.message,
                          style: MyTextStyle.textMatn12W500.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Container(
                    height: 60.h,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = index;
                              });
                              if (index == 0) {
                                _fetchItemsForCategory(widget.categoryId);
                                return;
                              }
                              final selectedCategory =
                                  _filterCategories.elementAt(index - 1);
                              _fetchItemsForCategory(selectedCategory.id);
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
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white,
                                ),
                              ),
                              child: Text(
                                _filters[index],
                                style: MyTextStyle.textMatn12W500.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : MyColors.text4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // List of Cards
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_isItemsLoading && _items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if ((_itemsError != null && _itemsError!.isNotEmpty) &&
                        _items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            _itemsError!,
                            style: MyTextStyle.textMatn14Bold.copyWith(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (_items.isEmpty) {
                      return Center(
                        child: Text(
                          'محتوایی یافت نشد',
                          style: MyTextStyle.textMatn14Bold.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final title = item['title']?.toString() ?? '';
                        final publishedAtRaw =
                            item['publishedAt']?.toString() ?? '';
                        final publishedAt = DateTime.tryParse(publishedAtRaw);
                        final date = publishedAt == null
                            ? ''
                            : DateUtil.toRelativeTime(publishedAt);
                        final colors = [
                          const Color(0xFFFBEBDF),
                          const Color(0xFFE3F2FD),
                          const Color(0xFFF3E5F5),
                          const Color(0xFFE8F5E9),
                        ];

                        return DetailedCourseCard(
                          title: title,
                          author: '',
                          date: date,
                          isPurchased: false,
                          backgroundColor: colors[index % colors.length],
                          onTap: _effectiveTreeType == KavooshTreeType.book
                              ? () {
                                  Navigator.pushNamed(
                                    context,
                                    BookDetailsScreen.routeName,
                                    arguments: {'title': title},
                                  );
                                }
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
