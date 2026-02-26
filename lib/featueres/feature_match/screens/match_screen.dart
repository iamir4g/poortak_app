import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
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
                    duration: const Duration(seconds: 2),
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
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            SizedBox(height: 75.h),

                            // Question section
                            _buildQuestionSection(state),

                            SizedBox(height: 20.h),

                            // Description text
                            _buildDescriptionText(),

                            SizedBox(height: 40.h),
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
      padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 0),
      height: 57.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(33.5.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 1.h),
            blurRadius: 1.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Flexible(
            child: Text(
              'شرکت در مسابقه',
              textAlign: TextAlign.center,
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: MyColors.textMatn2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Back button
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_forward,
                color: MyColors.textMatn1,
                size: 28.r,
              ),
            ),
          ),
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
          margin: EdgeInsets.only(top: 20.h),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: Offset(0, 2.h),
                blurRadius: 8.r,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Question text
              if (state is MatchLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (currentMatch != null)
                Center(
                    child: Text(
                  currentMatch!.data.match.question,
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    fontWeight: FontWeight.w300,
                    color: MyColors.textMatn1,
                  ),
                ))
              else if (state is MatchError)
                Text(
                  'خطا در بارگذاری سوال',
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    fontWeight: FontWeight.w300,
                    color: MyColors.error,
                  ),
                )
              else
                Text(
                  'در حال بارگذاری...',
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    fontWeight: FontWeight.w300,
                    color: MyColors.textMatn1,
                  ),
                ),

              SizedBox(height: 20.h),

              // Answer input field
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: _isAnswerSubmitted()
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: TextField(
                  controller: _answerController,
                  enabled: !_isAnswerSubmitted(),
                  textAlign: TextAlign.right,
                  style: MyTextStyle.textMatn16.copyWith(
                    color: _isAnswerSubmitted()
                        ? MyColors.text4.withOpacity(0.5)
                        : MyColors.text4,
                  ),
                  decoration: InputDecoration(
                    hintText: _isAnswerSubmitted()
                        ? 'شما قبلاً پاسخ داده‌اید'
                        : 'جواب سوال:',
                    hintStyle: MyTextStyle.textMatn16.copyWith(
                      color: _isAnswerSubmitted()
                          ? MyColors.text4.withOpacity(0.5)
                          : MyColors.text4,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Submit button
              Center(
                child: Container(
                  width: 164.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: _isAnswerSubmitted()
                        ? const Color(0xFFBDBDBD)
                        : MyColors.textMatn2,
                    borderRadius: BorderRadius.circular(56.5.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(56.5.r),
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
                              style: MyTextStyle.textMatn16.copyWith(
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
          top: -40.h,
          left: 0,
          child: Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
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
              width: 112.w,
              height: 33.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2FE),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Center(
                child: Text(
                  'سوال این ماه',
                  style: MyTextStyle.textMatn14Bold.copyWith(
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
        Text(
          'پس از ارسال پاسخ مسابقه، به نفراتی که پاسخ صحیح داده باشند به قید قرعه جوایز ویژه داده خواهد شد.',
          textAlign: TextAlign.right,
          style: MyTextStyle.textMatn11.copyWith(
            color: MyColors.text3,
            height: 1.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'قرعه کشی در اوایل هر ماه انجام می شود و لیست برندگان در بخش (برندگان مسابقه) نمایش داده خواهد شد.',
          textAlign: TextAlign.right,
          style: MyTextStyle.textMatn11.copyWith(
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
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Description text
          Text(
            'زمان باقی مانده ارسال پاسخ برای سوال این ماه :',
            style: MyTextStyle.textMatn10W300.copyWith(
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
                    width: 54.w,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5FA),
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: MyColors.text4.withOpacity(0.3),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$hoursRemaining',
                          style: MyTextStyle.text24Correct.copyWith(
                            color: MyColors.textMatn2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Colon
                  Text(
                    ':',
                    style: MyTextStyle.text24Correct.copyWith(
                      color: MyColors.text4,
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Hours box
                  Container(
                    width: 54.w,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5FA),
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: MyColors.text4.withOpacity(0.3),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$daysRemaining',
                          style: MyTextStyle.text24Correct.copyWith(
                            color: MyColors.textMatn2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ساعت',
                    style: MyTextStyle.textMatn10W300.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MyColors.text4,
                    ),
                  ),
                  SizedBox(width: 54.w),
                  Text(
                    'روز',
                    style: MyTextStyle.textMatn10W300.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MyColors.text4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),
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
          duration: Duration(seconds: 2),
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
