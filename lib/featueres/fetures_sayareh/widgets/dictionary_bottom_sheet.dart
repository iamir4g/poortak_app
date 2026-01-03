import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/dictionary_bloc/dictionary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/dictionary_bloc/dictionary_event.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/dictionary_bloc/dictionary_state.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/word_detail_screen.dart';
import 'package:poortak/main.dart';

class DictionaryBottomSheet extends StatelessWidget {
  const DictionaryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<DictionaryBloc>(),
      child: const _DictionaryContent(),
    );
  }
}

class _DictionaryContent extends StatefulWidget {
  const _DictionaryContent();

  @override
  State<_DictionaryContent> createState() => _DictionaryContentState();
}

class _DictionaryContentState extends State<_DictionaryContent> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();
  bool _showDetail = false;
  String? _selectedTranslation;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      if (query.trim().isNotEmpty) {
        context.read<DictionaryBloc>().add(SearchWord(query));
      }
    });
  }

  Future<void> _openFullPage(
      BuildContext ctx, String word, String translation) async {
    try {
      print(
          '[DictionaryBottomSheet] Full page navigate word="$word" translation="$translation"');
      Navigator.of(ctx).pop();
      await Future.delayed(const Duration(milliseconds: 50));
      navigatorKey.currentState?.pushNamed(
        WordDetailScreen.routeName,
        arguments: {'word': word, 'translation': translation},
      );
    } catch (e, st) {
      print('[DictionaryBottomSheet] Navigation error: $e');
      print(st);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('خطا در ناوبری')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: MyColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MyColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'دیکشنری',
            style: MyTextStyle.textHeader16Bold.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.background3,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyColors.divider),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                textAlign: TextAlign.right,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: 'جستجوی معنی کلمه',
                  hintStyle: MyTextStyle.textMatn14Bold.copyWith(
                    color: MyColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: MyColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<DictionaryBloc, DictionaryState>(
              builder: (context, state) {
                if (state is DictionaryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DictionaryLoaded) {
                  final entry = state.entry;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: _showDetail
                        ? _buildDetailView(
                            entry.word, _selectedTranslation, entry.examples)
                        : ListView.separated(
                            key: const ValueKey('list_view'),
                            padding: const EdgeInsets.all(20),
                            itemCount: entry.persianTranslations.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final translation =
                                  entry.persianTranslations[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _openFullPage(
                                        context, entry.word, translation);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            _openFullPage(context, entry.word,
                                                translation);
                                          },
                                          child: Text(
                                            translation,
                                            style: MyTextStyle.textMatn16,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                locator<TTSService>()
                                                    .speak(entry.word);
                                              },
                                              icon: const Icon(
                                                Icons.volume_up_rounded,
                                                color: MyColors.textSecondary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                _openFullPage(context,
                                                    entry.word, translation);
                                              },
                                              child: Text(
                                                entry.word,
                                                style:
                                                    MyTextStyle.textMatn16Bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                } else if (state is DictionaryEmpty) {
                  return Center(
                    child: Text(
                      'موردی یافت نشد',
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        color: MyColors.textSecondary,
                      ),
                    ),
                  );
                } else if (state is DictionaryError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        color: MyColors.error,
                      ),
                    ),
                  );
                }
                return Center(
                  child: Lottie.asset(
                    'assets/lottie/Search.json',
                    width: 200,
                    height: 200,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView(String word, String? translation, List examples) {
    return Column(
      key: const ValueKey('detail_view'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showDetail = false;
                    _selectedTranslation = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text('جزئیات', style: MyTextStyle.textHeader16Bold),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  translation ?? '',
                  style: MyTextStyle.textMatn16,
                  textAlign: TextAlign.right,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => locator<TTSService>().speak(word),
                    icon: const Icon(Icons.volume_up_rounded, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Text(word, style: MyTextStyle.textMatn16Bold),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: examples.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final ex = examples[index];
              final text = (ex is String) ? ex : ex.text?.toString() ?? '';
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: MyTextStyle.textMatn16,
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => locator<TTSService>().speak(text),
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
