// import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/utils/custom_textStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/custom_video_player.dart';

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
      body: SingleChildScrollView(
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
                        Text("مکالمه",
                            style: CustomTextStyle.subTitleLeasonText)
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
                        Text("vocabulary",
                            style: CustomTextStyle.titleLesonText),
                        Text("واژگان",
                            style: CustomTextStyle.subTitleLeasonText)
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
      ),
    );
  }
}
