import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import '../widgets/add_word_bottom_sheet.dart';
import 'package:poortak/featueres/feature_litner/data/models/list_words_model.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';

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
  int _page = 1;
  final int _size = 10;
  final String _order = 'asc';
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
    context
        .read<LitnerBloc>()
        .add(FetchListWordsEvent(size: _size, page: _page, order: _order));
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
        title: Text(
          'لغات در حال یادگیری',
          style: MyTextStyle.textHeader16Bold,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: MyColors.brandPrimary,
        onPressed: _showAddWordBottomSheet,
        child: Icon(Icons.add),
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
            return Center(child: CircularProgressIndicator());
          }
          if (_words.isEmpty) {
            return Center(child: Text('هیچ لغتی یافت نشد.'));
          }
          return ListView.separated(
            controller: _scrollController,
            itemCount: _words.length + (_isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) => Container(
              height: 1.5,
              width: 200,
              color: Color(0xFFF2F2F2),
            ),
            itemBuilder: (context, index) {
              if (index == _words.length) {
                return Center(
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
                              style: TextStyle(
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
                                icon: IconifyIcon(
                                  icon: "cuida:volume-2-outline",
                                  size: 18,
                                  color: Color(0xFFA3AFC2), // or blue if active
                                ),
                                splashRadius: 18,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  locator<TTSService>().speak(word.word);
                                },
                              ),
                              SizedBox(width: 4),
                              Text(
                                word.word,
                                style: TextStyle(
                                  fontFamily: 'IRANSans',
                                  fontWeight: FontWeight.w400, // or w300
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
          );
        },
      ),
    );
  }
}
