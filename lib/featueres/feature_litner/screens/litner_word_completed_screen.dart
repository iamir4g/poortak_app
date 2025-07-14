import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/feature_litner/data/models/list_words_model.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';

class LitnerWordCompletedScreen extends StatefulWidget {
  static const String routeName = '/litner-word-completed';
  const LitnerWordCompletedScreen({super.key});

  @override
  State<LitnerWordCompletedScreen> createState() =>
      _LitnerWordCompletedScreenState();
}

class _LitnerWordCompletedScreenState extends State<LitnerWordCompletedScreen> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  final int _size = 10;
  final String _order = 'asc';
  final String _boxLevels = '5';
  List<Datum> _words = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;

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
          word: "",
          query: "",
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
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
            if (_page == 1) {
              _words = state.listWords.data;
            } else {
              _words.addAll(state.listWords.data);
            }
            _hasMore = state.listWords.data.length == _size;
            _isLoadingMore = false;
          } else if (state is LitnerError) {
            _isLoadingMore = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LitnerLoading && _page == 1) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_words.isEmpty) {
            // Empty state UI
            return Center(
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
                  const Text(
                    'شما هنوز هیچ کلمه ای را به صورت کامل نیاموخته اید.',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF29303D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
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
              ),
            );
          }
          // List of completed words
          return ListView.separated(
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
                  ),
                );
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const IconifyIcon(
                                icon: "cuida:volume-2-outline",
                                size: 18,
                                color: Color(0xFFA3AFC2),
                              ),
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                locator<TTSService>().speak(word.word);
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
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
