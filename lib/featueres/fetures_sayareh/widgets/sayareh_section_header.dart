import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SayarehSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget? leading;

  const SayarehSectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'مشاهده همه',
    this.onActionTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          if (actionLabel != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionLabel!,
                style: MyTextStyle.sayarehHomeViewAll.copyWith(
                  color: isDark
                      ? MyColors.darkTextAccent
                      : MyColors.sayarehHomePurple,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          if (leading != null) ...[
            leading!,
            SizedBox(width: 6.w),
          ],
          Text(
            title,
            style: MyTextStyle.sayarehHomeSectionTitle.copyWith(
              color: isDark ? MyColors.darkTextPrimary : MyColors.text1,
            ),
          ),
        ],
      ),
    );
  }
}
