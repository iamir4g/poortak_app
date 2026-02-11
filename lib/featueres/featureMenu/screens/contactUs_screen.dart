import 'package:flutter/material.dart';
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background3,
      body: SafeArea(
        child: Column(
          children: [
            // Section 1: Header (based on Figma 467:5902)
            _buildHeaderSection(),

            // Section 2: Contact Information (based on Figma 769:10683)
            _buildContactInfoSection(),

            // Section 4: Additional Info (based on Figma 769:10685)
            _buildWebsiteInfoSection(),

            // Section 5: Illustration/Image
            _buildEmailSection(),

            SizedBox(
              height: 187,
              width: 350,
              child: Image.asset(
                "assets/images/contactUs/Poortak_Phone.png",
                fit: BoxFit.cover,
                // errorBuilder: (context, error, stackTrace) {
                //   return Container(
                //     decoration: BoxDecoration(
                //       color: MyColors.background,
                //       borderRadius: BorderRadius.circular(16),
                //       border: Border.all(
                //         color: MyColors.shadow.withOpacity(0.3),
                //         width: 1,
                //       ),
                //     ),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Icon(
                //           Icons.phone_android_rounded,
                //           size: 48,
                //           color: MyColors.primary,
                //         ),
                //         const SizedBox(height: 8),
                //         Text(
                //           'Poortak Phone',
                //           style: MyTextStyle.textMatn14Bold,
                //         ),
                //       ],
                //     ),
                //   );
                // },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section 1: Header based on Figma design 467:5902
  Widget _buildHeaderSection() {
    return Container(
        height: 57,
        decoration: const BoxDecoration(
          color: MyColors.background,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تماس با ما',
                style: MyTextStyle.textHeader16Bold,
                textAlign: TextAlign.center,
              ),
              Icon(
                Icons.arrow_forward,
                color: MyColors.textMatn1,
                size: 24,
              ),
            ],
          ),
        ));
  }

  // Section 2: Contact Information based on Figma design 769:10683
  Widget _buildContactInfoSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MyColors.background,
        boxShadow: [
          BoxShadow(
            color: MyColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MyColors.background,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "مراکز پخش و پشتیبانی:",
            style: MyTextStyle.textHeader16Bold,
          ),
          const SizedBox(height: 24),
          Text(
            "تهران، خیابان انقلاب، خیابان 12 فروردین، پاساژ ناشران فروشگاه انتشارات تاجیک",
            style: MyTextStyle.textMatn14Bold,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "021-66953621",
                style: MyTextStyle.textMatn14Bold,
              ),
              Text(
                "021-66953620",
                style: MyTextStyle.textMatn14Bold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section 4: Additional Info based on Figma design 769:10685
  Widget _buildWebsiteInfoSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MyColors.background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: MyColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: MyColors.background,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'وبسایت های ما:',
                  style: TextStyle(
                    fontFamily: "IranSans",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MyColors.textMatn1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              launchUrl(Uri.parse("https://poortak.ir"));
            },
            child: Text(
              "https://poortak.ir",
              style: MyTextStyle.textMatn14Bold,
            ),
          ),
        ],
      ),
    );
  }

  // Section 5: Illustration/Image Section
  Widget _buildEmailSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MyColors.background,
        boxShadow: [
          BoxShadow(
            color: MyColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MyColors.background,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'آدرس الکترونیکی:',
                  style: TextStyle(
                    fontFamily: "IranSans",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MyColors.textMatn1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              launchUrl(Uri.parse("mailto:info@poortak.ir"));
            },
            child: Text(
              "info@poortak.ir",
              style: MyTextStyle.textMatn14Bold,
            ),
          ),
        ],
      ),
    );
  }
}
