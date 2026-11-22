import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_logger.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Generic helpers
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException catch (e) {
      AppLogger.warning('Corrupted JSON stored for key "$key"', e);
      return null;
    } catch (e) {
      AppLogger.warning('Error retrieving key "$key"', e);
      return null;
    }
  }

  Future<bool> setJson(String key, Map<String, dynamic> data) {
    return _prefs.setString(key, jsonEncode(data));
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } on FormatException catch (e) {
      AppLogger.warning('Corrupted JSON list stored for key "$key"', e);
      return null;
    } catch (e) {
      AppLogger.warning('Error retrieving list key "$key"', e);
      return null;
    }
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> list) {
    return _prefs.setString(key, jsonEncode(list));
  }

  Future<void> clearAll() => _prefs.clear();
}
