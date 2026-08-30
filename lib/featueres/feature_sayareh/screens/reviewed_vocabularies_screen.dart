import 'package:flutter/material.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_sayareh/presentation/bloc/practice_vocabulary_bloc/practice_vocabulary_bloc.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/feature_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/feature_sayareh/screens/practice_vocabulary_screen.dart';

class ReviewedVocabulariesScreen extends StatefulWidget {
  static const routeName = "/reviewed_vocabularies_screen";

  final List<ReviewedVocabulary> reviewedVocabularies;
  final String courseId;

  const ReviewedVocabulariesScreen({
    super.key,
    required this.reviewedVocabularies,
    required this.courseId,
  });

  @override
  State<ReviewedVocabulariesScreen> createState() =>
      _ReviewedVocabulariesScreenState();
}

class _ReviewedVocabulariesScreenState
    extends State<ReviewedVocabulariesScreen> {
  final TTSService ttsService = locator<TTSService>();
  final StorageService storageService = locator<StorageService>();

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  void _initializeTTS() async {
    await ttsService.setMaleVoice();
  }

  void _readWord(String word) async {
    await ttsService.speak(word, voice: 'male');
  }

  void _addToListener(String wordId) {
    debugPrint('Added word $wordId to listener');
    // TODO: Implement add to listener functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('به زودی این قابلیت اضافه خواهد شد'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<ReviewedVocabulary> _uniqueReviewedVocabularies(
    List<ReviewedVocabulary> items,
  ) {
    final latestByWordId = <String, ReviewedVocabulary>{};
    final orderedWordIds = <String>[];

    for (final item in items) {
      if (!latestByWordId.containsKey(item.word.id)) {
        orderedWordIds.add(item.word.id);
      }
      latestByWordId[item.word.id] = item;
    }

    return orderedWordIds.map((id) => latestByWordId[id]!).toList();
  }

  Color _cardBorderColor(bool isDark, bool isCorrect) {
    if (isCorrect) {
      return isDark
          ? MyColors.quizAnswerCorrectBorderDark
          : MyColors.quizAnswerCorrectBorderLight;
    }
    return isDark
        ? MyColors.quizAnswerWrongBorderDark
        : MyColors.quizAnswerWrongBorderLight;
  }

  Color _statusIconColor(bool isDark, bool isCorrect) {
    if (isCorrect) {
      return isDark ? MyColors.quizAnswerCorrectTextDark : MyColors.success;
    }
    return isDark ? MyColors.quizAnswerWrongTextDark : MyColors.darkErrorLight;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uniqueReviewedVocabularies =
        _uniqueReviewedVocabularies(widget.reviewedVocabularies);
    final pageBackgroundColor =
        isDark ? MyColors.profileBackgroundDark : MyColors.secondaryTint4;
    final primaryTextColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1;
    final secondaryTextColor =
        isDark ? MyColors.darkTextSecondary : MyColors.text3;
    final cardBackgroundColor =
        isDark ? MyColors.termsBackgroundDark : MyColors.textLight;
    final bottomBarColor = isDark ? MyColors.termsBackgroundDark : MyColors.textLight;
    final imagePlaceholderColor = isDark
        ? MyColors.paymentHistoryCardHeaderDark
        : MyColors.secondaryTint4;
    final actionButtonBg = isDark
        ? MyColors.paymentHistoryCardHeaderDark
        : MyColors.secondaryTint4;
    final actionIconColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.text2;
    final volumeIconPath = isDark
        ? 'assets/images/icons/volume_dark.png'
        : 'assets/images/icons/volume.png';

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: PoortakAppBar(
        title: 'واژگان مرور شده',
        foregroundColor: primaryTextColor,
        onBackPressed: () => LessonScreen.popBackToLesson(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: uniqueReviewedVocabularies.isEmpty
                  ? Center(
                      child: Text(
                        'هیچ واژه‌ای مرور نشده است',
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          color: primaryTextColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(Dimens.medium),
                      itemCount: uniqueReviewedVocabularies.length,
                      itemBuilder: (context, index) {
                        final reviewedVocab =
                            uniqueReviewedVocabularies[index];
                        final word = reviewedVocab.word;
                        final isCorrect = reviewedVocab.isCorrect;

                        return Container(
                          margin: EdgeInsets.only(bottom: Dimens.medium),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius:
                                BorderRadius.circular(Dimens.radiusLarge),
                            border: Border.all(
                              color: _cardBorderColor(isDark, isCorrect),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(Dimens.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    FutureBuilder<String>(
                                      future: storageService
                                          .callGetDownloadPublicUrl(
                                              word.thumbnail),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container(
                                            width: Dimens.nw(80),
                                            height: Dimens.nh(80),
                                            decoration: BoxDecoration(
                                              color: imagePlaceholderColor,
                                              borderRadius: BorderRadius.circular(
                                                  Dimens.radiusMedium),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: isDark
                                                    ? MyColors.primary
                                                    : null,
                                              ),
                                            ),
                                          );
                                        }
                                        if (snapshot.hasError ||
                                            !snapshot.hasData) {
                                          return Container(
                                            width: Dimens.nw(80),
                                            height: Dimens.nh(80),
                                            decoration: BoxDecoration(
                                              color: imagePlaceholderColor,
                                              borderRadius: BorderRadius.circular(
                                                  Dimens.radiusMedium),
                                            ),
                                            child: Icon(
                                              Icons.error,
                                              color: secondaryTextColor,
                                            ),
                                          );
                                        }
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Dimens.radiusMedium),
                                          child: Image.network(
                                            snapshot.data!,
                                            width: Dimens.nw(80),
                                            height: Dimens.nh(80),
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: Dimens.medium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  word.word,
                                                  style: MyTextStyle
                                                      .textHeader16Bold
                                                      .copyWith(
                                                    color: primaryTextColor,
                                                    fontSize: Dimens.nsp(18),
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                isCorrect
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: _statusIconColor(
                                                  isDark,
                                                  isCorrect,
                                                ),
                                                size: Dimens.iconMedium,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: Dimens.tiny),
                                          Text(
                                            word.translation,
                                            style: MyTextStyle.textMatn14Bold
                                                .copyWith(
                                              color: secondaryTextColor,
                                              fontSize: Dimens.nsp(14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimens.medium),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: actionButtonBg,
                                        borderRadius: BorderRadius.circular(
                                            Dimens.radiusSmall),
                                      ),
                                      child: IconButton(
                                        onPressed: () =>
                                            _addToListener(word.id),
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: actionIconColor,
                                        ),
                                        iconSize: Dimens.iconLarge,
                                      ),
                                    ),
                                    SizedBox(width: Dimens.small),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? MyColors
                                                .paymentHistoryCardHeaderDark
                                            : MyColors.primaryTint3,
                                        borderRadius: BorderRadius.circular(
                                            Dimens.radiusSmall),
                                      ),
                                      child: IconButton(
                                        onPressed: () => _readWord(word.word),
                                        icon: Image.asset(
                                          volumeIconPath,
                                          width: Dimens.iconLarge,
                                          height: Dimens.iconLarge,
                                          fit: BoxFit.contain,
                                        ),
                                        iconSize: Dimens.iconLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Sticky Bottom Buttons
            Container(
              decoration: BoxDecoration(
                color: bottomBarColor,
                boxShadow: [
                  BoxShadow(
                    color: MyColors.textMatn2.withValues(
                      alpha: isDark ? 0.35 : 0.1,
                    ),
                    blurRadius: Dimens.nr(10),
                    offset: Offset(0, -Dimens.nh(2)),
                  ),
                ],
              ),
              padding: EdgeInsets.all(Dimens.medium),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => LessonScreen.popBackToLesson(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          foregroundColor:
                              MyColors.primaryButtonTextColor(isDark),
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.medium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimens.radiusMedium),
                          ),
                        ),
                        child: Text(
                          'بازگشت به درس',
                          style: MyTextStyle.textMatnBtn.copyWith(
                            color: MyColors.primaryButtonTextColor(isDark),
                            fontSize: Dimens.nsp(16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimens.small),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            PracticeVocabularyScreen.routeName,
                            arguments: {'courseId': widget.courseId},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? MyColors.paymentHistoryCardHeaderDark
                              : MyColors.secondaryTint4,
                          foregroundColor: isDark
                              ? MyColors.profileTextPrimaryDark
                              : MyColors.text2,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.medium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimens.radiusMedium),
                          ),
                        ),
                        child: Text(
                          'تمرین دوباره',
                          style: MyTextStyle.textMatnBtn.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: Dimens.nsp(16),
                            color: isDark
                                ? MyColors.profileTextPrimaryDark
                                : MyColors.text2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
