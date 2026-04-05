import 'package:shared_preferences/shared_preferences.dart';

/// Cached profile name for instant home greeting; refreshed from GET /profiles/me.
class UserPrefs {
  static const _kProfileName = 'fiora_profile_display_name';

  static Future<void> saveProfileName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kProfileName, name.trim());
  }

  static Future<String?> readProfileName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kProfileName);
  }

  static Future<void> clearProfileName() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kProfileName);
  }
}
