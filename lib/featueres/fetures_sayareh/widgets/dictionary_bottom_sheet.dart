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
          // Drag handle
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
          // Search Box
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
          // Results
          Expanded(
            child: BlocBuilder<DictionaryBloc, DictionaryState>(
              builder: (context, state) {
                if (state is DictionaryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DictionaryLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.entry.persianTranslations.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final translation =
                          state.entry.persianTranslations[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            translation,
                            style: MyTextStyle.textMatn16,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  locator<TTSService>().speak(state.entry.word);
                                },
                                child: const Icon(
                                  Icons.volume_up_rounded,
                                  color: MyColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                state.entry.word,
                                style: MyTextStyle.textMatn16Bold,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
}
