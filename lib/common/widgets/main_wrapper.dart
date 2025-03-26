import 'package:flutter/material.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/widgets/bottom_nav.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/sayareh_screen.dart';

class MainWrapper extends StatelessWidget {
  static const routeName = "/main_wrapper";
  MainWrapper({super.key});

  PageController controller = PageController();

  List<Widget> topLevelScreens = [
    SayarehScreen(),
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.yellow,
    ),
    Container(
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(150.0),
        //   child: Container(
        //     height: 57,
        //     // width: 100,
        //     color: Colors.white,
        //     alignment: Alignment.center,
        //     child: const Text('Some content'),
        //   ),
        // ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30.0),
            ),
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Color(0xFF72326a),
            //     Color(0xFF321c53),
            //   ],
            // ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
        // title: Text("Poortak"),
        // actions: [
        //   IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        // ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
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
                      width: 50,
                      height: 50,
                      color: Colors.red,
                    ),
                    Text("امیر فراهانی")
                  ],
                ),
              ),
            ),
            // ListTile(
            //   title: Text("Profile"),
            // ),
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
              title: Text("حالت شب"),
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
              title: Text("یادآور مطالعه"),
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
                    icon: "famicons:settings-outline",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text("تنظیمات"),
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
                    icon: "ph:chat-dots-light",
                    color: MyColors.text3,
                  ),
                ),
              ),
              title: Text("سوالات رایج"),
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
              title: Text("پشتیبانی"),
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
              title: Text("تماس با ما"),
            ),
            // ListTile(
            //   leading: IconifyIcon(icon: "tdesign:moon"),
            //   title: Text("Settings"),
            // ),
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
              title: Text("درباره ی ما"),
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
              title: Text("اشتراک گذاری به دوستان"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(controller: controller),
      body: PageView(controller: controller, children: topLevelScreens),
    );
  }
}
