import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/l10n/app_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/widgets/step_progress.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_review_cubit.dart';
import 'package:poortak/featueres/feature_litner/repositories/litner_repository.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';

class LitnerWordBoxScreen extends StatelessWidget {
  static const routeName = '/litner_word_box';
  const LitnerWordBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LitnerReviewCubit(locator<LitnerRepository>())..fetchWords(),
      child: const _LitnerWordBoxView(),
    );
  }
}

class _LitnerWordBoxView extends StatefulWidget {
  const _LitnerWordBoxView();

  @override
  State<_LitnerWordBoxView> createState() => _LitnerWordBoxViewState();
}

class _LitnerWordBoxViewState extends State<_LitnerWordBoxView> {
  final FlipCardController _flipController = FlipCardController();
  final TTSService ttsService = locator<TTSService>();
  bool isBack = false; // Track if the card is showing its back

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await ttsService.setMaleVoice();
  }

  void _flipToBack() {
    _flipController.flipcard();
    setState(() {
      isBack = true;
    });
  }

  void _flipToFront() {
    _flipController.flipcard();
    setState(() {
      isBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? MyColors.profileBackgroundDark : MyColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark
            ? MyColors.profileHeaderDark
            : Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_forward,
              color: isDark ? MyColors.darkTextPrimary : null,
            ),
          ),
        ],
        centerTitle: true,
        title: Flexible(
          child: Text(
            l10n!.litner_review,
            style: MyTextStyle.textHeader16Bold.copyWith(
              color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<LitnerReviewCubit, LitnerReviewState>(
          listener: (context, state) {
            print('State changed to: $state');
            if (state is LitnerReviewCompleted) {
              print('Showing completion modal');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ReusableModal.show(
                  context: context,
                  title: 'تبریک!',
                  message: 'تمام لغات امروز مرور شدند.',
                  type: ModalType.success,
                  buttonText: 'متوجه شدم',
                  onButtonPressed: () {
                    Navigator.of(context).pop(); // Close modal
                    Navigator.of(context).pop(); // Go back to Litner home
                  },
                );
              });
            }
          },
          builder: (context, state) {
            if (state is LitnerReviewLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LitnerReviewError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Text(
                    state.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (state is LitnerReviewCompleted) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Text(
                    'تبریک! تمام لغات مرور شدند.',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (state is LitnerReviewLoaded) {
              // Check if words list is empty
              if (state.words.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(Dimens.large.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 80.r,
                          color: isDark
                              ? MyColors.darkTextSecondary
                              : Colors.grey[400],
                        ),
                        SizedBox(height: Dimens.medium.h),
                        Text(
                          'شما ابتدا باید لغاتی را به لاینتر اضافه کنید',
                          style: MyTextStyle.textHeader16Bold.copyWith(
                            color: isDark
                                ? MyColors.darkTextPrimary
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Dimens.large.h),
                        PrimaryButton(
                          width: double.infinity,
                          height: Dimens.buttonHeight,
                          lable: 'اضافه کردن لغت',
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/litner-words-inprogress');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              final word = state.words[state.currentIndex];
              final totalSteps = state.words.length;
              final currentStep = state.currentIndex;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: Dimens.medium.h),
                    StepProgress(
                      currentIndex: currentStep,
                      totalSteps: totalSteps,
                    ),
                    SizedBox(height: 64.h),
                    Center(
                      child: FlipCard(
                        controller: _flipController,
                        rotateSide: RotateSide.right,
                        axis: FlipAxis.vertical,
                        frontWidget:
                            _buildFront(context, word.word, _flipToBack),
                        backWidget: _buildBack(
                            context, word.word, word.translation, _flipToFront),
                      ),
                    ),
                    SizedBox(height: Dimens.medium.h),
                    if (isBack)
                      Padding(
                        padding: EdgeInsets.all(Dimens.medium.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            litnerChoiceButton(
                              circleColor:
                                  const Color(0xFFEAF9F1), // light green
                              icon:
                                  Icons.check, // or use a custom SVG if needed
                              iconColor: const Color(0xFF4DC591), // green
                              label: 'می دانستم',
                              textColor: isDark
                                  ? MyColors.darkTextPrimary
                                  : const Color(0xFF3A465A),
                              onTap: () {
                                setState(() {
                                  isBack = false;
                                  if (_flipController.state?.isFront == false) {
                                    _flipController.flipcard();
                                  }
                                });
                                context
                                    .read<LitnerReviewCubit>()
                                    .submitReviewAndNext(word.id, true);
                              },
                            ),
                            litnerChoiceButton(
                              circleColor: const Color(0xFFFDEAEA), // light red
                              icon:
                                  Icons.close, // or use a custom SVG if needed
                              iconColor: const Color(0xFFF16063), // red
                              label: 'نمی دانستم',
                              textColor: isDark
                                  ? MyColors.darkTextPrimary
                                  : const Color(0xFF3A465A),
                              onTap: () {
                                setState(() {
                                  isBack = false;
                                  if (_flipController.state?.isFront == false) {
                                    _flipController.flipcard();
                                  }
                                });
                                context
                                    .read<LitnerReviewCubit>()
                                    .submitReviewAndNext(word.id, false);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildFront(
      BuildContext context, String englishWord, VoidCallback onFlip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 260.w,
      height: 320.h,
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    englishWord,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.sp,
                      color: isDark
                          ? MyColors.darkTextPrimary
                          : const Color(0xFF3A465A),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: Dimens.small.w),
                GestureDetector(
                  onTap: () => ttsService.speak(englishWord, voice: 'male'),
                  child: SvgPicture.asset(
                    'assets/images/icons/cuida--volume-2-outline.svg',
                    width: 28.r,
                    height: 28.r,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? MyColors.darkTextPrimary
                          : const Color(0xFF3A465A),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            )),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFlip,
            child: SvgPicture.asset(
              'assets/images/icons/solar--smartphone-rotate-angle-outline.svg',
              width: 32.r,
              height: 32.r,
              colorFilter: ColorFilter.mode(
                isDark ? MyColors.darkTextSecondary : const Color(0xFF3A465A),
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: Dimens.medium.h),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context, String englishWord,
      String persianWord, VoidCallback onFlip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 260.w,
      height: 320.h,
      decoration: BoxDecoration(
        color: isDark ? MyColors.primary : const Color(0xFF4285F4),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      englishWord,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.sp,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: Dimens.small.w),
                  GestureDetector(
                    onTap: () => ttsService.speak(englishWord, voice: 'male'),
                    child: SvgPicture.asset(
                      'assets/images/icons/cuida--volume-2-outline.svg',
                      width: 28.r,
                      height: 28.r,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              persianWord,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.sp,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFlip,
            child: SvgPicture.asset(
              'assets/images/icons/solar--smartphone-rotate-angle-outline.svg',
              width: 32.r,
              height: 32.r,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: Dimens.medium.h),
        ],
      ),
    );
  }
}

Widget litnerChoiceButton({
  required Color circleColor,
  required IconData icon,
  required Color iconColor,
  required String label,
  required Color textColor,
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 32.r),
        ),
        SizedBox(height: Dimens.small.h),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 16.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
