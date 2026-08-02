import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SayarehBundlePromo extends StatelessWidget {
  final VoidCallback? onTap;

  const SayarehBundlePromo({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 14.h, 16.w, 14.h),
          decoration: BoxDecoration(
            gradient: MyColors.sayarehHomeBundleGradient,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  'assets/images/sayareh_home/promo_chest.png',
                  width: 72.w,
                  height: 72.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'دسترسی به همه قسمت‌ها',
                      textAlign: TextAlign.right,
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'همراه ۲۱ کتاب + تخفیف ویژه',
                      textAlign: TextAlign.right,
                      style: MyTextStyle.description10Medium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
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
                        'خرید کل مجموعه',
                        style: MyTextStyle.textMatn12Bold.copyWith(
                          color: MyColors.sayarehHomePurple,
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
