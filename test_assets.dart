import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/kavoosh/videoIcon.png'),
              SizedBox(height: 20),
              Image.asset('assets/images/kavoosh/audioBookIcon.png'),
              SizedBox(height: 20),
              Image.asset('assets/images/kavoosh/ebookIcon.png'),
              SizedBox(height: 20),
              Image.asset('assets/images/kavoosh/selfAssessmentIcon.png'),
            ],
          ),
        ),
      ),
    );
  }
}
