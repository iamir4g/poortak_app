import 'package:flutter/material.dart';
import 'package:poortak/common/widgets/bottom_nav.dart';

class TestScreen extends StatelessWidget {
  static const routeName = "/test_screen";

  TestScreen({super.key});

  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomNav(controller: pageController),
    );
  }
}
