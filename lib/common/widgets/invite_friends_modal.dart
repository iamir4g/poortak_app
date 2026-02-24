import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/locator.dart';
import 'package:dio/dio.dart';

class InviteFriendsModal extends StatelessWidget {
  const InviteFriendsModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const InviteFriendsModal();
      },
    );
  }

  Future<String?> _getReferralCode() async {
    final prefsOperator = PrefsOperator();

    // First, refresh user profile data from server
    await _refreshUserProfileFromServer();

    // Try the main method first
    final mainResult = await prefsOperator.getUserReferrerCode();
    print('🔍 Main method result: $mainResult');

    if (mainResult != null && mainResult.isNotEmpty) {
      return mainResult;
    }

    // Try different possible keys as fallback
    final possibleKeys = [
      'user_referrer_code',
      'referrerCode',
      'refferCode',
      'referralCode',
      'user_referral_code',
    ];

    for (String key in possibleKeys) {
      try {
        final value = prefsOperator.sharedPreferences.getString(key);
        if (value != null && value.isNotEmpty) {
          print('🔍 Found referral code with key "$key": $value');
          return value;
        }
      } catch (e) {
        print('🔍 Error checking key "$key": $e');
      }
    }

    return null;
  }

  Future<void> _refreshUserProfileFromServer() async {
    try {
      print('🔄 Refreshing user profile data from server...');
      final profileRepository =
          ProfileRepository(ProfileApiProvider(dio: locator<Dio>()));
      final prefsOperator = PrefsOperator();

      final response = await profileRepository.callGetMeProfile();

      if (response is DataSuccess && response.data != null) {
        final userData = response.data!.data;
        print('✅ User profile refreshed successfully');
        print('   Referrer Code: ${userData.referrerCode ?? 'null'}');

        // Save profile data to preferences
        await prefsOperator.saveUserProfileData(
          userData.firstName,
          userData.lastName,
          userData.avatar,
          email: userData.email,
          ageGroup: userData.ageGroup,
          nationalCode: userData.nationalCode,
          province: userData.province,
          city: userData.city,
          address: userData.address,
          postalCode: userData.postalCode,
          birthdate: userData.birthdate?.toString(),
          rate: userData.rate,
          referrerCode: userData.referrerCode,
        );

        print('💾 Updated profile data saved to preferences');
      } else {
        print('⚠️ Failed to refresh user profile data');
        print('   Response: $response');
      }
    } catch (e) {
      print('💥 Error refreshing user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350.w,
        height: 462.h,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2E3F) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 6.h),

                // Lottie Animation
                SizedBox(
                  width: 231.w,
                  height: 231.h,
                  child: Lottie.asset(
                    'assets/images/points/refferal.json',
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 3.h),

                // Referral Code Container
                Container(
                    width: 252.w,
                    height: 56.h,
                    padding: EdgeInsets.only(right: 16.w, left: 16.w),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF323548)
                          : const Color(0xFFF6F9FE),
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: FutureBuilder<String?>(
                              future: _getReferralCode(),
                              builder: (context, snapshot) {
                                final referralCode = snapshot.data ?? 'B12NJS';
                                return Center(
                                  child: Text(
                                    referralCode,
                                    style: TextStyle(
                                      fontFamily: 'IranSans',
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF3D495C),
                                      letterSpacing: 5.4.w,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final referralCode =
                                  await _getReferralCode() ?? 'B12NJS';
                              print('🔍 Copying referral code: $referralCode');
                              await Clipboard.setData(
                                  ClipboardData(text: referralCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('کد معرف کپی شد'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(Icons.copy,
                                    size: 20.w, color: Colors.black),
                              ),
                            ),
                          ),
                        ])),

                SizedBox(height: 9.h),

                // Description Text
                SizedBox(
                  width: 232.w,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'IranSans',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF3D495C),
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'این '),
                        TextSpan(
                          text: 'کد معرف',
                          style: TextStyle(
                            fontFamily: 'IranSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        const TextSpan(
                            text:
                                ' را برای دوستان خود بفرستید تا آنها در زمان خرید از اپلیکیشن، این کد را وارد نمایند و پس از آن، '),
                        TextSpan(
                          text: '۱۰',
                          style: TextStyle(
                            fontFamily: 'IranSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        const TextSpan(text: ' امتیاز برای شما و '),
                        TextSpan(
                          text: '۱۰',
                          style: TextStyle(
                            fontFamily: 'IranSans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                            text: ' امتیاز برای دوستتان ثبت می شود.'),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                SizedBox(height: 20.h),

                // Bottom Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Share Button
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'قابلیت اشتراک‌گذاری به زودی اضافه خواهد شد'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: 56.w,
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF323548)
                              : const Color(0xFFF6F9FE),
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        child: Icon(
                          Icons.share,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF3D495C),
                          size: 24.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Copy Button
                    GestureDetector(
                      onTap: () async {
                        final referralCode =
                            await _getReferralCode() ?? 'B12NJS';
                        print('🔍 Copying referral code: $referralCode');
                        await Clipboard.setData(
                            ClipboardData(text: referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('کد معرف کپی شد'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: 179.w,
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4281EC),
                          borderRadius: BorderRadius.circular(56.5.r),
                        ),
                        child: Center(
                          child: Text(
                            'کپی کردن کد دعوت',
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Close Button (X) - Top Left
            Positioned(
              top: 12.h,
              left: 12.w,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF323548)
                        : const Color(0xFFF6F9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.w,
                    color: isDarkMode ? Colors.white : const Color(0xFF3D495C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
