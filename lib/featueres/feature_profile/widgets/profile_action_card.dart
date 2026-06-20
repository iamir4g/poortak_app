import 'package:flutter/material.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class ProfileActionCard extends StatelessWidget {
  final String iconAssetPath;
  final String label;
  final VoidCallback onTap;

  const ProfileActionCard({
    super.key,
    required this.iconAssetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: Dimens.nh(104),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: Dimens.nw(17)),
      decoration: BoxDecoration(
        color: isDark ? MyColors.termsBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(Dimens.nr(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Dimens.nr(4),
            offset: Offset(0, Dimens.nh(2)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimens.nr(22)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimens.nr(22)),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Dimens.nw(24)),
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                buildImageFromAssetOrEmbeddedSvg(
                  iconAssetPath,
                  width: Dimens.nr(39),
                  height: Dimens.nr(39),
                  fit: BoxFit.contain,
                ),
                SizedBox(width: Dimens.nw(16)),
                Expanded(
                  child: Text(
                    label,
                    style: MyTextStyle.textMatn16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? MyColors.profileTextPrimaryDark
                          : MyColors.textCancelButton,
                      height: 1.375,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

