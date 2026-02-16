import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/services/getImageUrl_service.dart';
import 'package:poortak/common/widgets/global_progress_bar.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/all_courses_progress_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/dialog_cart.dart';

class ItemLeason extends StatelessWidget {
  final Lesson item;
  final int index;
  final bool purchased;
  final Function() onTap;
  final CourseProgressItem? progress;

  const ItemLeason({
    super.key,
    required this.item,
    required this.onTap,
    required this.purchased,
    required this.index,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    // Get IknowAccessBloc from context
    final accessBloc = context.watch<IknowAccessBloc>();

    // Check if user has access to this course
    final hasAccess = accessBloc.hasCourseAccess(item.id);

    // Use hasAccess instead of purchased
    final isLocked = !hasAccess;

    double average = 0;
    if (progress != null) {
      average =
          (progress!.vocabulary + progress!.conversation + progress!.quiz) / 3;
    }

    return GestureDetector(
      onTap: () {
        // If isDemo is true OR user has access, go directly to lesson screen
        if (item.isDemo || hasAccess) {
          Navigator.pushNamed(context, LessonScreen.routeName, arguments: {
            'index': index,
            'title': item.name,
            'lessonId': item.id,
            'purchased': hasAccess, // Use hasAccess instead of purchased
          });
        } else {
          // If isDemo is false AND user doesn't have access, show add to cart modal
          showDialog(
            context: context,
            builder: (BuildContext context) => DialogCart(item: item),
          );
        }
      },
      child: Container(
        width: 360,
        height: 88,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(children: [
                CircleAvatar(
                  radius: 33.5,
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
                const SizedBox(width: 4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 6),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                )
              ]),
            ),
            Row(
              children: [
                if (progress != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: average >= 100
                        ? Row(
                            children: List.generate(
                                3,
                                (index) => Icon(Icons.star,
                                    color: Colors.amber, size: 20)))
                        : GlobalProgressBar(
                            percentage: average, width: 60, height: 8),
                  ),
                isLocked
                    ? Image(image: AssetImage("assets/images/lock_image.png"))
                    : SizedBox(),
                // : SizedBox(),
                SizedBox(
                  width: 4,
                ),
                IconifyIcon(
                  size: 32,
                  icon: "iconamoon:arrow-left-2-bold",
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
                // Icon(
                //   Icons.arrow_forward_ios,
                //   color: Theme.of(context).textTheme.titleMedium?.color,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
