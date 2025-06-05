import 'dart:developer';

import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(repository: locator()),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F0FC),
                Color(0xFFFCEBF1),
                Color(0xFFEFE8FC),
              ],
              stops: [0.1, 0.54, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showOtpForm
                        ? "کد تایید را وارد کنید"
                        : "ورود به حساب کاربری",
                    style: MyTextStyle.textMatn14Bold,
                  ),
                  const SizedBox(height: 32),
                  if (!showOtpForm)
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "شماره موبایل",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: MyColors.background,
                      ),
                    ),
                  if (showOtpForm)
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "کد تایید",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: MyColors.background,
                      ),
                    ),
                  const SizedBox(height: 24),
                  BlocConsumer<ProfileBloc, ProfileState>(
                    listener: (context, state) {
                      if (state is ProfileErrorRequestOtp) {
                        log("error request otp");
                        log(state.message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            duration: const Duration(seconds: 10),
                          ),
                        );
                      } else if (state is ProfileErrorLogin) {
                        log("error login");
                        log(state.message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            duration: const Duration(seconds: 10),
                          ),
                        );
                      } else if (state is ProfileSuccessRequestOtp) {
                        log("success request otp");
                        log(state.data.data.result.otp);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('کد تایید: ${state.data.data.result.otp}'),
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
                          const SnackBar(
                            content: Text('ورود با موفقیت انجام شد'),
                            duration: Duration(seconds: 2),
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
                        return const CircularProgressIndicator();
                      }
                      return PrimaryButton(
                        lable: showOtpForm ? "تایید" : "دریافت کد تایید",
                        onPressed: () {
                          if (showOtpForm) {
                            if (_otpController.text.isNotEmpty &&
                                mobileNumber != null) {
                              context.read<ProfileBloc>().add(
                                    LoginWithOtpEvent(
                                      mobile: mobileNumber!,
                                      otp: _otpController.text,
                                    ),
                                  );
                            }
                          } else {
                            if (_mobileController.text.isNotEmpty) {
                              print(_mobileController.text);
                              context.read<ProfileBloc>().add(
                                    RequestOtpEvent(
                                      mobile: _mobileController.text,
                                    ),
                                  );
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
