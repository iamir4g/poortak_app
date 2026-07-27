import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/featureMenu/data/models/contact_us_model.dart';
import 'package:poortak/featueres/featureMenu/presentation/bloc/contact_us_bloc/contact_us_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  static const String routeName = "/contact-us";
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ContactUsBloc>().add(const GetContactUsInfoEvent());
      }
    });
  }

  String _websiteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  String _websiteDisplay(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

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
        child: BlocBuilder<ContactUsBloc, ContactUsState>(
          builder: (context, state) {
            if (state is ContactUsLoading || state is ContactUsInitial) {
              return Column(
                children: [
                  _buildHeaderSection(
                    headerBackgroundColor: headerBackgroundColor,
                    titleStyle: titleStyle,
                    iconColor: titleColor,
                  ),
                  const Expanded(child: Center(child: DotLoadingWidget())),
                ],
              );
            }

            if (state is ContactUsError) {
              return Column(
                children: [
                  _buildHeaderSection(
                    headerBackgroundColor: headerBackgroundColor,
                    titleStyle: titleStyle,
                    iconColor: titleColor,
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message,
                              style: MyTextStyle.textMatn14Bold.copyWith(
                                color: MyColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            TextButton(
                              onPressed: () {
                                context
                                    .read<ContactUsBloc>()
                                    .add(const GetContactUsInfoEvent());
                              },
                              child: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final info = state is ContactUsSuccess
                ? state.info
                : const ContactUsInfo();

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderSection(
                    headerBackgroundColor: headerBackgroundColor,
                    titleStyle: titleStyle,
                    iconColor: titleColor,
                  ),
                  SizedBox(height: 15.h),
                  _buildContactInfoSection(
                    info: info,
                    cardBackgroundColor: cardBackgroundColor,
                    titleStyle: titleStyle,
                    descriptionStyle: descriptionStyle,
                  ),
                  _buildWebsiteInfoSection(
                    info: info,
                    cardBackgroundColor: cardBackgroundColor,
                    titleStyle: titleStyle,
                    descriptionStyle: descriptionStyle,
                  ),
                  _buildEmailSection(
                    info: info,
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
            );
          },
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
    required ContactUsInfo info,
    required Color cardBackgroundColor,
    required TextStyle titleStyle,
    required TextStyle descriptionStyle,
  }) {
    final address = info.address ?? '';
    final telephones = info.telephones;

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
          if (address.isNotEmpty)
            Text(
              address,
              style: descriptionStyle,
            ),
          if (telephones.isNotEmpty) ...[
            SizedBox(height: 16.h),
            if (telephones.length == 1)
              Text(
                telephones.first,
                style: descriptionStyle,
                textDirection: TextDirection.ltr,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    telephones[0],
                    style: descriptionStyle,
                    textDirection: TextDirection.ltr,
                  ),
                  Text(
                    telephones[1],
                    style: descriptionStyle,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            if (telephones.length > 2) ...[
              SizedBox(height: 12.h),
              ...telephones.skip(2).map(
                    (phone) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        phone,
                        style: descriptionStyle,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildWebsiteInfoSection({
    required ContactUsInfo info,
    required Color cardBackgroundColor,
    required TextStyle titleStyle,
    required TextStyle descriptionStyle,
  }) {
    final websites = info.websites;

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
          ...websites.map(
            (website) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: () {
                  launchUrl(Uri.parse(_websiteUrl(website)));
                },
                child: Text(
                  _websiteDisplay(website),
                  style: descriptionStyle,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection({
    required ContactUsInfo info,
    required Color cardBackgroundColor,
    required TextStyle titleStyle,
    required TextStyle descriptionStyle,
  }) {
    final emails =
        info.emails.isNotEmpty ? info.emails : const ['info@poortak.ir'];

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
          ...emails.map(
            (email) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: () {
                  launchUrl(Uri.parse("mailto:$email"));
                },
                child: Text(
                  email,
                  style: descriptionStyle,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
