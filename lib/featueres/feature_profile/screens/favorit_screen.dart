import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_bookmarks/data/models/bookmark_models.dart';
import 'package:poortak/featueres/feature_bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/book_details_screen.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/video_detail_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_sayareh/screens/book_detail_screen.dart';
import 'package:poortak/featueres/feature_sayareh/screens/lesson_screen.dart';
import 'package:poortak/locator.dart';

class FavoritScreen extends StatefulWidget {
  static const routeName = "/favorit_screen";
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!locator<PrefsOperator>().isLoggedIn()) {
        _promptLogin();
        return;
      }
      context.read<BookmarkCubit>().loadFavorites(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<BookmarkCubit>().loadFavorites(refresh: false);
    }
  }

  void _promptLogin() {
    ReusableModal.show(
      context: context,
      title: '',
      message: 'لطفا ابتدا وارد حساب کاربری خود شوید',
      type: ModalType.info,
      buttonText: 'ورود به حساب کاربری',
      onButtonPressed: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, LoginScreen.routeName);
      },
    );
  }

  void _openItem(BookmarkItem item) {
    switch (item.type) {
      case BookmarkType.IKnowBook:
        Navigator.pushNamed(
          context,
          BookDetailScreen.routeName,
          arguments: {'bookId': item.itemId},
        );
        break;
      case BookmarkType.IKnowCourse:
        Navigator.pushNamed(
          context,
          LessonScreen.routeName,
          arguments: {
            'index': 0,
            'title': item.displayTitle,
            'lessonId': item.itemId,
            'purchased': false,
          },
        );
        break;
      case BookmarkType.Book:
        Navigator.pushNamed(
          context,
          BookDetailsScreen.routeName,
          arguments: {
            'bookId': item.itemId,
            'title': item.displayTitle,
          },
        );
        break;
      case BookmarkType.VideoCourse:
        Navigator.pushNamed(
          context,
          VideoDetailScreen.routeName,
          arguments: {
            'courseId': item.itemId,
            'title': item.displayTitle,
          },
        );
        break;
    }
  }

  Future<void> _removeItem(BookmarkItem item) async {
    final cubit = context.read<BookmarkCubit>();
    final ok = await cubit.removeFavorite(item);
    if (!mounted) return;
    if (!ok) {
      final code = cubit.state.actionErrorCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code == 'unauthorized'
                ? 'لطفا ابتدا وارد حساب کاربری خود شوید'
                : 'خطا در حذف از علاقه‌مندی‌ها',
          ),
        ),
      );
      cubit.clearActionError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? MyColors.darkBackground : MyColors.background3,
      appBar: PoortakAppBar(
        title: 'علاقه مندی ها',
        foregroundColor: isDarkMode ? Colors.white : MyColors.textMatn1,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<BookmarkCubit, BookmarkState>(
          builder: (context, state) {
            if (state.isLoadingList && state.favorites.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.listError != null && state.favorites.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'خطا در دریافت علاقه‌مندی‌ها',
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          color: isDarkMode ? Colors.white : MyColors.textMatn1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () {
                          if (!locator<PrefsOperator>().isLoggedIn()) {
                            _promptLogin();
                            return;
                          }
                          context
                              .read<BookmarkCubit>()
                              .loadFavorites(refresh: true);
                        },
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.favorites.isEmpty) {
              return _buildEmptyState(isDarkMode);
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<BookmarkCubit>().loadFavorites(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(17.r),
                itemCount:
                    state.favorites.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.favorites.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildFavoriteItem(
                    isDarkMode,
                    state.favorites[index],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: 0.025,
            child: SizedBox(
              width: 110.7.w,
              height: 200.8.h,
              child: Image.asset(
                'assets/images/favorit/Delivery_Final.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 8.h),
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

  Widget _buildFavoriteItem(bool isDarkMode, BookmarkItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Stack(
        children: [
          InkWell(
            onTap: () => _openItem(item),
            borderRadius: BorderRadius.circular(15.r),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? MyColors.darkBackgroundSecondary
                    : Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 0),
                    blurRadius: 4.r,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.displayTitle,
                            style: MyTextStyle.textMatn13.copyWith(
                              color: isDarkMode
                                  ? Colors.white
                                  : MyColors.textMatn1,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              color: MyColors.primary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Icon(
                              item.type == BookmarkType.Book ||
                                      item.type == BookmarkType.IKnowBook
                                  ? Icons.menu_book
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 24.r,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      child: _FavoriteThumbnail(
                        thumbnailId: item.displayThumbnailId,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () => _removeItem(item),
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

class _FavoriteThumbnail extends StatelessWidget {
  final String? thumbnailId;

  const _FavoriteThumbnail({this.thumbnailId});

  @override
  Widget build(BuildContext context) {
    if (thumbnailId == null || thumbnailId!.isEmpty) {
      return Image.asset(
        'assets/images/favorit/Delivery_Final.png',
        fit: BoxFit.cover,
      );
    }

    return FutureBuilder<String>(
      future: GetImageUrlService().getImageUrl(thumbnailId!),
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null || url.isEmpty) {
          return Image.asset(
            'assets/images/favorit/Delivery_Final.png',
            fit: BoxFit.cover,
          );
        }
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/favorit/Delivery_Final.png',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
