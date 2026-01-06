import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _kycVerifiedKey = 'kyc_verified';
  static const String _kycStatusKey = 'kyc_status';

  static Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  // KYC Status Caching
  static Future<void> setKycStatus(int verified, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kycVerifiedKey, verified);
    await prefs.setString(_kycStatusKey, status);
  }

  static Future<int?> getKycVerified() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_kycVerifiedKey);
    return value;
  }

  static Future<String?> getKycStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kycStatusKey);
  }
}
