import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/featureMenu/screens/aboutUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/faq_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/contactUs_screen.dart';
import 'package:poortak/featueres/featureMenu/screens/settings_screen.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/profile_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/locator.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  bool isLoggedIn = false;
  String? userName;
  String? userFirstName;
  String? userLastName;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await prefsOperator.getLoggedIn();
    final name = await prefsOperator.getUserName();
    final firstName = await prefsOperator.getUserFirstName();
    final lastName = await prefsOperator.getUserLastName();
    setState(() {
      isLoggedIn = loggedIn;
      userName = name;
      userFirstName = firstName;
      userLastName = lastName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                if (isLoggedIn) {
                  Navigator.pushNamed(context, ProfileScreen.routeName);
                } else {
                  Navigator.pushNamed(context, LoginScreen.routeName);
                }
              },
              child: SizedBox(
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
                              "assets/images/profile/finalProfile.png",
                            ),
                          ),
                        ),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isLoggedIn
                            ? (userFirstName != null && userLastName != null
                                ? "$userFirstName $userLastName"
                                : userFirstName ?? userLastName ?? "کاربر")
                            : "وارد شوید",
                        style: MyTextStyle.textMatn14Bold,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("به زودی")),
                );
                // Navigator.pushNamed(context, PaymentResultScreen.routeName,
                //     arguments: {
                //       'status': 0,
                //       'ref': '1234567890',
                //     });
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
              onTap: () {
                Navigator.pushNamed(context, ContactUsScreen.routeName);
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
              onTap: () {
                Navigator.pushNamed(context, AboutUsScreen.routeName);
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("به زودی.")),
                );
                // Navigator.pushNamed(context, PaymentResultScreen.routeName,
                //     arguments: {
                //       'status': 1,
                //       'ref': '1234567890',
                //     });
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
