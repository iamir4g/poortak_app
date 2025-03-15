import 'package:flutter/material.dart';
import 'package:poortak/common/widgets/bottom_nav.dart';

class MainWrapper extends StatelessWidget {
  static const routeName = "/main_wrapper";
  MainWrapper({super.key});

  PageController controller = PageController();

  List<Widget> topLevelScreens = [
    Container(
      color: Colors.red,
    ),
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
      bottomNavigationBar: BottomNav(controller: controller),
      body: PageView(controller: controller, children: topLevelScreens),
    );
  }
}
