import 'package:flutter/material.dart';
import 'package:poortak/l10n/app_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/common/widgets/step_progress.dart';
import 'package:iconify_design/iconify_design.dart';
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
  const _LitnerWordBoxView({super.key});

  @override
  State<_LitnerWordBoxView> createState() => _LitnerWordBoxViewState();
}

class _LitnerWordBoxViewState extends State<_LitnerWordBoxView> {
  final FlipCardController _flipController = FlipCardController();
  final TTSService ttsService = locator<TTSService>();
  bool isBack = false; // Track if the card is showing its back

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
        centerTitle: true,
        title: Text(l10n!.litner_review, style: MyTextStyle.textHeader16Bold),
      ),
      body: BlocConsumer<LitnerReviewCubit, LitnerReviewState>(
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
            return Center(child: Text(state.message));
          } else if (state is LitnerReviewCompleted) {
            return const Center(
                child: Text('تبریک! تمام لغات مرور شدند.',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
          } else if (state is LitnerReviewLoaded) {
            // Check if words list is empty
            if (state.words.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'شما ابتدا باید لغاتی را به لاینتر اضافه کنید',
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/litner-words-inprogress');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'اضافه کردن لغت',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final word = state.words[state.currentIndex];
            final totalSteps = state.words.length;
            final currentStep = state.currentIndex;
            return Column(
              children: [
                const SizedBox(height: 16),
                StepProgress(
                  currentIndex: currentStep,
                  totalSteps: totalSteps,
                ),
                const SizedBox(height: 64),
                // Expanded(
                //   child:
                Center(
                  child: FlipCard(
                    controller: _flipController,
                    rotateSide: RotateSide.right,
                    axis: FlipAxis.vertical,
                    frontWidget: _buildFront(context, word.word, _flipToBack),
                    backWidget: _buildBack(
                        context, word.word, word.translation, _flipToFront),
                  ),
                ),
                // ),
                const SizedBox(height: 16),
                if (isBack)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        litnerChoiceButton(
                          circleColor: Color(0xFFEAF9F1), // light green
                          icon: Icons.check, // or use a custom SVG if needed
                          iconColor: Color(0xFF4DC591), // green
                          label: 'می دانستم',
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
                          circleColor: Color(0xFFFDEAEA), // light red
                          icon: Icons.close, // or use a custom SVG if needed
                          iconColor: Color(0xFFF16063), // red
                          label: 'نمی دانستم',
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
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildFront(
      BuildContext context, String englishWord, VoidCallback onFlip) {
    return Container(
      width: 260,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                englishWord,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF3A465A),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => ttsService.speak(englishWord),
                child: IconifyIcon(
                  icon: "cuida:volume-2-outline",
                  size: 28,
                  color: const Color(0xFF3A465A),
                ),
              ),
            ],
          )),
          const Spacer(),
          GestureDetector(
            onTap: onFlip,
            child: const IconifyIcon(
              icon: "solar:smartphone-rotate-angle-outline",
              size: 32,
              color: Color(0xFF3A465A),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context, String englishWord,
      String persianWord, VoidCallback onFlip) {
    return Container(
      width: 260,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  englishWord,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => ttsService.speak(englishWord),
                  child: IconifyIcon(
                    icon: "cuida:volume-2-outline",
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Text(
            persianWord,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFlip,
            child: const IconifyIcon(
              icon: "solar:smartphone-rotate-angle-outline",
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
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
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A465A), // dark color
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
