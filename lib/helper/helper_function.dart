import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //key
  static String userLoggedInKey = "userLoggedInKey";
  static String userNameKey = "userNameKey";
  static String userEmailKey = "userEmailKey";

  //save data to shared preferences

  static Future<bool> saveUserLoggedInStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(userLoggedInKey, value);
  }

  static Future<bool> saveUserNameSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userNameKey, value);
  }

  static Future<bool> saveEmailSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userEmailKey, value);
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  static Future<String?> getEmailSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserNameSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }
}
