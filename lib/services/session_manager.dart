import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';

  static Future<void> saveSession(String accessToken, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<bool> hasActiveSession() async {
    final token = await getAccessToken();
    final userId = await getUserId();
    return token != null && userId != null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userIdKey);
  }

  static Future<Map<String, dynamic>?> getSessionData() async {
    final token = await getAccessToken();
    final userId = await getUserId();

    if (token != null && userId != null) {
      return {'access_token': token, 'user_id': userId};
    }
    return null;
  }
}
