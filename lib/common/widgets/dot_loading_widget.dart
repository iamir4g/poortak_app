import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DotLoadingWidget extends StatelessWidget {
  final double? size;
  const DotLoadingWidget({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: LoadingAnimationWidget.progressiveDots(
          size: size ?? 50.r,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
