import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';

class KavooshCategoryTabs extends StatelessWidget {
  final List<CategoryNodeSummary> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final IconData Function(CategoryNodeSummary tab) iconFor;

  const KavooshCategoryTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    required this.iconFor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < tabs.length; i++) ...[
                if (i > 0) SizedBox(width: 24.w),
                _TabItem(
                  tab: tabs[i],
                  isSelected: selectedIndex == i,
                  isDark: isDark,
                  icon: iconFor(tabs[i]),
                  onTap: () => onSelected(i),
                ),
              ],
            ],
          ),
        ),
        Container(
          height: 2.h,
          width: double.infinity,
          color: (isDark ? MyColors.darkBorder : Colors.grey)
              .withValues(alpha: 0.35),
          child: Row(
            children: List.generate(tabs.length, (index) {
              return Expanded(
                child: Container(
                  color: selectedIndex == index
                      ? MyColors.primary
                      : Colors.transparent,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final CategoryNodeSummary tab;
  final bool isSelected;
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected
                ? MyColors.primary
                : (isDark ? MyColors.darkTextSecondary : Colors.grey),
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            tab.title,
            style: MyTextStyle.textMatn14Bold.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? MyColors.primary
                  : (isDark ? MyColors.darkTextSecondary : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
