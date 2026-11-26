import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/bloc/long_caption_bloc/long_caption_bloc.dart';
import 'package:poortak/common/models/long_caption_model.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class AboutUsScreen extends StatefulWidget {
  static const routeName = '/about-us';

  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<LongCaptionBloc>()
            .add(const GetLongCaptionEvent(LongCaptionKey.aboutUs));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? MyColors.darkBackground : MyColors.background3;
    final headerBackgroundColor =
        isDark ? MyColors.darkCardBackground : Colors.white;
    final primaryTextColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textCancelButton;
    final bodyTextColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PoortakAppBar(
        title: 'درباره ی ما',
        backgroundColor: headerBackgroundColor,
        foregroundColor: primaryTextColor,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<LongCaptionBloc, LongCaptionState>(
          builder: (context, state) {
            if (state is LongCaptionLoading || state is LongCaptionInitial) {
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
                              const GetLongCaptionEvent(LongCaptionKey.aboutUs));
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
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < paragraphs.length; i++) ...[
                          if (i > 0) SizedBox(height: 16.h),
                          Text(
                            paragraphs[i],
                            style: MyTextStyle.textMatn13.copyWith(
                              height: 1.8,
                              color: bodyTextColor,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    height: 175.h,
                    width: 247.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      image: const DecorationImage(
                        image: AssetImage(
                            'assets/images/bb988dc544213a4e701876539a24257f921a670f.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
