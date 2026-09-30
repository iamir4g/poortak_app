import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/book_details_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/course_list_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/video_detail_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/section_header.dart';
import 'package:poortak/locator.dart';

/// Loads published courses/books for a second-level category (incl. subtree)
/// and shows a horizontal preview. Subcategories appear as filters on See All.
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
  static const _previewSize = 10;

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
      _items = const [];
    });

    final itemsResult = await _repository.fetchCategoryItems(
      treeType: widget.treeType,
      categoryId: widget.section.id,
      size: _previewSize,
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

  void _openCourseList() {
    Navigator.pushNamed(
      context,
      CourseListScreen.routeName,
      arguments: {
        'title':
            '${widget.seeAllTitlePrefix} ${widget.section.title}'.trim(),
        'categoryId': widget.section.id,
        'treeType': widget.treeType,
        if (widget.treeType == KavooshTreeType.book) 'type': 'book',
      },
    );
  }

  void _openItemDetail(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final title = item['title']?.toString() ?? '';
    if (id.isEmpty) return;

    if (widget.treeType == KavooshTreeType.book) {
      Navigator.pushNamed(
        context,
        BookDetailsScreen.routeName,
        arguments: {'bookId': id, 'title': title},
      );
      return;
    }

    Navigator.pushNamed(
      context,
      VideoDetailScreen.routeName,
      arguments: {'courseId': id, 'title': title},
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
          onSeeAllTap: _openCourseList,
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
        else if (_items.isNotEmpty)
          SizedBox(
            height: 190.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return CourseCard(
                  title: item['title']?.toString() ?? '',
                  thumbnailId: item['thumbnailId']?.toString(),
                  backgroundColor: _cardColors[index % _cardColors.length],
                  showPlayBadge: widget.treeType == KavooshTreeType.video,
                  onTap: () => _openItemDetail(item),
                );
              },
            ),
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
}
