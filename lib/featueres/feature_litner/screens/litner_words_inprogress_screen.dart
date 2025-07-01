import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import '../widgets/add_word_bottom_sheet.dart';

class LitnerWordsInprogressScreen extends StatefulWidget {
  static const String routeName = '/litner-words-inprogress';
  const LitnerWordsInprogressScreen({super.key});

  @override
  State<LitnerWordsInprogressScreen> createState() =>
      _LitnerWordsInprogressScreenState();
}

class _LitnerWordsInprogressScreenState
    extends State<LitnerWordsInprogressScreen> {
  void _showAddWordBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // builder: (context) => const AddWordBottomSheet(),
      builder: (context) => BlocProvider.value(
        value: context.read<LitnerBloc>(),
        child: AddWordBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لغات در حال یادگیری',
          style: MyTextStyle.textHeader16Bold,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: MyColors.brandPrimary,
        onPressed: _showAddWordBottomSheet,
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'لغات در حال یادگیری',
              style: MyTextStyle.textHeader16Bold,
            ),
          ],
        ),
      ),
    );
  }
}
