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
        title: const Text(
          'آموخته شده ها',
          style: MyTextStyle.textHeader16Bold,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3D495C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<LitnerBloc, LitnerState>(
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
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search Box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'جستجو در لغات آموخته شده...',
                      hintStyle: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      prefixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF9CA3AF)),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.search,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 14,
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/litner/litner_empty_state.png',
                                  width: 246,
                                  height: 246,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  _searchWord.isNotEmpty
                                      ? 'هیچ لغتی یافت نشد.'
                                      : 'شما هنوز هیچ کلمه ای را به صورت کامل نیاموخته اید.',
                                  style: const TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xFF29303D),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_searchWord.isEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Text(
                                      'وقتی معنی کلمه ای را به طور کامل به خاطر بسپارید، کلمه به این قسمت هدایت می شود.',
                                      style: TextStyle(
                                        fontFamily: 'IRANSans',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
                                        color: Color(0xFFA3AFC2),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            itemCount: _words.length + (_isLoadingMore ? 1 : 0),
                            separatorBuilder: (context, index) => Container(
                              height: 1.5,
                              width: 200,
                              color: const Color(0xFFF2F2F2),
                            ),
                            itemBuilder: (context, index) {
                              if (index == _words.length) {
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(),
                                ));
                              }
                              final word = _words[index];
                              return Center(
                                child: Container(
                                  width: 340,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Left: English word + speaker
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Row(
                                          children: [
                                            Text(
                                              word.translation,
                                              style: const TextStyle(
                                                fontFamily: 'IRANSans',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: Color(0xFF29303D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Right: Persian word
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const IconifyIcon(
                                                  icon:
                                                      "cuida:volume-2-outline",
                                                  size: 18,
                                                  color: Color(0xFFA3AFC2),
                                                ),
                                                splashRadius: 18,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  locator<TTSService>()
                                                      .speak(word.word);
                                                },
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                word.word,
                                                style: const TextStyle(
                                                  fontFamily: 'IRANSans',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color: Color(0xFF29303D),
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
