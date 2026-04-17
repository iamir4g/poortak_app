import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomConcaveClipper extends CustomClipper<Path> {
  final double curveDepth;
  final double bottomOffset;

  CustomConcaveClipper({
    this.curveDepth = 30.0,
    this.bottomOffset = 50.0,
  });

  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top-left
    path.moveTo(0, 0);

    // Go to top-right
    path.lineTo(size.width, 0);

    // Go to bottom-right
    path.lineTo(size.width, size.height - bottomOffset.h);

    // Create the concave curve at the bottom
    path.quadraticBezierTo(
      size.width * 0.5, // Control point x (center)
      size.height + curveDepth.h, // Control point y (determines depth)
      size.width * 0.2, // End point x (20% from left)
      size.height - (bottomOffset * 0.4).h, // End point y
    );

    // Continue the curve to the left
    path.quadraticBezierTo(
      size.width * 0.05, // Control point x (5% from left)
      size.height - (bottomOffset * 0.9).h, // Control point y
      0, // End point x (left edge)
      size.height - bottomOffset.h, // End point y
    );

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper is CustomConcaveClipper) {
      return oldClipper.curveDepth != curveDepth || oldClipper.bottomOffset != bottomOffset;
    }
    return true;
  }
}
