import 'package:flutter/material.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/dialog_cart.dart';

class ItemLeason extends StatelessWidget {
  final Lesson item;
  final int index;
  final bool purchased;
  final Function() onTap;
  const ItemLeason(
      {super.key,
      required this.item,
      required this.onTap,
      required this.purchased,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (item.price != "0") {
        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return DialogCart(item: item); //buildDialog(context, item);
        //     });
        // } else {
        Navigator.pushNamed(context, LessonScreen.routeName, arguments: {
          'index': index,
          'title': item.name,
          'lessonId': item.id,
          'purchased': purchased,
        });
        // }
      },
      child: Container(
        width: 360,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MyColors.background,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(children: [
                CircleAvatar(
                  maxRadius: 30,
                  minRadius: 30,
                  child: FutureBuilder<String>(
                    future: GetImageUrlService().getImageUrl(item.thumbnail),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Icon(Icons.error);
                      }
                      return Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name),
                    Text(item.description),
                  ],
                )
              ]),
            ),
            Row(
              children: [
                !purchased
                    ? Image(image: AssetImage("assets/images/lock_image.png"))
                    : SizedBox(),
                SizedBox(
                  width: 8,
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
