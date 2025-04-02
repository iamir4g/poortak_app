import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class PrimaryButton extends StatelessWidget {
  final String lable;
  final Function() onPressed;
  final double? width;
  final double? height;

  const PrimaryButton(
      {super.key,
      required this.lable,
      required this.onPressed,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.brandSecondary,
          foregroundColor: MyColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          lable,
          style: MyTextStyle.textMatnBtn,
        ),
      ),
    );
  }
}
