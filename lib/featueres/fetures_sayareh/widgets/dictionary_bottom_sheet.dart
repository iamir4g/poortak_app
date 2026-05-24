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
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/dictionary_model.dart';

class DictionaryBottomSheet extends StatelessWidget {
  const DictionaryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => locator<DictionaryBloc>(),
        ),
        BlocProvider.value(
          value: locator<LitnerBloc>(),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? MyColors.termsBackgroundDark : MyColors.background;
    final fieldColor = isDark ? MyColors.profileHeaderDark : MyColors.background3;
    final textColor = isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1;
    final hintColor = isDark ? MyColors.loginTextSecondaryDark : MyColors.textSecondary;
    final borderColor = isDark ? MyColors.loginIconContainerDark : MyColors.divider;
    return BlocListener<LitnerBloc, LitnerState>(
      listener: (context, state) {
        if (state is CreateWordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لغت به لایتنر اضافه شد',
                style: MyTextStyle.textMatn12Bold.copyWith(
                  color: MyColors.textLight,
                ),
              ),
              backgroundColor: MyColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is LitnerError) {
          final isWordExistsError = state.message == "این کلمه قبلا اضافه شده";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: MyTextStyle.textMatn12Bold.copyWith(
                  color: MyColors.textLight,
                ),
              ),
              backgroundColor:
                  isWordExistsError ? MyColors.warning : MyColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: surfaceColor,
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
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'دیکشنری',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: _onSearchChanged,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        fontWeight: FontWeight.normal,
                        color: textColor,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                      cursorColor: MyColors.primary,
                      decoration: InputDecoration(
                        hintText: 'جستجوی معنی کلمه',
                        hintStyle: MyTextStyle.textMatn14Bold.copyWith(
                          color: hintColor,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        prefixIcon: Icon(Icons.search, color: hintColor),
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
                              ? _buildDetailView(entry.word,
                                  _selectedTranslation, entry.examples)
                              : ListView(
                                  key: const ValueKey('list_view'),
                                  padding: const EdgeInsets.all(20),
                                  children: [
                                    _buildGroupedItem(context, entry),
                                    if (entry.relatedWords.isNotEmpty) ...[
                                      const SizedBox(height: 24),
                                      const Divider(),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('کلمات مرتبط',
                                              style:
                                                  MyTextStyle.textHeader16Bold),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        alignment: WrapAlignment.end,
                                        children: entry.relatedWords
                                            .map((w) => ActionChip(
                                                label: Text(
                                                  w,
                                                  style: MyTextStyle
                                                      .textMatn12W300,
                                                ),
                                                onPressed: () {
                                                  _controller.text = w;
                                                  _onSearchChanged(w);
                                                }))
                                            .toList(),
                                      )
                                    ]
                                  ],
                                ),
                        );
                      } else if (state is DictionaryEmpty) {
                        return Center(
                          child: Text(
                            'موردی یافت نشد',
                            style: MyTextStyle.textMatn14Bold.copyWith(
                              color: hintColor,
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
          )),
    );
  }

  Widget _buildGroupedItem(BuildContext context, DictionaryEntry entry) {
    final translations = entry.persianTranslations.join('، ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _showDetail = true;
            _selectedTranslation = translations;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.word,
                    style: MyTextStyle.textMatn16Bold,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      locator<TTSService>().speak(entry.word);
                    },
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: MyColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  BlocBuilder<LitnerBloc, LitnerState>(
                    builder: (context, litnerState) {
                      return IconButton(
                        onPressed: litnerState is LitnerLoading
                            ? null
                            : () => context.read<LitnerBloc>().add(
                                  CreateWordEvent(
                                    word: entry.word,
                                    translation: translations,
                                  ),
                                ),
                        icon: Image.asset(
                          'assets/images/icons/litner_icon.png',
                          width: 22,
                          height: 22,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  translations,
                  style: MyTextStyle.textMatn16,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
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
                  Text(
                    '• ',
                    style: MyTextStyle.textMatn16.copyWith(
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ),
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
