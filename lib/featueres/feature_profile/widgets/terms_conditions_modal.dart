import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/bloc/long_caption_bloc/long_caption_bloc.dart';
import 'package:poortak/common/models/long_caption_model.dart';
import 'package:poortak/common/services/answer_feedback_sound_service.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/config/my_theme.dart';
import 'package:poortak/locator.dart';

class TermsConditionsModal extends StatelessWidget {
  const TermsConditionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final termsTheme = theme.extension<TermsConditionsTheme>() ??
        (theme.brightness == Brightness.dark
            ? TermsConditionsTheme.dark
            : TermsConditionsTheme.light);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        width: 333.w,
        height: 600.h, // Adjusted height to be more reasonable
        decoration: BoxDecoration(
          color: termsTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 73.h,
              padding: EdgeInsets.symmetric(horizontal: 19.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "قوانین و مقررات ",
                              style: MyTextStyle.textMatn12Bold.copyWith(
                                fontSize: 15.sp,
                                color: MyColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "خرید از پورتک",
                              style: MyTextStyle.textMatn12Bold.copyWith(
                                fontSize: 15.sp,
                                color: termsTheme.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Empty space to balance the close button
                      SizedBox(width: 24.w),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: Icon(
                            Icons.close,
                            color: termsTheme.iconColor,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 1.h,
                    color: termsTheme.dividerColor,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: BlocBuilder<LongCaptionBloc, LongCaptionState>(
                builder: (context, state) {
                  if (state is LongCaptionLoading ||
                      state is LongCaptionInitial) {
                    return const Center(child: DotLoadingWidget());
                  }

                  if (state is LongCaptionError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message,
                              style: MyTextStyle.textMatn14Bold.copyWith(
                                color: MyColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            TextButton(
                              onPressed: () {
                                context.read<LongCaptionBloc>().add(
                                    const GetLongCaptionEvent(
                                        LongCaptionKey.tos));
                              },
                              child: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final paragraphs = state is LongCaptionSuccess
                      ? state.caption.paragraphs
                      : const <String>[];

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 19.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        for (var i = 0; i < paragraphs.length; i++) ...[
                          if (i > 0) SizedBox(height: 16.h),
                          Text(
                            paragraphs[i],
                            style: MyTextStyle.textMatn13.copyWith(
                              fontSize: 14.sp,
                              color: termsTheme.textColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    unawaited(AnswerFeedbackSoundService.playPopup());
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (_) => locator<LongCaptionBloc>()
            ..add(const GetLongCaptionEvent(LongCaptionKey.tos)),
          child: const TermsConditionsModal(),
        );
      },
    );
  }
}
