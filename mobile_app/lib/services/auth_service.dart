import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static const String _expiresAtKey = 'token_expires_at';

  // In-memory cache — avoids repeated disk reads
  static SharedPreferences? _prefs;
  static UserModel? _cachedUser;
  static String? _cachedToken;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Expose prefs for screens that need direct access (e.g. notification timestamps)
  static Future<SharedPreferences> getPrefsInstance() => _getPrefs();

  static Future<void> saveUser(UserModel user, {String? token, String? expiresAt}) async {
    final prefs = await _getPrefs();
    final userData = {
      'id': user.id,
      'email': user.email,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'role': user.role.name,
      'studentId': user.studentId,
      'department': user.department,
    };
    await prefs.setString(_userKey, json.encode(userData));

    if (token != null) {
      await prefs.setString(_tokenKey, token);
      _cachedToken = token;
    }
    if (expiresAt != null) {
      await prefs.setString(_expiresAtKey, expiresAt);
    }

    _cachedUser = user;
  }

  static Future<UserModel?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;
    final prefs = await _getPrefs();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _cachedUser = UserModel.fromJson(json.decode(userJson));
      return _cachedUser;
    }
    return null;
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await _getPrefs();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  static Future<bool> isTokenValid() async {
    final prefs = await _getPrefs();
    final expiresAt = prefs.getString(_expiresAtKey);
    if (expiresAt == null) return false;
    try {
      return DateTime.now().isBefore(DateTime.parse(expiresAt));
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await _getPrefs();
    await Future.wait([
      prefs.remove(_userKey),
      prefs.remove(_tokenKey),
      prefs.remove(_expiresAtKey),
    ]);
    _cachedUser = null;
    _cachedToken = null;
  }
}
