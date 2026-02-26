import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/widgets/main_wrapper.dart';
import 'package:poortak/featueres/feature_profile/widgets/terms_conditions_modal.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/config/dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_state.dart';
import 'package:poortak/locator.dart';
import 'package:smart_auth/smart_auth.dart';

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

  // Timer variables
  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes = 120 seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _getAppSignature();
  }

  void _getAppSignature() async {
    try {
      final res = await SmartAuth.instance.getAppSignature();
      log("📱 App Signature for SMS Retriever: ${res.data}");
    } catch (e) {
      log("Error getting app signature: $e");
    }
  }

  void _startSmsListener() async {
    try {
      final res = await SmartAuth.instance.getSmsWithRetrieverApi();
      if (!mounted) return;
      if (res.hasData) {
        final code = res.data?.code;
        if (code != null) {
          setState(() {
            _otpController.text = code;
          });
          // Optional: Auto submit
          if (mobileNumber != null) {
            context.read<ProfileBloc>().add(
                  LoginWithOtpEvent(
                    mobile: mobileNumber!,
                    otp: code,
                  ),
                );
          }
        }
      }
    } catch (e) {
      log("Error listening for SMS: $e");
    }
  }

  @override
  void dispose() {
    SmartAuth.instance.removeSmsRetrieverApiListener();
    _timer?.cancel();
    _mobileController.dispose();
    _otpController.dispose();
    _mobileFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 120;
    _canResend = false;
    log("🕐 Timer started: $_remainingSeconds seconds remaining");

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        log("🕐 Timer tick: $_remainingSeconds seconds remaining");
      } else {
        setState(() {
          _canResend = true;
        });
        log("🕐 Timer finished: Resend button now available");
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _remainingSeconds = 120;
    _canResend = false;
    _startTimer();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(repository: locator()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/login/login_background.png',
                fit: BoxFit.cover,
              ),
            ),
            // Content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.0.w),
                  child: Column(
                    children: [
                      // Top spacing
                      SizedBox(height: 100.h),

                      // Logo section
                      Center(
                        child: Image.asset(
                          'assets/images/poortakLogo.png',
                          height: 102.h,
                          width: 153.w,
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: Dimens.medium.h),

                      // Title section
                      Text(
                        showOtpForm
                            ? "کد ارسال شده را وارد کنید:"
                            : "شماره موبایل خود را وارد کنید:",
                        style: MyTextStyle.textMatn12Bold.copyWith(
                          fontSize: 16.sp,
                          color: MyColors.textMatn1,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: Dimens.medium.h),

                      // Form section
                      if (!showOtpForm) _buildMobileInput(),
                      if (showOtpForm) _buildOtpInput(),

                      SizedBox(height: Dimens.small.h),

                      // Subtitle for OTP
                      if (showOtpForm) ...[
                        Text(
                          "کد ارسال شده به شماره 09${mobileNumber ?? ''} را وارد کنید",
                          style: MyTextStyle.textMatn13.copyWith(
                            color: MyColors.text3,
                            height: 1.4,
                            fontSize: 13.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        // Timer display or resend button
                        if (!_canResend)
                          Text(
                            "ارسال مجدد کد:${_formatTime(_remainingSeconds)}",
                            style: MyTextStyle.textMatn13.copyWith(
                              color: MyColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Builder(
                            builder: (builderContext) {
                              return TextButton(
                                onPressed: () {
                                  if (mobileNumber != null) {
                                    builderContext.read<ProfileBloc>().add(
                                          RequestOtpEvent(
                                              mobile: "09$mobileNumber"),
                                        );
                                    // Reset timer after resending
                                    _resetTimer();
                                  }
                                },
                                child: Text(
                                  "ارسال مجدد کد",
                                  style: MyTextStyle.textMatn13.copyWith(
                                    color: MyColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],

                      if (!showOtpForm)
                        Text(
                          "یک کد تایید برای شما ارسال می شود.",
                          style: MyTextStyle.textMatn13.copyWith(
                            color: MyColors.text3,
                            height: 1.4,
                            fontSize: 13.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      SizedBox(height: 60.h),

                      // Terms and conditions link
                      if (!showOtpForm) _buildTermsLink(),

                      SizedBox(height: Dimens.small.h),

                      // Action button
                      _buildActionButton(),

                      SizedBox(height: Dimens.small.h),

                      // Footer buttons removed - resend button is now in OTP section

                      // Bottom spacing
                      SizedBox(height: 40.h),
                      // const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInput() {
    return Container(
      constraints: BoxConstraints(maxWidth: 360.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _mobileController,
                focusNode: _mobileFocusNode,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.left,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                onChanged: (value) {
                  // Close keyboard when mobile number is complete (9 digits)
                  if (value.length == 9) {
                    FocusScope.of(context).unfocus();
                  }
                },
                style: MyTextStyle.textMatn16.copyWith(
                  fontSize: 16.sp,
                  color: MyColors.textMatn1,
                  // fontFamily: 'monospace', // برای نمایش بهتر اعداد
                ),
                decoration: InputDecoration(
                  hintText: "xxxxxxxxx",
                  hintStyle: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16.sp,
                    fontFamily: 'monospace',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 18.h,
                  ),
                ),
              ),
            ),
          ),
          // Divider line
          Container(
            width: 1.w,
            height: 20.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            color: MyColors.divider,
          ),
          // Prefix "۰۹"
          Text(
            "۰۹",
            style: MyTextStyle.textMatn12Bold.copyWith(
              fontSize: 22.sp,
              color: MyColors.textMatn1,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          // Phone icon
          Container(
            width: 56.r,
            height: 56.r,
            margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(19.r),
            ),
            child: Transform.rotate(
              angle: 4.71238,
              child: Center(
                child: IconifyIcon(
                  icon: "ion:call",
                  color: MyColors.text4,
                  size: 18.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: MyColors.background,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color:
                  _otpFocusNode.hasFocus ? MyColors.primary : MyColors.divider,
              width: _otpFocusNode.hasFocus ? 2.w : 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              autofillHints: const [AutofillHints.oneTimeCode],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onChanged: (value) {
                // Close keyboard when OTP is complete (4 digits)
                if (value.length == 4) {
                  FocusScope.of(context).unfocus();
                }
              },
              style: MyTextStyle.textMatn16.copyWith(
                fontSize: 18.sp,
                color: MyColors.textMatn1,
                letterSpacing: 2.w,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                hintText: "----",
                hintStyle: MyTextStyle.textMatn13.copyWith(
                  color: MyColors.text4,
                  letterSpacing: 4.w,
                  fontFamily: 'monospace',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 18.h,
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
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is ProfileErrorLogin) {
          log("error login");
          log(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: MyColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is ProfileSuccessRequestOtp) {
          log("success request otp");
          log(state.data.data.result.otp);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('کد تایید: ${state.data.data.result.otp}'),
          //     backgroundColor: MyColors.success,
          //     duration: const Duration(seconds: 5),
          //   ),
          // );
          setState(() {
            showOtpForm = true;
            mobileNumber = _mobileController.text;
          });
          // Start the timer when OTP is successfully requested
          log("🕐 Starting OTP timer...");
          _startTimer();
          _startSmsListener();
        } else if (state is ProfileSuccessLogin) {
          // Save user data and login state
          locator<PrefsOperator>().saveUserData(
            state.data.data.result.accessToken,
            state.data.data.result.refreshToken,
            "09${mobileNumber ?? ''}",
            "09${mobileNumber ?? ''}",
            // userId: state.data.data.result.user.id,
            // referrerCode: state.data.data.result.user.referrerCode,
            // rate: state.data.data.result.user.rate,
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
            height: 56.h,
            decoration: BoxDecoration(
              color: MyColors.primary,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.w,
              ),
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(
            minWidth: 156.w,
            minHeight: 56.h,
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: MyColors.primary,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
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
                      _mobileController.text.length == 9) {
                    context.read<ProfileBloc>().add(
                          RequestOtpEvent(
                            mobile: "09${_mobileController.text}",
                          ),
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('لطفا شماره موبایل معتبر وارد کنید'),
                        backgroundColor: MyColors.warning,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Center(
                child: Text(
                  showOtpForm ? "تایید و ورود" : "تأیید",
                  style: MyTextStyle.textMatn12Bold.copyWith(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsLink() {
    return GestureDetector(
      onTap: () {
        TermsConditionsModal.show(context);
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "قوانین و مقررات ",
              style: MyTextStyle.textMatn13.copyWith(
                fontSize: 14.sp,
                color: MyColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "خرید از پورتک",
              style: MyTextStyle.textMatn13.copyWith(
                fontSize: 14.sp,
                color: MyColors.textMatn1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
