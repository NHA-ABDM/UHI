import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? preferences;

  static init() async {
    preferences = await SharedPreferences.getInstance();
  }

  static void saveString({required String key, required String? value}) {
    preferences?.setString(key, value ?? '');
  }

  static void saveBool({required String key, required bool? value}) {
    preferences?.setBool(key, value ?? false);
  }

  static String? getString({required String key}) {
    return preferences?.getString(key);
  }

  static bool? getBool({required String key}) {
    return preferences?.getBool(key);
  }
}