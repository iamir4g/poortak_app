import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

class PrizeHistoryItem extends StatelessWidget {
  final String title;
  final String points;
  final bool isCompleted;

  const PrizeHistoryItem({
    super.key,
    required this.title,
    required this.points,
    this.isCompleted = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
        width: 360,
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? MyColors.darkCardBackground
              : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // Check icon
              SizedBox(
                width: 25,
                height: 25,
                // margin: const EdgeInsets.only(left: 16),
                child: isCompleted
                    ? Image.asset(
                        'assets/images/check_icon.png',
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        Icons.pending,
                        color: isDarkMode
                            ? MyColors.darkTextSecondary
                            : MyColors.textSecondary,
                        size: 20,
                      ),
              ),

              // Title
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'IranSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : MyColors.textMatn2,
                    ),
                  ),
                ),
              ),
              // Points amount
              Container(
                margin: const EdgeInsets.only(left: 16),
                child: Text(
                  points,
                  style: TextStyle(
                    fontFamily: 'IranSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? MyColors.darkTextPrimary
                        : MyColors.textMatn2,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
