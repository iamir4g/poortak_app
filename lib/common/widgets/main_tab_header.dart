import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

class MainTabHeader extends StatelessWidget {
  const MainTabHeader({
    super.key,
    required this.isDark,
    required this.onMenuPressed,
    this.showLogoutMenu = false,
    this.onLogout,
  });

  final bool isDark;
  final VoidCallback onMenuPressed;
  final bool showLogoutMenu;
  final VoidCallback? onLogout;

  static const _headerHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDark ? MyColors.darkBackground : MyColors.background;
    final foregroundColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;

    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _headerHeight,
          decoration: MyColors.headerDecoration(
            backgroundColor: backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: foregroundColor),
                onPressed: onMenuPressed,
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              if (showLogoutMenu)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: foregroundColor),
                  onSelected: (value) {
                    if (value == 'logout') {
                      onLogout?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('خروج از حساب کاربری'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
