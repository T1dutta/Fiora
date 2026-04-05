import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT from signup/login for authenticated API calls.
class AuthTokenStore {
  static const _key = 'fiora_access_token';

  static Future<void> save(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, token);
  }

  static Future<String?> read() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_key);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}
