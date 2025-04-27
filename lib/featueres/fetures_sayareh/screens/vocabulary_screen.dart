import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

class VocabularyScreen extends StatefulWidget {
  static const routeName = "/vocabulary_screen";
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.secondaryTint4,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
          ),
        ),
        title: Text('واژگان'),
      ),
      body: Column(
        children: [
          Text('Vocabulary'),
        ],
      ),
    );
  }
}
