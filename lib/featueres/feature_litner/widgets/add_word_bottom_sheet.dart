import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';

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
              duration: Duration(seconds: 2),
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
              duration: const Duration(seconds: 2),
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          left: 24.w,
          right: 24.w,
          top: 24.h,
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
              SizedBox(height: 32.h),
              // English Word Label
              Text(
                'واژه انگلیسی',
                style: MyTextStyle.textMatn12W500,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 8.h),
              // English Word Input
              Container(
                decoration: BoxDecoration(
                  color: MyColors.inputBackground,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextFormField(
                  controller: _wordController,
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn15,
                  decoration: InputDecoration(
                    hintText: 'واژه را وارد کنید',
                    hintStyle: MyTextStyle.textHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا لغت را وارد کنید';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20.h),
              // Persian Translation Label
              Text(
                'معنی فارسی',
                style: MyTextStyle.textMatn12W500,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 8.h),
              // Persian Translation Input
              Container(
                decoration: BoxDecoration(
                  color: MyColors.inputBackground,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextFormField(
                  controller: _translationController,
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn15,
                  decoration: InputDecoration(
                    hintText: 'معنی واژه را وارد کنید',
                    hintStyle: MyTextStyle.textHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا ترجمه را وارد کنید';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 32.h),
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
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            elevation: 0,
                          ),
                          child: state is LitnerLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            MyColors.textLight),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add,
                                        color: MyColors.textLight),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'ذخیره کردن',
                                      style: MyTextStyle.textMatnBtn
                                          .copyWith(fontSize: 16.sp),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: MyColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(
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
