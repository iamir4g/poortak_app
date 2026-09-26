import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/course_list_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/section_header.dart';
import 'package:poortak/locator.dart';

/// Loads a second-level category via Find Category by ID and shows its
/// sub-categories (or published courses/books when there are no children).
class CategoryContentSection extends StatefulWidget {
  final CategoryNodeSummary section;
  final KavooshTreeType treeType;
  final String seeAllTitlePrefix;

  const CategoryContentSection({
    super.key,
    required this.section,
    required this.treeType,
    required this.seeAllTitlePrefix,
  });

  @override
  State<CategoryContentSection> createState() => _CategoryContentSectionState();
}

class _CategoryContentSectionState extends State<CategoryContentSection> {
  static const _cardColors = [
    Color(0xFFFBEBDF),
    Color(0xFFE8F5E9),
    Color(0xFFFFF8E1),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
  ];

  final KavooshRepository _repository = locator<KavooshRepository>();

  bool _loading = true;
  String? _error;
  List<CategoryNodeSummary> _childCategories = const [];
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CategoryContentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.id != widget.section.id ||
        oldWidget.treeType != widget.treeType) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _childCategories = const [];
      _items = const [];
    });

    final detailResult = await _repository.fetchCategoryNodeDetail(
      categoryId: widget.section.id,
    );

    if (!mounted) return;

    if (detailResult is DataFailed) {
      setState(() {
        _loading = false;
        _error = detailResult.error;
      });
      return;
    }

    final detail = (detailResult as DataSuccess<CategoryNodeSummary>).data;
    final children = detail?.children ?? const <CategoryNodeSummary>[];

    if (children.isNotEmpty) {
      setState(() {
        _childCategories = children;
        _loading = false;
      });
      return;
    }

    final hasContent = widget.treeType == KavooshTreeType.video
        ? widget.section.courseCount > 0
        : widget.section.bookCount > 0;

    if (!hasContent) {
      setState(() => _loading = false);
      return;
    }

    final itemsResult = await _repository.fetchCategoryItems(
      treeType: widget.treeType,
      categoryId: widget.section.id,
      size: 10,
      page: 1,
    );

    if (!mounted) return;

    if (itemsResult is DataFailed) {
      setState(() {
        _loading = false;
        _error = itemsResult.error;
      });
      return;
    }

    final payload =
        (itemsResult as DataSuccess<Map<String, dynamic>>).data ?? const {};
    final data = payload['data'];
    setState(() {
      _items = data is List
          ? data
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
          : const [];
      _loading = false;
    });
  }

  void _openCourseList({String? categoryId, String? title}) {
    Navigator.pushNamed(
      context,
      CourseListScreen.routeName,
      arguments: {
        'title': title ??
            '${widget.seeAllTitlePrefix} ${widget.section.title}'.trim(),
        'categoryId': categoryId ?? widget.section.id,
        'treeType': widget.treeType,
        if (widget.treeType == KavooshTreeType.book) 'type': 'book',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: widget.section.title,
          onSeeAllTap: () => _openCourseList(),
        ),
        if (_loading)
          SizedBox(
            height: 120.h,
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              _error!,
              style: MyTextStyle.textMatn12W500.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          )
        else if (_childCategories.isNotEmpty)
          _buildCardsList(
            itemCount: _childCategories.length,
            builder: (index) {
              final child = _childCategories[index];
              return CourseCard(
                title: child.title,
                thumbnailId: child.thumbnailId,
                backgroundColor: _cardColors[index % _cardColors.length],
                showPlayBadge: widget.treeType == KavooshTreeType.video,
                onTap: () => _openCourseList(
                  categoryId: child.id,
                  title: child.title,
                ),
              );
            },
          )
        else if (_items.isNotEmpty)
          _buildCardsList(
            itemCount: _items.length,
            builder: (index) {
              final item = _items[index];
              return CourseCard(
                title: item['title']?.toString() ?? '',
                thumbnailId: item['thumbnailId']?.toString(),
                backgroundColor: _cardColors[index % _cardColors.length],
                showPlayBadge: widget.treeType == KavooshTreeType.video,
                onTap: () => _openCourseList(
                  categoryId: widget.section.id,
                  title: item['title']?.toString(),
                ),
              );
            },
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'محتوایی یافت نشد',
              style: MyTextStyle.textMatn12W500.copyWith(
                color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildCardsList({
    required int itemCount,
    required Widget Function(int index) builder,
  }) {
    return SizedBox(
      height: 190.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: itemCount,
        itemBuilder: (context, index) => builder(index),
      ),
    );
  }
}
