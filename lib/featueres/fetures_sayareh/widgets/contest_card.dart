import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class ContestCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ContestCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 16.w, 14.h),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).cardColor : null,
            gradient: isDark ? null : MyColors.sayarehHomeContestGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF11131C)
                      : Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _GiftBoxAsset(size: 34.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'مسابقه پورتک',
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn16Bold.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'در مسابقه ماهانه پورتک شرکت کنید و جایزه ببرید.',
                      textAlign: TextAlign.right,
                      style: MyTextStyle.description10Medium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'شرکت می‌کنم',
                        style: MyTextStyle.textMatn12Bold.copyWith(
                          color: MyColors.sayarehHomeContestEnd,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftBoxAsset extends StatelessWidget {
  final double size;

  const _GiftBoxAsset({
    required this.size,
  });

  static const _assetPath = 'assets/images/main/gift-box.svg';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: loadEmbeddedPngBytesFromSvgAsset(_assetPath),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          );
        }

        return SvgPicture.asset(
          _assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
