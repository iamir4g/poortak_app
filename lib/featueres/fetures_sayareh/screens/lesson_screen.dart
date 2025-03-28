import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/utils/custom_textStyle.dart';

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
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image.network(widget.image),

            Center(
              child: Container(
                width: 350,
                height: 240,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(37)),
                    color: Colors.red),
              ),
            ),

            SizedBox(
              height: 18,
            ),
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

            SizedBox(
              height: 12,
            ),
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
            SizedBox(
              height: 12,
            ),
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
            SizedBox(
              height: 12,
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         widget.title,
            //         style: CustomTextStyle.lessonTitle,
            //       ),
            //       const SizedBox(height: 8),

            //       const SizedBox(height: 16),
            //       Text("Lesson ${widget.index + 1}",
            //           style: CustomTextStyle.lessonNumber),
            //       // Add more content as needed
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
