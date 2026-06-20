import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_match/presentation/bloc/match_bloc/match_bloc.dart';
import 'package:poortak/featueres/feature_match/data/models/match_model.dart';
import 'package:poortak/featueres/feature_match/screens/prize_screen.dart';
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
  late final Future<Uint8List?> _avatarBytesFuture;

  // Countdown values
  int daysRemaining = 0;
  int hoursRemaining = 0;
  Match? currentMatch;

  @override
  void initState() {
    super.initState();
    _avatarBytesFuture = loadEmbeddedPngBytesFromSvgAsset(
        'assets/images/match/match_avatar.svg');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF171926),
                    MyColors.darkBackground,
                    Color(0xFF171926),
                  ],
                  stops: [0.1, 0.54, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF5F0),
                    Color(0xFFFBFDF2),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: Dimens.medium),
                        child: Column(
                          children: [
                            SizedBox(height: Dimens.nh(75)),

                            // Question section
                            _buildQuestionSection(state),

                            SizedBox(height: Dimens.nh(20)),

                            // Description text
                            _buildDescriptionText(),

                            SizedBox(height: Dimens.nh(40)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimens.medium,
        0,
        Dimens.nw(32),
        0,
      ),
      height: Dimens.nh(57),
      decoration: BoxDecoration(
        color: isDark ? MyColors.darkBackgroundSecondary : Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimens.nr(33.5)),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: Offset(0, Dimens.nh(1)),
                  blurRadius: Dimens.nr(1),
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
                color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Back button
          SizedBox(
            width: Dimens.nw(40),
            height: Dimens.nh(40),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_forward,
                color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
                size: Dimens.nr(28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(MatchState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main content area
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: Dimens.nh(20)),
          padding: EdgeInsets.all(Dimens.nr(20)),
          decoration: BoxDecoration(
            color: isDark ? MyColors.termsBackgroundDark : Colors.white,
            borderRadius: BorderRadius.circular(Dimens.nr(22)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: Offset(0, Dimens.nh(2)),
                      blurRadius: Dimens.nr(8),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimens.nh(20)),

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
                    color:
                        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
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
                    color:
                        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
                  ),
                ),

              SizedBox(height: Dimens.nh(20)),

              // Answer input field
              Container(
                height: Dimens.nh(50),
                decoration: BoxDecoration(
                  color: _isAnswerSubmitted()
                      ? (isDark
                          ? MyColors.loginIconContainerDark
                          : const Color(0xFFE0E0E0))
                      : (isDark
                          ? MyColors.loginInputBackgroundDark
                          : const Color(0xFFF8F8F8)),
                  borderRadius: BorderRadius.circular(Dimens.nr(30)),
                ),
                child: TextField(
                  controller: _answerController,
                  enabled: !_isAnswerSubmitted(),
                  textAlign: TextAlign.right,
                  style: MyTextStyle.textMatn16.copyWith(
                    color: _isAnswerSubmitted()
                        ? (isDark
                            ? MyColors.darkTextSecondary.withValues(alpha: 0.7)
                            : MyColors.text4.withValues(alpha: 0.5))
                        : (isDark ? MyColors.darkTextPrimary : MyColors.text4),
                  ),
                  decoration: InputDecoration(
                    hintText: _isAnswerSubmitted()
                        ? 'شما قبلاً پاسخ داده‌اید'
                        : 'جواب سوال:',
                    hintStyle: MyTextStyle.textMatn16.copyWith(
                      color: _isAnswerSubmitted()
                          ? (isDark
                              ? MyColors.darkTextSecondary
                                  .withValues(alpha: 0.7)
                              : MyColors.text4.withValues(alpha: 0.5))
                          : (isDark
                              ? MyColors.darkTextSecondary
                              : MyColors.text4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Dimens.nw(20),
                      vertical: Dimens.nh(15),
                    ),
                  ),
                ),
              ),

              SizedBox(height: Dimens.nh(20)),

              // Submit button
              Center(
                child: Container(
                  width: Dimens.nw(164),
                  height: Dimens.nh(50),
                  decoration: BoxDecoration(
                    color: _isAnswerSubmitted()
                        ? const Color(0xFFBDBDBD)
                        : MyColors.primary,
                    borderRadius: BorderRadius.circular(Dimens.nr(56.5)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Dimens.nr(56.5)),
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
                                    ? Colors.white.withValues(alpha: 0.7)
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
          top: -Dimens.nh(40),
          left: 0,
          child: Container(
            width: Dimens.nw(70),
            height: Dimens.nh(60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimens.nr(10)),
            ),
            child: FutureBuilder<Uint8List?>(
              future: _avatarBytesFuture,
              builder: (context, snapshot) {
                final bytes = snapshot.data;
                if (bytes == null) return const SizedBox.shrink();
                return Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                );
              },
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
              width: Dimens.nw(112),
              height: Dimens.nh(33),
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.medium,
                vertical: Dimens.nh(8),
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? MyColors.darkCardBackground
                    : const Color(0xFFF2F2FE),
                borderRadius: BorderRadius.circular(Dimens.nr(15)),
              ),
              child: Center(
                child: Text(
                  'سوال این ماه',
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    fontWeight: FontWeight.w300,
                    color:
                        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'پس از ارسال پاسخ مسابقه، به نفراتی که پاسخ صحیح داده باشند به قید قرعه جوایز ویژه داده خواهد شد.',
          textAlign: TextAlign.right,
          style: MyTextStyle.textMatn11.copyWith(
            color: isDark ? MyColors.darkTextSecondary : MyColors.text3,
            height: 1.5,
          ),
        ),
        SizedBox(height: Dimens.nh(8)),
        Text(
          'قرعه کشی در اوایل هر ماه انجام می شود و لیست برندگان در بخش (برندگان مسابقه) نمایش داده خواهد شد.',
          textAlign: TextAlign.right,
          style: MyTextStyle.textMatn11.copyWith(
            color: isDark ? MyColors.darkTextSecondary : MyColors.text3,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: Dimens.nh(100),
      padding: EdgeInsets.symmetric(
        vertical: Dimens.nh(12),
        horizontal: Dimens.medium,
      ),
      decoration: BoxDecoration(
        color: isDark ? MyColors.darkBackgroundSecondary : MyColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.nr(20)),
          topRight: Radius.circular(Dimens.nr(20)),
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
              color: isDark ? MyColors.darkTextSecondary : MyColors.text3,
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
                    width: Dimens.nw(50),
                    height: Dimens.nh(50),
                    decoration: BoxDecoration(
                      color: isDark
                          ? MyColors.termsBackgroundDark
                          : const Color(0xFFF2F5FA),
                      borderRadius: BorderRadius.circular(Dimens.nr(5)),
                      border: Border.all(
                        color: isDark
                            ? MyColors.darkBorder
                            : MyColors.text4.withValues(alpha: 0.3),
                        width: Dimens.nw(1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$hoursRemaining',
                          style: MyTextStyle.text24Correct.copyWith(
                            color: isDark
                                ? MyColors.darkTextPrimary
                                : MyColors.text2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: Dimens.small),

                  // Colon
                  Text(
                    ':',
                    style: MyTextStyle.text24Correct.copyWith(
                      color: isDark ? MyColors.darkTextPrimary : MyColors.text2,
                    ),
                  ),

                  SizedBox(width: Dimens.small),

                  // Hours box
                  Container(
                    width: Dimens.nw(50),
                    height: Dimens.nh(50),
                    decoration: BoxDecoration(
                      color: isDark
                          ? MyColors.termsBackgroundDark
                          : const Color(0xFFF2F5FA),
                      borderRadius: BorderRadius.circular(Dimens.nr(5)),
                      border: Border.all(
                        color: isDark
                            ? MyColors.darkBorder
                            : MyColors.text4.withValues(alpha: 0.3),
                        width: Dimens.nw(1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$daysRemaining',
                          style: MyTextStyle.text24Correct.copyWith(
                            // fontWeight: FontWeight.bold,
                            color: isDark
                                ? MyColors.darkTextPrimary
                                : MyColors.text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimens.nh(6)),

              // Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ساعت',
                    style: MyTextStyle.textMatn10W300.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? MyColors.darkTextSecondary : MyColors.text4,
                    ),
                  ),
                  SizedBox(width: Dimens.nw(54)),
                  Text(
                    'روز',
                    style: MyTextStyle.textMatn10W300.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? MyColors.darkTextSecondary : MyColors.text4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimens.nh(6)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: Dimens.nw(24)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: Dimens.nw(360)),
            decoration: BoxDecoration(
              color: isDark ? MyColors.termsBackgroundDark : Colors.white,
              borderRadius: BorderRadius.circular(Dimens.nr(20)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  color: isDark
                      ? MyColors.darkBackgroundSecondary
                      : MyColors.modalHeaderBackground,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: Icon(
                            Icons.close,
                            size: Dimens.nr(22),
                            color: isDark
                                ? MyColors.darkTextPrimary
                                : MyColors.text2,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.medium,
                            vertical: Dimens.nh(24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: Dimens.nr(64),
                                height: Dimens.nr(64),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: MyColors.success,
                                    width: Dimens.nr(3),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check,
                                    size: Dimens.nr(34),
                                    color: MyColors.success,
                                  ),
                                ),
                              ),
                              SizedBox(height: Dimens.nh(16)),
                              Text(
                                'پاسخ شما با موفقیت ارسال شد.',
                                textAlign: TextAlign.center,
                                style: MyTextStyle.textCenter16.copyWith(
                                  fontFamily: 'IRANSans',
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? MyColors.darkTextPrimary
                                      : MyColors.text2,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushNamed(
                        context,
                        MatchPrizeScreen.routeName,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: Dimens.nh(18)),
                      alignment: Alignment.center,
                      child: Text(
                        'مشاهده جوایز مسابقه',
                        textAlign: TextAlign.center,
                        style: (isDark
                                ? MyTextStyle.modalAction16MediumOnDark
                                : MyTextStyle.modalAction16MediumBlue)
                            .copyWith(
                          color: isDark
                              ? MyColors.darkTextAccent
                              : MyTextStyle.modalAction16MediumBlue.color,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: Dimens.nh(1),
                  thickness: Dimens.nh(1),
                  color: isDark ? MyColors.darkBorder : MyColors.gray,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: Dimens.nh(18)),
                      alignment: Alignment.center,
                      child: Text(
                        'بستن',
                        textAlign: TextAlign.center,
                        style: MyTextStyle.modalAction16MediumOnDark.copyWith(
                          color: isDark
                              ? MyColors.darkTextPrimary
                              : MyColors.activeTabBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isAnswerSubmitted() {
    return currentMatch?.data.answer != null;
  }
}
