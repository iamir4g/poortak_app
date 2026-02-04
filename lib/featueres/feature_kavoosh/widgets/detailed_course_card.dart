import 'package:flutter/material.dart';

import 'package:poortak/featueres/feature_kavoosh/screens/video_detail_screen.dart';

class DetailedCourseCard extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final bool isPurchased;
  final String? imagePath;
  final Color backgroundColor;

  const DetailedCourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    this.isPurchased = false,
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
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Content Section (Left side in LTR, Right in RTL - but Row lays out start-to-end)
            // Since app is RTL, we want Image on the Right (Start) and Text on the Left (End)?
            // Wait, in RTL, the first child of a Row is on the Right.
            // Looking at the screenshot: Image is on the Right. Text is on the Left.
            // So in RTL, Image should be the first child.

            // Image Container
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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

            // Text Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29303D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Author
                    Text(
                      author,
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF52617A),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bottom Row: Date and Purchased Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date (Left side of the text area)
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Color(0xFF9BA7C6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                fontFamily: 'IRANSans',
                                fontSize: 10,
                                color: Color(0xFF9BA7C6),
                              ),
                            ),
                          ],
                        ),
                        
                        // Purchased Badge (Right side of the text area - closer to image?)
                        // Actually in the design, the badge is on the far left (end of row in RTL).
                        // The date is closer to the image (start of row in RTL).
                        // Let's swap them if needed. 
                        // In RTL: Row starts right.
                        // Child 1: Date. Child 2: Badge.
                        // So Date is right, Badge is left.
                        // Screenshot shows: Badge is Left, Date is Right (closer to text start).
                        // So Badge should be at the end of the Row (Left).
                        
                        if (isPurchased)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7ED),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'خریداری شده',
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Color(0xFF4CAF50),
                                ),
                              ],
                            ),
                          ),
                      ],
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
