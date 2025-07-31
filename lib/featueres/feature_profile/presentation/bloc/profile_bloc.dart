import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_profile/data/models/login_with_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/request_otp_model.dart';
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
  }

  void _onRequestOtp(RequestOtpEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await repository.callRequestOtp(event.mobile);

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
}
