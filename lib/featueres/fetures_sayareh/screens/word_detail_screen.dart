import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/dictionary_bloc/dictionary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/dictionary_bloc/dictionary_event.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/dictionary_bloc/dictionary_state.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';

class WordDetailScreen extends StatelessWidget {
  static const routeName = '/word_detail';
  final String word;
  final String translation;

  const WordDetailScreen(
      {super.key, required this.word, required this.translation});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<DictionaryBloc>()..add(SearchWord(word)),
      child: _WordDetailView(word: word, translation: translation),
    );
  }
}

class _WordDetailView extends StatelessWidget {
  final String word;
  final String translation;

  const _WordDetailView({required this.word, required this.translation});

  Future<void> _addToLitner(BuildContext context) async {
    final prefsOperator = locator<PrefsOperator>();
    final isLoggedIn = await prefsOperator.getLoggedIn();
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لطفا وارد شوید"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    context.read<LitnerBloc>().add(
          CreateWordEvent(word: word, translation: translation),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocListener<LitnerBloc, LitnerState>(
          listener: (context, state) {
            if (state is CreateWordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لغت به لایتنر اضافه شد'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is LitnerError) {
              final isWordExistsError =
                  state.message == "این کلمه قبلا اضافه شده";
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor:
                      isWordExistsError ? Colors.orange : Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.0.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _addToLitner(context),
                      icon: Image.asset(
                        'assets/images/icons/litner_icon.png',
                        width: 22.r,
                        height: 22.r,
                      ),
                    ),
                    Row(
                      children: [
                        Text(word,
                            style: TextStyle(
                                fontFamily: 'IRANSans',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF29303D))),
                        IconButton(
                          onPressed: () => locator<TTSService>().speak(word),
                          icon: IconifyIcon(
                              icon: "cuida:volume-2-outline",
                              size: 22.r,
                              color: const Color(0xFFA3AFC2)),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Dimens.small.h),
                Text(translation,
                    style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3A465A))),
                SizedBox(height: 16.h),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(12.0.r),
                          child: Text('مثال ها',
                              style: MyTextStyle.textHeader16Bold),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: BlocBuilder<DictionaryBloc, DictionaryState>(
                            builder: (context, state) {
                              if (state is DictionaryLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (state is DictionaryLoaded) {
                                final examples = state.entry.examples;
                                if (examples.isEmpty) {
                                  return const Center(
                                      child: Text('مثالی موجود نیست'));
                                }
                                return ListView.separated(
                                  itemCount: examples.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final ex = examples[index];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0.w, vertical: 10.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('• ',
                                                  style: TextStyle(
                                                      fontSize: 18.sp)),
                                              Expanded(
                                                child: Text(
                                                  ex.text,
                                                  style: TextStyle(
                                                      fontFamily: 'IRANSans',
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xFF29303D)),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    locator<TTSService>()
                                                        .speak(ex.text),
                                                icon: IconifyIcon(
                                                    icon:
                                                        "cuida:volume-2-outline",
                                                    size: 18.r,
                                                    color: const Color(
                                                        0xFFA3AFC2)),
                                              ),
                                            ],
                                          ),
                                          if (ex.persian != null &&
                                              ex.persian!.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 6.0.h, right: 24.0.w),
                                              child: Text(
                                                ex.persian!,
                                                style: TextStyle(
                                                    fontFamily: 'IRANSans',
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color(
                                                        0xFF3A465A)),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else if (state is DictionaryError) {
                                return Center(child: Text(state.message));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
