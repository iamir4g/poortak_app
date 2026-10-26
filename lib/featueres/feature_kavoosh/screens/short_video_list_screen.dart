import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/date_util.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/short_video_model.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/short_video_player_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/detailed_course_card.dart';
import 'package:poortak/locator.dart';

class ShortVideoListScreen extends StatefulWidget {
  static const String routeName = '/short-video-list';

  final String title;
  final String? categoryId;

  const ShortVideoListScreen({
    super.key,
    required this.title,
    this.categoryId,
  });

  @override
  State<ShortVideoListScreen> createState() => _ShortVideoListScreenState();
}

class _ShortVideoListScreenState extends State<ShortVideoListScreen> {
  static const _pageSize = 20;

  final KavooshRepository _repository = locator<KavooshRepository>();
  final ScrollController _scrollController = ScrollController();

  int _selectedFilterIndex = 0;
  List<CategoryNodeSummary> _filterCategories = const [];
  List<ShortVideoSummary> _items = const [];
  bool _isItemsLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _itemsError;
  String? _activeCategoryId;

  @override
  void initState() {
    super.initState();
    _activeCategoryId = _normalizedCategoryId(widget.categoryId);
    _scrollController.addListener(_onScroll);
    _fetchNodeChildren();
    _fetchItems(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String? _normalizedCategoryId(String? value) {
    if (value == null ||
        value.isEmpty ||
        value == CategoryNodeSummary.injectedShortsTabId) {
      return null;
    }
    return value;
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isItemsLoading || _isLoadingMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _fetchItems(refresh: false);
    }
  }

  Future<void> _fetchNodeChildren() async {
    final categoryId = _normalizedCategoryId(widget.categoryId);
    if (categoryId == null) return;

    final result = await _repository.fetchCategoryNodeDetail(
      categoryId: categoryId,
    );
    if (!mounted || result is! DataSuccess<CategoryNodeSummary>) return;

    setState(() {
      _filterCategories = result.data?.children ?? const [];
    });
  }

  Future<void> _fetchItems({required bool refresh}) async {
    if (refresh) {
      setState(() {
        _isItemsLoading = true;
        _itemsError = null;
        _hasMore = true;
        _currentPage = 0;
      });
    } else {
      if (!_hasMore || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    }

    final nextPage = refresh ? 1 : _currentPage + 1;
    final result = await _repository.fetchShortVideos(
      categoryId: _activeCategoryId,
      page: nextPage,
      size: _pageSize,
    );

    if (!mounted) return;

    if (result is DataFailed) {
      setState(() {
        _isItemsLoading = false;
        _isLoadingMore = false;
        _itemsError = result.error;
        if (refresh) _items = const [];
      });
      return;
    }

    final page = (result as DataSuccess<ShortVideoPage>).data;
    final incoming = page?.items ?? const <ShortVideoSummary>[];
    final merged = refresh ? incoming : [..._items, ...incoming];

    setState(() {
      _items = merged;
      _currentPage = nextPage;
      _hasMore = merged.length < (page?.totalCount ?? 0);
      _isItemsLoading = false;
      _isLoadingMore = false;
      _itemsError = null;
    });
  }

  void _onFilterSelected(int index) {
    if (index == _selectedFilterIndex) return;
    setState(() {
      _selectedFilterIndex = index;
      _activeCategoryId = index == 0
          ? _normalizedCategoryId(widget.categoryId)
          : _filterCategories.elementAt(index - 1).id;
    });
    _fetchItems(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = [
      'همه',
      ..._filterCategories.map((e) => e.title),
    ];

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkBackground : MyColors.background1,
      appBar: PoortakAppBar(
        title: widget.title,
        foregroundColor: isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
      ),
      body: Column(
        children: [
          if (_filterCategories.isNotEmpty)
            Container(
              height: 60.h,
              margin: EdgeInsets.symmetric(vertical: 8.h),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Center(
                    child: GestureDetector(
                      onTap: () => _onFilterSelected(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? MyColors.secondary : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white,
                          ),
                        ),
                        child: Text(
                          filters[index],
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

                final colors = [
                  const Color(0xFFFBEBDF),
                  const Color(0xFFE3F2FD),
                  const Color(0xFFF3E5F5),
                  const Color(0xFFE8F5E9),
                ];

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
                  itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _items.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    final item = _items[index];
                    final date = item.publishedAt == null
                        ? ''
                        : DateUtil.toRelativeTime(item.publishedAt!);

                    return DetailedCourseCard(
                      title: item.title,
                      author: item.instructor?.name ?? '',
                      date: date,
                      isPurchased: false,
                      thumbnailId: item.thumbnailId,
                      backgroundColor: colors[index % colors.length],
                      onTap: () => ShortVideoPlayerScreen.open(
                        context,
                        videoId: item.id,
                        title: item.title,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
