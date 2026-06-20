import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  static const String routeName = "/contact-us";
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? MyColors.darkBackground : MyColors.background3;
    final headerBackgroundColor =
        isDark ? MyColors.darkCardBackground : MyColors.background;
    final cardBackgroundColor =
        isDark ? MyColors.darkCardBackground : MyColors.background;
    final titleColor =
        isDark ? MyColors.darkTextPrimary : MyColors.activeTabBackground;
    final descriptionColor =
        isDark ? MyColors.darkTextSecondary : MyColors.activeTabBackground;
    final titleStyle =
        MyTextStyle.contactTitle18Light.copyWith(color: titleColor);
    final descriptionStyle =
        MyTextStyle.contactDescription15Light.copyWith(color: descriptionColor);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(
                headerBackgroundColor: headerBackgroundColor,
                titleStyle: titleStyle,
                iconColor: titleColor,
              ),
              SizedBox(height: 15.h),
              _buildContactInfoSection(
                cardBackgroundColor: cardBackgroundColor,
                titleStyle: titleStyle,
                descriptionStyle: descriptionStyle,
              ),
              _buildWebsiteInfoSection(
                cardBackgroundColor: cardBackgroundColor,
                titleStyle: titleStyle,
                descriptionStyle: descriptionStyle,
              ),
              _buildEmailSection(
                cardBackgroundColor: cardBackgroundColor,
                titleStyle: titleStyle,
                descriptionStyle: descriptionStyle,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 187.h,
                width: 350.w,
                child: Image.asset(
                  "assets/images/contactUs/Poortak_Phone.png",
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection({
    required Color headerBackgroundColor,
    required TextStyle titleStyle,
    required Color iconColor,
  }) {
    return Container(
      height: 57.h,
      decoration: BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تماس با ما',
              style: titleStyle,
              textAlign: TextAlign.center,
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_forward,
                color: iconColor,
                size: 24.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection({
    required Color cardBackgroundColor,
    required TextStyle titleStyle,
    required TextStyle descriptionStyle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: MyColors.shadow,
            blurRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
        ],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: cardBackgroundColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "مراکز پخش و پشتیبانی:",
            style: titleStyle,
          ),
          SizedBox(height: 24.h),
          Text(
            "تهران، خیابان انقلاب، خیابان 12 فروردین، پاساژ ناشران فروشگاه انتشارات تاجیک",
            style: descriptionStyle,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "021-66953621",
                style: descriptionStyle,
              ),
              Text(
                "021-66953620",
                style: descriptionStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteInfoSection({
    required Color cardBackgroundColor,
    required TextStyle titleStyle,
    required TextStyle descriptionStyle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: MyColors.shadow,
            blurRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: Border.all(
          color: cardBackgroundColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'وبسایت های ما:',
                  style: titleStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          InkWell(
            onTap: () {
              launchUrl(Uri.parse("https://poortak.ir"));
            },
            child: Text(
              "https://poortak.ir",
              style: descriptionStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection({
    required Color cardBackgroundColor,
    required TextStyle titleStyle,
    required TextStyle descriptionStyle,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: MyColors.shadow,
            blurRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
        ],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: cardBackgroundColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'آدرس الکترونیکی:',
                  style: titleStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          InkWell(
            onTap: () {
              launchUrl(Uri.parse("mailto:info@poortak.ir"));
            },
            child: Text(
              "info@poortak.ir",
              style: descriptionStyle,
            ),
          ),
        ],
      ),
    );
  }
}
