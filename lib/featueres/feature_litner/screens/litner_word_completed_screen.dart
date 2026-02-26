import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/feature_litner/data/models/list_words_model.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
import 'dart:async';

class LitnerWordCompletedScreen extends StatefulWidget {
  static const String routeName = '/litner-word-completed';
  const LitnerWordCompletedScreen({super.key});

  @override
  State<LitnerWordCompletedScreen> createState() =>
      _LitnerWordCompletedScreenState();
}

class _LitnerWordCompletedScreenState extends State<LitnerWordCompletedScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  int _page = 1;
  final int _size = 10;
  final String _order = 'asc';
  final String _boxLevels = '5';
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
          query: "",
        ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9FE),
        elevation: 0,
        title: Flexible(
          child: Text(
            'آموخته شده ها',
            style: MyTextStyle.textHeader16Bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3D495C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            } else if (state is LitnerError) {
              setState(() {
                _isInitialLoading = false;
                _isLoadingMore = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  padding: EdgeInsets.all(Dimens.medium.r),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(Dimens.small.r),
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
                        hintText: 'جستجو در لغات آموخته شده...',
                        hintStyle: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 14.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        prefixIcon: _isSearching
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0.r),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF9CA3AF)),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.search,
                                color: const Color(0xFF9CA3AF),
                                size: 20.r,
                              ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Dimens.medium.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 14.sp,
                        color: const Color(0xFF29303D),
                      ),
                      maxLines: 1,
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
                          ? Center(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(16.r),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/litner/litner_empty_state.png',
                                      width: 200.w,
                                      height: 200.h,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: 32.h),
                                    Text(
                                      _searchWord.isNotEmpty
                                          ? 'هیچ لغتی یافت نشد.'
                                          : 'شما هنوز هیچ کلمه ای را به صورت کامل نیاموخته اید.',
                                      style: TextStyle(
                                        fontFamily: 'IRANSans',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: const Color(0xFF29303D),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_searchWord.isEmpty) ...[
                                      SizedBox(height: 12.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.0.w),
                                        child: Text(
                                          'وقتی معنی کلمه ای را به طور کامل به خاطر بسپارید، کلمه به این قسمت هدایت می شود.',
                                          style: TextStyle(
                                            fontFamily: 'IRANSans',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11.sp,
                                            color: const Color(0xFFA3AFC2),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
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
                                color: const Color(0xFFF2F2F2),
                              ),
                              itemBuilder: (context, index) {
                                if (index == _words.length) {
                                  return Center(
                                      child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: const CircularProgressIndicator(),
                                  ));
                                }
                                final word = _words[index];
                                return Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(minHeight: 56.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      // Left: English word + speaker
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                          child: Text(
                                            word.translation,
                                            style: TextStyle(
                                              fontFamily: 'IRANSans',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16.sp,
                                              color:
                                                  const Color(0xFF29303D),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // Right: Persian word
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: IconifyIcon(
                                                  icon:
                                                      "cuida:volume-2-outline",
                                                  size: 18.r,
                                                  color:
                                                      const Color(0xFFA3AFC2),
                                                ),
                                                splashRadius: 18.r,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  locator<TTSService>()
                                                      .speak(word.word);
                                                },
                                              ),
                                              SizedBox(width: 8.w),
                                              Flexible(
                                                child: Text(
                                                  word.word,
                                                  style: TextStyle(
                                                    fontFamily: 'IRANSans',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14.sp,
                                                    color:
                                                        const Color(0xFF29303D),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
