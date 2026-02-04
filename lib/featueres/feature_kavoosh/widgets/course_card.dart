import 'package:flutter/material.dart';

import 'package:poortak/featueres/feature_kavoosh/screens/video_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String? imagePath; // For now we might use placeholder or assets
  final Color backgroundColor;

  const CourseCard({
    super.key,
    required this.title,
    this.imagePath,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          VideoDetailScreen.routeName,
          arguments: {'title': title},
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),
            // Title
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF29303D),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
