// import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/utils/custom_textStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/custom_video_player.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';
import 'package:poortak/locator.dart';

class LessonScreen extends StatefulWidget {
  static const routeName = "/lesson_screen";
  final int index;
  final String title;

  const LessonScreen({
    super.key,
    required this.index,
    required this.title,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  String videoTestPath = "assets/videos/poortak_test.mp4";

  @override
  void initState() {
    super.initState();
    // Call the storage API when the screen initializes
    context.read<SayarehCubit>().callSayarehStorageEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.secondaryTint4,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
          ),
        ),
        title: Text(widget.title),
      ),
      body: BlocBuilder<SayarehCubit, SayarehState>(
        builder: (context, state) {
          // Show loading only when explicitly loading storage data
          if (state.sayarehDataStatus is SayarehDataLoading) {
            return Stack(
              children: [
                _buildContent(),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          // Show error state if storage API fails
          if (state.sayarehDataStatus is SayarehStorageError) {
            final error = state.sayarehDataStatus as SayarehStorageError;
            return Stack(
              children: [
                _buildContent(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error.errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<SayarehCubit>()
                              .callSayarehStorageEvent();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // For all other states (including initial and completed), show the content
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: CustomVideoPlayer(
              videoPath: videoTestPath,
              isNetworkVideo: false,
              width: 350,
              height: 240,
              borderRadius: 37,
              autoPlay: true,
              showControls: true,
            ),
          ),
          const SizedBox(height: 18),
          //card lesons
          Container(
            width: 350,
            height: 104,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: MyColors.background),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 28),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/chat_icon.png",
                    width: 48.0,
                    height: 48.0,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("conversation",
                          style: CustomTextStyle.titleLesonText),
                      Text("مکالمه", style: CustomTextStyle.subTitleLeasonText)
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 350,
            height: 104,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: MyColors.background),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 28),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/words_icon.png",
                    width: 48.0,
                    height: 48.0,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("vocabulary", style: CustomTextStyle.titleLesonText),
                      Text("واژگان", style: CustomTextStyle.subTitleLeasonText)
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 350,
            height: 104,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: MyColors.background),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 22, horizontal: 28),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/quiz_icon.png",
                    width: 48.0,
                    height: 48.0,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Quiz", style: CustomTextStyle.titleLesonText),
                      Text("آزمون", style: CustomTextStyle.subTitleLeasonText)
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
