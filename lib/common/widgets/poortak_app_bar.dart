import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class PoortakAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool backButtonEnabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? leading;
  final List<Widget>? actions;
  final TextStyle? titleStyle;
  final double borderRadius;
  final bool centerTitle;

  const PoortakAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onBackPressed,
    this.showBackButton = true,
    this.backButtonEnabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.actions,
    this.titleStyle,
    this.borderRadius = 30,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBackgroundColor = backgroundColor ??
        (isDark ? MyColors.darkBackgroundSecondary : Colors.white);
    final primaryTextColor = foregroundColor ??
        (isDark ? MyColors.darkTextPrimary : MyColors.textMatn1);
    final radius = BorderRadius.only(
      bottomLeft: Radius.circular(borderRadius.r),
    );

    final backAction = showBackButton
        ? IconButton(
            onPressed: !backButtonEnabled
                ? null
                : (onBackPressed ?? () => Navigator.of(context).pop()),
            icon: Icon(Icons.arrow_forward, color: primaryTextColor),
          )
        : null;

    final allActions = <Widget>[
      if (actions != null) ...actions!,
      if (backAction != null) backAction,
    ];

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius),
      flexibleSpace: Container(
        decoration: MyColors.headerDecoration(
          backgroundColor: headerBackgroundColor,
          borderRadius: radius,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: primaryTextColor,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leading: leading,
      actions: allActions.isEmpty ? null : allActions,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: (titleStyle ?? MyTextStyle.textHeader16Bold).copyWith(
                    color: primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null),
    );
  }
}
