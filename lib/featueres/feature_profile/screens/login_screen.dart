import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_state.dart';
import 'package:poortak/locator.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login_screen";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool showOtpForm = false;
  String? mobileNumber;
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _mobileFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(repository: locator()),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login/login_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Top spacing
                    const SizedBox(height: 60),

                    // Logo section
                    Center(
                      child: Image.asset(
                        'assets/images/poortakLogo.png',
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title section
                    Text(
                      showOtpForm
                          ? "تایید شماره موبایل"
                          : "ورود به حساب کاربری",
                      style: MyTextStyle.textHeader16Bold.copyWith(
                        fontSize: 24,
                        color: MyColors.textMatn1,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      showOtpForm
                          ? "کد ارسال شده به شماره ${mobileNumber ?? ''} را وارد کنید"
                          : "برای ورود شماره موبایل خود را وارد کنید",
                      style: MyTextStyle.textMatn13.copyWith(
                        color: MyColors.text3,
                        height: 1.4,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Form section
                    if (!showOtpForm) _buildMobileInput(),
                    if (showOtpForm) _buildOtpInput(),

                    const SizedBox(height: 40),

                    // Action button

                    _buildActionButton(),

                    const SizedBox(height: 32),

                    // Footer buttons
                    if (showOtpForm) _buildResendOtpButton(),
                    const SizedBox(height: 16),
                    // _buildBackButton(),

                    // Bottom spacing
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "شماره موبایل",
          style: MyTextStyle.textMatn12Bold.copyWith(
            color: MyColors.textMatn1,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: MyColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _mobileFocusNode.hasFocus
                  ? MyColors.primary
                  : MyColors.divider,
              width: _mobileFocusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _mobileController,
            focusNode: _mobileFocusNode,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            style: MyTextStyle.textMatn16.copyWith(
              fontSize: 16,
              color: MyColors.textMatn1,
            ),
            decoration: InputDecoration(
              hintText: "09xxxxxxxxx",
              hintStyle: MyTextStyle.textMatn13.copyWith(
                color: MyColors.text4,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.phone_android,
                  color: MyColors.text3,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "کد تایید",
          style: MyTextStyle.textMatn12Bold.copyWith(
            color: MyColors.textMatn1,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: MyColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _otpFocusNode.hasFocus ? MyColors.primary : MyColors.divider,
              width: _otpFocusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: MyTextStyle.textMatn16.copyWith(
              fontSize: 18,
              color: MyColors.textMatn1,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: "000000",
              hintStyle: MyTextStyle.textMatn13.copyWith(
                color: MyColors.text4,
                letterSpacing: 2,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.lock_outline,
                  color: MyColors.text3,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileErrorRequestOtp) {
          log("error request otp");
          log(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: MyColors.error,
              duration: const Duration(seconds: 10),
            ),
          );
        } else if (state is ProfileErrorLogin) {
          log("error login");
          log(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: MyColors.error,
              duration: const Duration(seconds: 10),
            ),
          );
        } else if (state is ProfileSuccessRequestOtp) {
          log("success request otp");
          log(state.data.data.result.otp);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('کد تایید: ${state.data.data.result.otp}'),
              backgroundColor: MyColors.success,
              duration: const Duration(seconds: 5),
            ),
          );
          setState(() {
            showOtpForm = true;
            mobileNumber = _mobileController.text;
          });
        } else if (state is ProfileSuccessLogin) {
          // Save user data and login state
          locator<PrefsOperator>().saveUserData(
            state.data.data.result.accessToken,
            state.data.data.result.refreshToken,
            mobileNumber ?? '',
            mobileNumber ?? '',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('ورود با موفقیت انجام شد'),
              backgroundColor: MyColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          // Navigate to MainWrapper instead of profile screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            MainWrapper.routeName,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              color: MyColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }

        return SizedBox(
          width: 156,
          height: 64,
          child: PrimaryButton(
            lable: showOtpForm ? "تایید و ورود" : "دریافت کد تایید",
            onPressed: () {
              if (showOtpForm) {
                if (_otpController.text.isNotEmpty && mobileNumber != null) {
                  context.read<ProfileBloc>().add(
                        LoginWithOtpEvent(
                          mobile: mobileNumber!,
                          otp: _otpController.text,
                        ),
                      );
                }
              } else {
                if (_mobileController.text.isNotEmpty &&
                    _mobileController.text.length == 11) {
                  context.read<ProfileBloc>().add(
                        RequestOtpEvent(
                          mobile: _mobileController.text,
                        ),
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('لطفا شماره موبایل معتبر وارد کنید'),
                      backgroundColor: MyColors.warning,
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildResendOtpButton() {
    return TextButton(
      onPressed: () {
        if (mobileNumber != null) {
          context.read<ProfileBloc>().add(
                RequestOtpEvent(mobile: mobileNumber!),
              );
        }
      },
      child: Text(
        "ارسال مجدد کد",
        style: MyTextStyle.textMatn13.copyWith(
          color: MyColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget _buildBackButton() {
  //   return TextButton(
  //     onPressed: () {
  //       if (showOtpForm) {
  //         setState(() {
  //           showOtpForm = false;
  //           _otpController.clear();
  //           mobileNumber = null;
  //         });
  //       }
  //     },
  //     child: Text(
  //       showOtpForm ? "بازگشت" : "انصراف",
  //       style: MyTextStyle.textMatn13.copyWith(
  //         color: MyColors.text3,
  //       ),
  //     ),
  //   );
  // }
}
