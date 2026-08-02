import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/data/models/user_points_total_model.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/locator.dart';

class SayarehHomeHeader extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onGiftTap;

  const SayarehHomeHeader({
    super.key,
    this.onMenuTap,
    this.onGiftTap,
  });

  @override
  State<SayarehHomeHeader> createState() => _SayarehHomeHeaderState();
}

class _SayarehHomeHeaderState extends State<SayarehHomeHeader> {
  static const _staticStreakLabel = '۸ روز';

  String? _avatarUrl;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadHeaderData();
  }

  Future<void> _loadHeaderData() async {
    final prefs = locator<PrefsOperator>();
    if (!prefs.isLoggedIn()) {
      if (!mounted) return;
      setState(() {
        _avatarUrl = null;
        _coins = 0;
      });
      return;
    }

    final avatarKey = await prefs.getUserAvatar();
    String? avatarUrl;
    if (avatarKey != null && avatarKey.isNotEmpty) {
      try {
        avatarUrl =
            await locator<StorageService>().callGetDownloadPublicUrl(avatarKey);
      } catch (_) {
        avatarUrl = null;
      }
    }

    int coins = 0;
    try {
      final points =
          await locator<ProfileRepository>().callGetUserPointsTotal();
      if (points is DataSuccess<UserPointsTotalModel> && points.data != null) {
        coins = points.data!.data.remaining;
      }
    } catch (_) {
      coins = 0;
    }

    if (!mounted) return;
    setState(() {
      _avatarUrl = avatarUrl;
      _coins = coins;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          _HeaderIconButton(
            onTap: widget.onMenuTap ??
                () => Scaffold.maybeOf(context)?.openDrawer(),
            child: Icon(
              Icons.menu_rounded,
              size: 24.r,
              color: isDark ? MyColors.darkTextPrimary : MyColors.text1,
            ),
          ),
          SizedBox(width: 8.w),
          _HeaderIconButton(
            onTap: widget.onGiftTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  'assets/images/main/gift-box.svg',
                  width: 22.r,
                  height: 22.r,
                ),
                Positioned(
                  top: -2.h,
                  left: -2.w,
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: MyColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _StatChip(
            icon: Icons.local_fire_department_rounded,
            iconColor: MyColors.primaryShade2,
            label: _staticStreakLabel,
            isDark: isDark,
          ),
          SizedBox(width: 8.w),
          _StatChip(
            icon: Icons.monetization_on_rounded,
            iconColor: MyColors.primary,
            label: '$_coins',
            isDark: isDark,
            isLtr: true,
          ),
          SizedBox(width: 10.w),
          _Avatar(url: _avatarUrl, isDark: isDark),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _HeaderIconButton({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: SizedBox(
          width: 36.r,
          height: 36.r,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;
  final bool isLtr;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
    this.isLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? MyColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.r, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            label,
            textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
            style: MyTextStyle.sayarehHomeHeaderStat.copyWith(
              color: isDark ? MyColors.darkTextPrimary : MyColors.text1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final bool isDark;

  const _Avatar({
    required this.url,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? MyColors.darkCardBackground : MyColors.background3,
        border: Border.all(
          color: isDark ? MyColors.profileAvatarBorderDark : MyColors.gray,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url!.isNotEmpty
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person_rounded,
                size: 22.r,
                color: isDark ? MyColors.darkTextSecondary : MyColors.text5,
              ),
            )
          : Icon(
              Icons.person_rounded,
              size: 22.r,
              color: isDark ? MyColors.darkTextSecondary : MyColors.text5,
            ),
    );
  }
}
