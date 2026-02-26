import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/config/dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import '../widgets/add_word_bottom_sheet.dart';
import 'package:poortak/featueres/feature_litner/data/models/list_words_model.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'dart:async';

class LitnerWordsInprogressScreen extends StatefulWidget {
  static const String routeName = '/litner-words-inprogress';
  const LitnerWordsInprogressScreen({super.key});

  @override
  State<LitnerWordsInprogressScreen> createState() =>
      _LitnerWordsInprogressScreenState();
}

class _LitnerWordsInprogressScreenState
    extends State<LitnerWordsInprogressScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  int _page = 1;
  final int _size = 10;
  final String _order = 'asc';
  final String _boxLevels = '1,2,3,4';
  List<Datum> _words = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchWord = '';
  bool _isSearching = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWords();
    _scrollController.addListener(_onScroll);
  }

  void _fetchWords() {
    context.read<LitnerBloc>().add(FetchListWordsEvent(
        size: _size,
        page: _page,
        order: _order,
        boxLevels: _boxLevels,
        word: _searchWord,
        query: ""));
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update search query without triggering rebuild
    _searchWord = value;

    // Only start debounce timer if we have at least 3 characters
    if (value.length >= 3) {
      setState(() {
        _isSearching = true;
      });

      // Set a new timer for 800ms delay
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        setState(() {
          _page = 1;
          _isSearching = false;
        });
        _words.clear();
        _hasMore = true;
        _fetchWords();
      });
    } else if (value.isEmpty) {
      // If search is cleared, reset to original state
      setState(() {
        _page = 1;
        _isSearching = false;
      });
      _words.clear();
      _hasMore = true;
      _fetchWords();
    } else {
      // For 1-2 characters, just update the search state
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isSearching) {
      setState(() {
        _isLoadingMore = true;
        _page++;
      });
      _fetchWords();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _showAddWordBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<LitnerBloc>(),
        child: AddWordBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Flexible(
          child: Text(
            'لغات در حال یادگیری',
            style: MyTextStyle.textHeader16Bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.r),
        ),
        backgroundColor: MyColors.brandPrimary,
        onPressed: _showAddWordBottomSheet,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocConsumer<LitnerBloc, LitnerState>(
          listener: (context, state) {
            if (state is ListWordsSuccess) {
              setState(() {
                _isInitialLoading = false;
                _isLoadingMore = false;
                if (_page == 1) {
                  _words = state.listWords.data;
                } else {
                  _words.addAll(state.listWords.data);
                }
                _hasMore = state.listWords.data.length == _size;
              });
            } else if (state is CreateWordSuccess) {
              // Refresh the list when a new word is successfully created
              setState(() {
                _page = 1;
                _words.clear();
                _hasMore = true;
                _isInitialLoading = false;
              });
              _fetchWords();
            } else if (state is LitnerError) {
              setState(() {
                _isInitialLoading = false;
                _isLoadingMore = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Search Box
                Padding(
                  padding: EdgeInsets.all(16.0.r),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F9FE),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.w,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'جستجو در لغات...',
                        hintStyle: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 14.sp,
                          color: Color(0xFF9CA3AF),
                        ),
                        prefixIcon: _isSearching
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0.r),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF9CA3AF)),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.search,
                                color: Color(0xFF9CA3AF),
                                size: 20.r,
                              ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 14.sp,
                        color: Color(0xFF29303D),
                      ),
                    ),
                  ),
                ),

                // List
                Expanded(
                  child: _isInitialLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _words.isEmpty
                          ? SingleChildScrollView(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 32.h, horizontal: 16.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64.r,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      SizedBox(height: Dimens.small.h),
                                      Text(
                                        _searchWord.isNotEmpty
                                            ? 'هیچ لغتی یافت نشد.'
                                            : 'هیچ لغتی موجود نیست.',
                                        style: TextStyle(
                                          fontFamily: 'IRANSans',
                                          fontSize: 14.sp,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount:
                                  _words.length + (_isLoadingMore ? 1 : 0),
                              separatorBuilder: (context, index) => Container(
                                height: 1.5.h,
                                width: double.infinity,
                                color: const Color(0xFFF2F2F2),
                              ),
                              itemBuilder: (context, index) {
                                if (index == _words.length) {
                                  return Center(
                                      child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: CircularProgressIndicator(),
                                  ));
                                }
                                final word = _words[index];
                                return Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(minHeight: 48.h),
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.w),
                                          child: Text(
                                            word.translation,
                                            style: TextStyle(
                                              fontFamily: 'IRANSans',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16.sp,
                                              color: Color(0xFF29303D),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: IconifyIcon(
                                              icon: "cuida:volume-2-outline",
                                              size: 18.r,
                                              color: Color(0xFFA3AFC2),
                                            ),
                                            splashRadius: 18.r,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              locator<TTSService>()
                                                  .speak(word.word);
                                            },
                                          ),
                                          SizedBox(width: 4.w),
                                          ConstrainedBox(
                                            constraints:
                                                BoxConstraints(maxWidth: 120.w),
                                            child: Text(
                                              word.word,
                                              style: TextStyle(
                                                fontFamily: 'IRANSans',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp,
                                                color: Color(0xFF29303D),
                                              ),
                                              textAlign: TextAlign.right,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
