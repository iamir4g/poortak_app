import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/locator.dart';
import 'dart:developer';
import 'dart:async';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  final PrefsOperator prefsOperator = locator<PrefsOperator>();

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<LoginWithOtpEvent>(_onLoginWithOtp);
    on<GetMeProfileEvent>(_onGetMeProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  void _onRequestOtp(RequestOtpEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await repository.callRequestOtp(
        event.mobile,
        appSignatureHash: event.appSignatureHash,
      );

      if (response is DataSuccess) {
        if (response.data != null) {
          emit(ProfileSuccessRequestOtp(response.data!));
        } else {
          emit(ProfileErrorRequestOtp("Invalid response data"));
        }
      } else if (response is DataFailed) {
        emit(
            ProfileErrorRequestOtp(response.error ?? "خطا در دریافت کد تایید"));
      }
    } catch (e) {
      emit(ProfileErrorRequestOtp(e.toString()));
    }
  }

  void _onLoginWithOtp(
      LoginWithOtpEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      log("🔄 Starting login process for mobile: ${event.mobile}");
      final response = await repository.callLoginWithOtp(event.otp);
      log("📡 Login Response: ${response}");

      if (response is DataSuccess) {
        if (response.data != null) {
          final loginData = response.data!;
          log("✅ Login successful! Saving user data...");
          log("📱 User mobile: ${event.mobile}");
          log("🔑 Access token: ${loginData.data.result.accessToken.substring(0, 20)}...");
          log("🔄 Refresh token: ${loginData.data.result.refreshToken.substring(0, 20)}...");

          await prefsOperator.saveUserData(
            loginData.data.result.accessToken,
            loginData.data.result.refreshToken,
            event.mobile,
            event.mobile,
          );
          log("💾 User data saved successfully to local storage");

          // Get user profile data after successful login
          log("👤 Getting user profile data...");
          await _getAndSaveUserProfile();

          // Sync local cart data to server after successful login with delay
          log("🛒 Starting cart sync process...");
          await _syncLocalCartToServerWithDelay();

          log("🎉 Login process completed successfully!");
          emit(ProfileSuccessLogin(loginData));
        } else {
          log("❌ Login failed: Invalid response data");
          emit(ProfileErrorLogin("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("❌ Login failed: ${response.error ?? "خطا در ورود"}");
        emit(ProfileErrorLogin(response.error ?? "خطا در ورود"));
      }
    } catch (e) {
      log("💥 Login error: $e");
      emit(ProfileErrorLogin(e.toString()));
    }
  }

  // Sync local cart data to server after successful login with delay
  Future<void> _syncLocalCartToServerWithDelay() async {
    try {
      log("🔍 Checking for local cart items...");

      // Get local cart items
      final localCartItems = await prefsOperator.getLocalCartItems();

      log("📊 Found ${localCartItems.length} local cart items");

      if (localCartItems.isNotEmpty) {
        log("⏳ Waiting 2 seconds for authentication to be properly set up...");
        await Future.delayed(const Duration(seconds: 2));
        log("✅ Authentication delay completed, proceeding with cart sync");

        log("🔄 Starting cart sync to server...");
        log("📋 Cart items to sync:");

        for (int i = 0; i < localCartItems.length; i++) {
          final item = localCartItems[i];
          log("   ${i + 1}. Type: ${item['type']}, ID: ${item['itemId']}, Added: ${item['addedAt']}");
        }

        // Get shopping cart bloc from locator
        final shoppingCartBloc = locator<ShoppingCartBloc>();
        log("🎯 Shopping cart bloc retrieved from locator");

        // Sync local cart to backend
        log("📤 Sending SyncLocalCartToBackendEvent to shopping cart bloc...");
        shoppingCartBloc.add(SyncLocalCartToBackendEvent());

        log("✅ Cart sync event dispatched successfully");
        log("⏳ Cart sync process initiated - items will be sent to server");

        // Log the expected API calls
        log("🌐 Expected API calls to server:");
        for (final item in localCartItems) {
          log("   POST /cart - Type: ${item['type']}, ItemId: ${item['itemId']}");
        }
      } else {
        log("📭 No local cart items found - skipping cart sync");
        log("ℹ️ User has no items in local cart to sync to server");
      }
    } catch (e) {
      log("💥 Error during cart sync: $e");
      log("⚠️ Cart sync failed, but login will continue");
      // Don't throw error here as login should still succeed even if cart sync fails
    }
  }

  // Get user profile data and save to preferences
  Future<void> _getAndSaveUserProfile() async {
    try {
      log("🔍 Fetching user profile data...");
      final response = await repository.callGetMeProfile();

      if (response is DataSuccess && response.data != null) {
        final userData = response.data!.data;
        log("✅ User profile data retrieved successfully");
        log("   First name: ${userData.firstName ?? 'null'}");
        log("   Last name: ${userData.lastName ?? 'null'}");
        log("   Avatar: ${userData.avatar ?? 'null'}");
        log("   Referrer Code: ${userData.referrerCode ?? 'null'}");

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

        log("💾 User profile data saved to preferences successfully");
      } else {
        log("⚠️ Failed to get user profile data, but login will continue");
        log("   Response: ${response}");
      }
    } catch (e) {
      log("💥 Error getting user profile data: $e");
      log("⚠️ Profile data fetch failed, but login will continue");
      // Don't throw error here as login should still succeed even if profile fetch fails
    }
  }

  void _onGetMeProfile(
      GetMeProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      log("🔄 Getting user profile...");
      final response = await repository.callGetMeProfile();
      log("📡 Get Me Profile Response: ${response}");

      if (response is DataSuccess) {
        if (response.data != null) {
          log("✅ Profile retrieved successfully!");
          emit(ProfileSuccessGetMe(response.data!));
        } else {
          log("❌ Get profile failed: Invalid response data");
          emit(ProfileErrorGetMe("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("❌ Get profile failed: ${response.error ?? "خطا در دریافت پروفایل"}");
        emit(ProfileErrorGetMe(response.error ?? "خطا در دریافت پروفایل"));
      }
    } catch (e) {
      log("💥 Get profile error: $e");
      emit(ProfileErrorGetMe(e.toString()));
    }
  }

  void _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      log("🔄 Updating user profile...");
      log("📝 Update data: firstName=${event.updateProfileParams.firstName}, lastName=${event.updateProfileParams.lastName}");
      final response =
          await repository.callPutUserProfile(event.updateProfileParams);
      log("📡 Update Profile Response: ${response}");

      if (response is DataSuccess) {
        if (response.data != null) {
          log("✅ Profile updated successfully!");

          // Save updated profile data to preferences
          final updatedData = response.data!.data;
          log("💾 Saving updated profile data to preferences...");
          log("   First name: ${updatedData.firstName}");
          log("   Last name: ${updatedData.lastName}");
          log("   Avatar: ${updatedData.avatar}");

          await prefsOperator.saveUserProfileData(
            updatedData.firstName,
            updatedData.lastName,
            updatedData.avatar,
            email: updatedData.email,
            ageGroup: updatedData.ageGroup,
            nationalCode: updatedData.nationalCode,
            province: updatedData.province,
            city: updatedData.city,
            address: updatedData.address,
            postalCode: updatedData.postalCode,
            birthdate: updatedData.birthdate?.toIso8601String(),
            rate: updatedData.rate,
            // referrerCode is not available in UpdateProfileModel
          );

          log("✅ Updated profile data saved to preferences successfully!");
          emit(ProfileSuccessUpdate(response.data!));
        } else {
          log("❌ Update profile failed: Invalid response data");
          emit(ProfileErrorUpdate("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("❌ Update profile failed: ${response.error ?? "خطا در بروزرسانی پروفایل"}");
        emit(ProfileErrorUpdate(response.error ?? "خطا در بروزرسانی پروفایل"));
      }
    } catch (e) {
      log("💥 Update profile error: $e");
      emit(ProfileErrorUpdate(e.toString()));
    }
  }
}
