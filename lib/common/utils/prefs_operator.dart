import 'package:shared_preferences/shared_preferences.dart';
import '../../locator.dart';

class PrefsOperator {
  late SharedPreferences sharedPreferences;
  PrefsOperator() {
    sharedPreferences = locator<SharedPreferences>();
  }

  saveUserData(accessToken, refreshToken, userName, mobile) async {
    sharedPreferences.setString("user_token", accessToken);
    sharedPreferences.setString("refresh_token", refreshToken);
    sharedPreferences.setString("user_name", userName);
    sharedPreferences.setString("user_mobile", mobile);
    sharedPreferences.setBool("loggedIn", true);
  }

  Future<String?> getUserToken() async {
    final String? userToken = sharedPreferences.getString('user_token');
    return userToken;
  }

  Future<String?> getRefreshToken() async {
    final String? refreshToken = sharedPreferences.getString('refresh_token');
    return refreshToken;
  }

  changeIntroState() async {
    sharedPreferences.setBool("showIntro", false);
  }

  Future<bool> getIntroState() async {
    return sharedPreferences.getBool("showIntro") ?? true;
  }

  Future<bool> getLoggedIn() async {
    return sharedPreferences.getBool("loggedIn") ?? false;
  }

  Future<void> logout() async {
    sharedPreferences.clear();
    sharedPreferences.setBool("showIntro", false);
  }

  bool isLoggedIn() {
    return sharedPreferences.getString('user_token') != null;
  }
}
