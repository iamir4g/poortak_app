import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/services/payment_service.dart';
import 'package:poortak/featueres/featureMenu/screens/faq_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _handlePayment(BuildContext context) {
    final paymentService = PaymentService();

    paymentService.startPayment(
      amount: 10000, // 1000 Toman = 10000 Rials
      description: "پرداخت در اپلیکیشن پورتک",
      callbackUrl: "poortak://payment", // You'll need to set up deep linking
      onPaymentComplete: (isSuccess, refId) {
        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('پرداخت با موفقیت انجام شد. کد پیگیری: $refId'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پرداخت با خطا مواجه شد. لطفا دوباره تلاش کنید.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
        child: ListView(
          children: [
            SizedBox(
              height: 80,
              width: 240,
              child: Container(
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.red,
                        image: const DecorationImage(
                          image: AssetImage(
                            "assets/images/profile.png",
                          ),
                        ),
                      ),
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "امیر فراهانی",
                      style: MyTextStyle.textMatn14Bold,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add Payment Button
            // ElevatedButton(
            //   onPressed: () => _handlePayment(context),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: MyColors.primary,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     padding: const EdgeInsets.symmetric(vertical: 12),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       IconifyIcon(
            //         icon: "mdi:credit-card-outline",
            //         color: Colors.white,
            //       ),
            //       const SizedBox(width: 8),
            //       Text(
            //         "پرداخت",
            //         style: MyTextStyle.textMatn14Bold.copyWith(
            //           color: Colors.white,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: "famicons:moon",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "حالت شب",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: "ic:baseline-more-time",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "یادآور مطالعه",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: "famicons:settings-outline",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "تنظیمات",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, FAQScreen.routeName);
              },
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: "ph:chat-dots-light",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "سوالات رایج",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    size: 18.0,
                    icon: "lsicon:circle-more-outline",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "پشتیبانی",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: "ion:call-outline",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "تماس با ما",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: "material-symbols-light:info-outline-rounded",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "درباره ی ما",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MyColors.background1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: IconifyIcon(
                    icon: "mynaui:share",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text(
                "اشتراک گذاری به دوستان",
                style: MyTextStyle.textMatn14Bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
