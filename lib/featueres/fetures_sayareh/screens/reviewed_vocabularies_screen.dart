import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/services/tts_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/practice_vocabulary_bloc/practice_vocabulary_bloc.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/practice_vocabulary_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.secondaryTint4,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.r),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                LessonScreen.routeName,
                arguments: {
                  'index': 0,
                  'title': 'درس',
                  'lessonId': widget.courseId,
                },
              );
            },
          ),
        ],
        centerTitle: true,
        title: Text(
          'واژگان مرور شده',
          style: MyTextStyle.textHeader16Bold,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.reviewedVocabularies.isEmpty
                  ? Center(
                      child: Text(
                        'هیچ واژه‌ای مرور نشده است',
                        style: MyTextStyle.textMatn14Bold,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: widget.reviewedVocabularies.length,
                      itemBuilder: (context, index) {
                        final reviewedVocab =
                            widget.reviewedVocabularies[index];
                        final word = reviewedVocab.word;
                        final isCorrect = reviewedVocab.isCorrect;

                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isCorrect
                                  ? const Color(0xFFADFF99)
                                  : const Color(0xFFFFB199),
                              width: 2.w,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Word Image
                                    FutureBuilder<String>(
                                      future: storageService
                                          .callGetDownloadPublicUrl(
                                              word.thumbnail),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container(
                                            width: 80.w,
                                            height: 80.h,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        if (snapshot.hasError ||
                                            !snapshot.hasData) {
                                          return Container(
                                            width: 80.w,
                                            height: 80.h,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: const Icon(Icons.error),
                                          );
                                        }
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          child: Image.network(
                                            snapshot.data!,
                                            width: 80.w,
                                            height: 80.h,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 16.w),
                                    // Word Details
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
                                                    color:
                                                        const Color(0xFF3D495C),
                                                    fontSize: 18.sp,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                isCorrect
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: isCorrect
                                                    ? const Color(0xFF4CAF50)
                                                    : const Color(0xFFFF5252),
                                                size: 24.r,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            word.translation,
                                            style: MyTextStyle.textMatn14Bold
                                                .copyWith(
                                              color: const Color(0xFF52617A),
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                // Action Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Add to Listener Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: MyColors.secondaryTint4,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: IconButton(
                                        onPressed: () =>
                                            _addToListener(word.id),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Color(0xFF3D495C),
                                        ),
                                        iconSize: 28.r,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    // Speak Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            MyColors.primary.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: IconButton(
                                        onPressed: () => _readWord(word.word),
                                        icon: const IconifyIcon(
                                          icon: "cuida:volume-2-outline",
                                          color: Color(0xFF3D495C),
                                        ),
                                        iconSize: 28.r,
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, -2.h),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.r),
              child: SafeArea(
                child: Row(
                  children: [
                    // تمرین ها Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            LessonScreen.routeName,
                            arguments: {
                              'index': 0,
                              'title': 'درس',
                              'lessonId': widget.courseId,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'تمرین ها',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontFamily: "IranSans",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // مرور دوباره Button
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
                          backgroundColor: MyColors.secondaryTint4,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'مرور دوباره',
                          style: TextStyle(
                            color: Color(0xFF3D495C),
                            fontSize: 16.sp,
                            fontFamily: "IranSans",
                            fontWeight: FontWeight.bold,
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
