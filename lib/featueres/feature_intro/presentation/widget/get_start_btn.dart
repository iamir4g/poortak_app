import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GetStartBtn extends StatefulWidget {
  final String text;
  final Function onTap;
  const GetStartBtn({super.key, required this.text, required this.onTap});

  @override
  State<GetStartBtn> createState() => _GetStartBtnState();
}

class _GetStartBtnState extends State<GetStartBtn>
    with TickerProviderStateMixin {
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fadeController = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    fadeAnimation = CurvedAnimation(parent: fadeController, curve: Curves.ease);
    fadeController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SizedBox(
        height: 45.h,
        width: 120.w,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r), // <-- Radius
            ),
          ),
          onPressed: () {
            widget.onTap();
          },
          child: Text(
            widget.text,
            style: TextStyle(
                fontSize: 17.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontFamily: 'Vazir'),
          ),
        ),
      ),
    );
  }
}
