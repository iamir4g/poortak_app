import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/myColors.dart';

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
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1.r,
                blurRadius: 3.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'مسابقه پورتک',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFFFFFFF)
                            : Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'در مسابقه ماهانه پورتک شرکت کنید و جایزه ببرید.',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF838697)
                            : Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF11131C) : MyColors.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.18)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Center(
                  child: _GiftBoxAsset(
                    size: 40.r,
                  ),
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
