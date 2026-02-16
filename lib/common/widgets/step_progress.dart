import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

class StepProgress extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;

  const StepProgress(
      {super.key, required this.currentIndex, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 300,
      decoration: BoxDecoration(
        color: MyColors.brandPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Progress
          FractionallySizedBox(
            widthFactor: (currentIndex + 1) / totalSteps,
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.brandPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
