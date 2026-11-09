import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  bool getBool(String key, {bool fallback = false}) =>
      _prefs.getBool(key) ?? fallback;
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  int getInt(String key, {int fallback = 0}) => _prefs.getInt(key) ?? fallback;
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  double getDouble(String key, {double fallback = 0}) =>
      _prefs.getDouble(key) ?? fallback;
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<void> clear() => _prefs.clear();
}
