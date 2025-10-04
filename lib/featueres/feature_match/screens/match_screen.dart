import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/featueres/feature_match/presentation/bloc/match_bloc/match_bloc.dart';
import 'package:poortak/featueres/feature_match/data/models/match_model.dart';
import 'dart:async';

class MatchScreen extends StatefulWidget {
  static const routeName = '/match_screen';
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final TextEditingController _answerController = TextEditingController();
  Timer? _countdownTimer;

  // Countdown values
  int daysRemaining = 0;
  int hoursRemaining = 0;
  Match? currentMatch;

  @override
  void initState() {
    super.initState();
    // Fetch match data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MatchBloc>().add(GetMatchEvent());
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF5F0), // #fff5f0
              Color(0xFFFBFDF2), // #fbfdf2
            ],
          ),
        ),
        child: SafeArea(
          child: BlocListener<MatchBloc, MatchState>(
            listener: (context, state) {
              if (state is MatchSuccess) {
                setState(() {
                  currentMatch = state.match;
                  // If user has already submitted an answer, populate the input field
                  if (state.match.data.answer != null) {
                    _answerController.text = state.match.data.answer!.answer;
                  }
                });
                _startCountdown(state.match.data.match.endsAt);
              } else if (state is MatchAnswerSubmitted) {
                _showSuccessModal(state.response.data.isCorrect);
              } else if (state is MatchError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: MyColors.error,
                  ),
                );
              }
            },
            child: BlocBuilder<MatchBloc, MatchState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Header
                    _buildHeader(),

                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 75),

                            // Question section
                            _buildQuestionSection(state),

                            const SizedBox(height: 20),

                            // Description text
                            _buildDescriptionText(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),

                    // Bottom countdown section
                    _buildCountdownSection(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
      height: 57,
      // margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(33.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        // padding: const EdgeInsets.symmetric(horizontal: 16),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title

          Text(
            'شرکت در مسابقه',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IranSans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MyColors.textMatn2,
            ),
          ),

          // Back button
          Container(
            width: 40,
            height: 40,
            // margin: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_forward,
                color: MyColors.textMatn1,
                size: 28,
              ),
            ),
          ),
          // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildQuestionSection(MatchState state) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main content area
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Question text
              if (state is MatchLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (state is MatchSuccess)
                Center(
                    child: Text(
                  state.match.data.match.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'IranSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: MyColors.textMatn1,
                  ),
                ))
              else if (state is MatchError)
                Text(
                  'خطا در بارگذاری سوال',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'IranSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: MyColors.error,
                  ),
                )
              else
                const Text(
                  'در حال بارگذاری...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IranSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: MyColors.textMatn1,
                  ),
                ),

              const SizedBox(height: 20),

              // Answer input field
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _isAnswerSubmitted()
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _answerController,
                  enabled: !_isAnswerSubmitted(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'IranSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: _isAnswerSubmitted()
                        ? MyColors.text4.withOpacity(0.5)
                        : MyColors.text4,
                  ),
                  decoration: InputDecoration(
                    hintText: _isAnswerSubmitted()
                        ? 'شما قبلاً پاسخ داده‌اید'
                        : 'جواب سوال:',
                    hintStyle: TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: _isAnswerSubmitted()
                          ? MyColors.text4.withOpacity(0.5)
                          : MyColors.text4,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Submit button
              Center(
                child: Container(
                  width: 164,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isAnswerSubmitted()
                        ? const Color(0xFFBDBDBD)
                        : MyColors.textMatn2,
                    borderRadius: BorderRadius.circular(56.5),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(56.5),
                      onTap: _isAnswerSubmitted()
                          ? null
                          : () {
                              // Handle submit answer
                              _submitAnswer();
                            },
                      child: BlocBuilder<MatchBloc, MatchState>(
                        builder: (context, state) {
                          if (state is MatchSubmittingAnswer) {
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            );
                          }
                          return Center(
                            child: Text(
                              _isAnswerSubmitted()
                                  ? 'پاسخ ارسال شده'
                                  : 'ارسال پاسخ',
                              style: TextStyle(
                                fontFamily: 'IranSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _isAnswerSubmitted()
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Avatar positioned on the left side above the main container
        Positioned(
          top: -40,
          left: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: const DecorationImage(
                image: AssetImage('assets/images/match/match_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // "سوال این ماه" label centered above the main container
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 112,
              height: 33,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'سوال این ماه',
                  style: TextStyle(
                    fontFamily: 'IranSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: MyColors.textMatn1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'پس از ارسال پاسخ مسابقه، به نفراتی که پاسخ صحیح داده باشند به قید قرعه جوایز ویژه داده خواهد شد.',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'IranSans',
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: MyColors.text3,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'قرعه کشی در اوایل هر ماه انجام می شود و لیست برندگان در بخش (برندگان مسابقه) نمایش داده خواهد شد.',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'IranSans',
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: MyColors.text3,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F5FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Description text
          const Text(
            'زمان باقی مانده ارسال پاسخ برای سوال این ماه :',
            style: TextStyle(
              fontFamily: 'IranSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: MyColors.textMatn2,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Countdown boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Days box
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5FA),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: MyColors.text4.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$hoursRemaining',
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: MyColors.textMatn2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Colon
                  const Text(
                    ':',
                    style: TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MyColors.text4,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Hours box
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5FA),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: MyColors.text4.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$daysRemaining',
                          style: const TextStyle(
                            fontFamily: 'IranSans',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: MyColors.textMatn2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ساعت',
                    style: TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MyColors.text4,
                    ),
                  ),
                  const SizedBox(width: 54),
                  const Text(
                    'روز',
                    style: TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MyColors.text4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
            ],
          ),
        ],
      ),
    );
  }

  void _startCountdown(DateTime endTime) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = endTime.difference(now);

      if (difference.isNegative) {
        // Time has expired
        setState(() {
          daysRemaining = 0;
          hoursRemaining = 0;
        });
        timer.cancel();
        return;
      }

      setState(() {
        daysRemaining = difference.inDays;
        hoursRemaining = difference.inHours % 24;
      });
    });
  }

  void _submitAnswer() {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً پاسخ خود را وارد کنید'),
          backgroundColor: MyColors.error,
        ),
      );
      return;
    }

    if (currentMatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اطلاعات مسابقه در دسترس نیست'),
          backgroundColor: MyColors.error,
        ),
      );
      return;
    }

    // Submit answer using bloc
    context.read<MatchBloc>().add(SubmitAnswerEvent(
          matchId: currentMatch!.data.match.id,
          answer: _answerController.text.trim(),
        ));
  }

  void _showSuccessModal(bool isCorrect) {
    ReusableModal.showSuccess(
      context: context,
      title: 'پاسخ شما با موفقیت ارسال شد.',
      message: '',
      buttonText: 'مشاهده جوایز مسابقه',
      secondButtonText: 'بستن',
      showSecondButton: true,
      onButtonPressed: () {
        Navigator.of(context).pop(); // Close modal
        // Navigate to prizes screen
        // Navigator.pushNamed(context, '/prize_screen');
      },
      onSecondButtonPressed: () {
        Navigator.of(context).pop(); // Close modal
      },
    );
  }

  bool _isAnswerSubmitted() {
    return currentMatch?.data.answer != null;
  }
}
