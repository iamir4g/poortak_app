import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';

class AddWordBottomSheet extends StatefulWidget {
  const AddWordBottomSheet({super.key});

  @override
  State<AddWordBottomSheet> createState() => _AddWordBottomSheetState();
}

class _AddWordBottomSheetState extends State<AddWordBottomSheet> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LitnerBloc, LitnerState>(
      listener: (context, state) {
        if (state is CreateWordSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لغت به لایتنر اضافه شد'),
              backgroundColor: MyColors.success,
              duration: Duration(milliseconds: 800),
            ),
          );
          _wordController.clear();
          _translationController.clear();
        } else if (state is LitnerError) {
          final isWordExistsError = state.message == "این لغت قبلا اضافه شده";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor:
                  isWordExistsError ? MyColors.warning : MyColors.error,
              duration: const Duration(milliseconds: 800),
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: MyColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'افزودن واژه جدید',
                style: MyTextStyle.textHeader16Bold
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 32),
              // English Word Label
              Text(
                'واژه انگلیسی',
                style: MyTextStyle.textMatn12W500,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              // English Word Input
              Container(
                decoration: BoxDecoration(
                  color: MyColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextFormField(
                  controller: _wordController,
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn15,
                  decoration: const InputDecoration(
                    hintText: 'واژه را وارد کنید',
                    hintStyle: MyTextStyle.textHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا لغت را وارد کنید';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Persian Translation Label
              Text(
                'معنی فارسی',
                style: MyTextStyle.textMatn12W500,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              // Persian Translation Input
              Container(
                decoration: BoxDecoration(
                  color: MyColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextFormField(
                  controller: _translationController,
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn15,
                  decoration: const InputDecoration(
                    hintText: 'معنی واژه را وارد کنید',
                    hintStyle: MyTextStyle.textHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا ترجمه را وارد کنید';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: BlocBuilder<LitnerBloc, LitnerState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is LitnerLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    context.read<LitnerBloc>().add(
                                          CreateWordEvent(
                                            word: _wordController.text,
                                            translation:
                                                _translationController.text,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: state is LitnerLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        MyColors.textLight),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add,
                                        color: MyColors.textLight),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ذخیره کردن',
                                      style: MyTextStyle.textMatnBtn
                                          .copyWith(fontSize: 16),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: MyColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'لغو',
                        style: MyTextStyle.textCancelButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save Button
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
