import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../locator.dart';
import 'dart:developer';

class PrefsOperator {
  late SharedPreferences sharedPreferences;
  PrefsOperator() {
    sharedPreferences = locator<SharedPreferences>();
  }

  saveUserData(accessToken, refreshToken, userName, mobile) async {
    log("💾 Saving user data to SharedPreferences...");
    log("   Access token: ${accessToken.substring(0, 20)}...");
    log("   Refresh token: ${refreshToken.substring(0, 20)}...");
    log("   User name: $userName");
    log("   Mobile: $mobile");

    sharedPreferences.setString("user_token", accessToken);
    sharedPreferences.setString("refresh_token", refreshToken);
    sharedPreferences.setString("user_name", userName);
    sharedPreferences.setString("user_mobile", mobile);
    sharedPreferences.setBool("loggedIn", true);

    log("✅ User data saved successfully");
  }

  Future<String?> getUserToken() async {
    final String? userToken = sharedPreferences.getString('user_token');
    log("🔑 Retrieved user token: ${userToken != null ? '${userToken.substring(0, 20)}...' : 'null'}");
    return userToken;
  }

  Future<String?> getRefreshToken() async {
    final String? refreshToken = sharedPreferences.getString('refresh_token');
    log("🔄 Retrieved refresh token: ${refreshToken != null ? '${refreshToken.substring(0, 20)}...' : 'null'}");
    return refreshToken;
  }

  changeIntroState() async {
    sharedPreferences.setBool("showIntro", false);
  }

  Future<bool> getIntroState() async {
    return sharedPreferences.getBool("showIntro") ?? false;
  }

  Future<bool> getLoggedIn() async {
    return sharedPreferences.getBool("loggedIn") ?? false;
  }

  Future<void> logout() async {
    log("🚪 Logging out - clearing SharedPreferences");
    sharedPreferences.clear();
    sharedPreferences.setBool("showIntro", false);
    log("✅ Logout completed");
  }

  bool isLoggedIn() {
    final token = sharedPreferences.getString('user_token');
    log("🔍 Checking if user is logged in: ${token != null ? 'Yes' : 'No'}");
    return token != null;
  }

  Future<String?> getAccessToken() async {
    final token = sharedPreferences.getString('user_token');
    log("🔑 Retrieved access token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}");
    return token;
  }

  Future<String?> getUserName() async {
    final userName = sharedPreferences.getString('user_name');
    log("👤 Retrieved user name: ${userName ?? 'null'}");
    return userName;
  }

  // User Profile Data Methods
  Future<void> saveUserProfileData(
      String? firstName, String? lastName, String? avatar) async {
    log("💾 Saving user profile data to SharedPreferences...");
    log("   First name: ${firstName ?? 'null'}");
    log("   Last name: ${lastName ?? 'null'}");
    log("   Avatar: ${avatar ?? 'null'}");

    if (firstName != null) {
      sharedPreferences.setString("user_first_name", firstName);
    }
    if (lastName != null) {
      sharedPreferences.setString("user_last_name", lastName);
    }
    if (avatar != null) {
      sharedPreferences.setString("user_avatar", avatar);
    }

    log("✅ User profile data saved successfully");
  }

  Future<String?> getUserFirstName() async {
    final firstName = sharedPreferences.getString('user_first_name');
    log("👤 Retrieved user first name: ${firstName ?? 'null'}");
    return firstName;
  }

  Future<String?> getUserLastName() async {
    final lastName = sharedPreferences.getString('user_last_name');
    log("👤 Retrieved user last name: ${lastName ?? 'null'}");
    return lastName;
  }

  Future<String?> getUserAvatar() async {
    final avatar = sharedPreferences.getString('user_avatar');
    log("🖼️ Retrieved user avatar: ${avatar ?? 'null'}");
    return avatar;
  }

  Future<String> getFullUserName() async {
    final firstName = await getUserFirstName();
    final lastName = await getUserLastName();

    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    } else if (firstName != null) {
      return firstName;
    } else if (lastName != null) {
      return lastName;
    } else {
      return "کاربر";
    }
  }

  // Local Cart Storage Methods
  Future<void> saveLocalCartItem(String type, String itemId) async {
    log("🛒 Saving local cart item: Type=$type, ID=$itemId");
    final cartItems = await getLocalCartItems();
    final newItem = {
      'type': type,
      'itemId': itemId,
      'addedAt': DateTime.now().toIso8601String(),
    };

    // Check if item already exists
    final exists = cartItems
        .any((item) => item['type'] == type && item['itemId'] == itemId);

    if (!exists) {
      cartItems.add(newItem);
      await sharedPreferences.setString(
          'local_cart_items', jsonEncode(cartItems));
      log("✅ Local cart item saved successfully");
    } else {
      log("ℹ️ Item already exists in local cart - skipping");
    }
  }

  Future<List<Map<String, dynamic>>> getLocalCartItems() async {
    log("📋 Getting local cart items...");
    final cartJson = sharedPreferences.getString('local_cart_items');
    if (cartJson != null) {
      final List<dynamic> cartList = jsonDecode(cartJson);
      final items = cartList.cast<Map<String, dynamic>>();
      log("📊 Found ${items.length} local cart items");
      return items;
    }
    log("📭 No local cart items found");
    return [];
  }

  Future<void> removeLocalCartItem(String type, String itemId) async {
    log("🗑️ Removing local cart item: Type=$type, ID=$itemId");
    final cartItems = await getLocalCartItems();
    cartItems.removeWhere(
        (item) => item['type'] == type && item['itemId'] == itemId);
    await sharedPreferences.setString(
        'local_cart_items', jsonEncode(cartItems));
    log("✅ Local cart item removed successfully");
  }

  Future<void> clearLocalCart() async {
    log("🧹 Clearing local cart...");
    await sharedPreferences.remove('local_cart_items');
    log("✅ Local cart cleared successfully");
  }
}
